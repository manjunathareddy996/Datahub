CREATE OR REPLACE PROCEDURE BAGIC_PREPROD_CURATED_DB.UTILS.MAXI_RAW_DBT_ORCHESTRATOR_SP("RUN_MODE" VARCHAR DEFAULT 'full', "FAILED_RUN_ID" VARCHAR DEFAULT '', "MODEL_NAMES" VARCHAR DEFAULT '')
RETURNS VARCHAR
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'main'
EXTERNAL_ACCESS_INTEGRATIONS = (AWS_SES_INTEGRATION)
SECRETS = ('creds'=BAGIC_PREPROD_CURATED_DB.UTILS.SMTP_SECRET)
EXECUTE AS CALLER
AS '
import json
import re
import time
import smtplib
from datetime import datetime, timedelta
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import _snowflake

# ─── Configuration ────────────────────────────────────────────────────────────
DBT_DATABASE = "BAGIC_PREPROD_CURATED_DB"
DBT_SCHEMA = "UTILS"
DBT_PROJECT_OBJECT = "POC_DBT_TEST"
DBT_PROJECT_FQN = f"{DBT_DATABASE}.{DBT_SCHEMA}.{DBT_PROJECT_OBJECT}"
CHECKPOINT_TABLE = f"{DBT_DATABASE}.{DBT_SCHEMA}.MAXI_RAW_DBT_MODEL_RUN_LOG"
WAREHOUSE = "SNOWFLAKE_LEARNING_WH"
RETENTION_DAYS = 30

SENDER_EMAIL = "DPM_L1_Team@bajajallianz.co.in"
RECIPIENT_EMAILS = [
    "ashraf.shaik01@bajajgeneral.com",
    "sarvesh.shukla@bajajgeneral.com",
    "mallareddygari.reddy@bajajgeneral.com"
]

# ─── run_results.json Parser ──────────────────────────────────────────────────

def get_run_results_from_artifacts(session, query_id):
    try:
        result = session.sql(f"SELECT SYSTEM$LOCATE_DBT_ARTIFACTS(''{query_id}'')").collect()
        artifact_path = result[0][0] if result else None
        if not artifact_path:
            return None
        if not artifact_path.endswith(''/''):
            artifact_path += ''/''
        session.sql("CREATE OR REPLACE TEMPORARY STAGE MAXI_RAW_TMP_ARTIFACTS ENCRYPTION = (TYPE = ''SNOWFLAKE_SSE'')").collect()
        session.sql(f"COPY FILES INTO @MAXI_RAW_TMP_ARTIFACTS/ FROM ''{artifact_path}target/'' FILES = (''run_results.json'')").collect()
        row = session.sql("SELECT $1 FROM @MAXI_RAW_TMP_ARTIFACTS/run_results.json (FILE_FORMAT => ''JSON_FORMAT'')").collect()
        if not row or not row[0][0]:
            return None
        data = row[0][0]
        return json.loads(data) if isinstance(data, str) else data
    except Exception as e:
        return None


def parse_run_results(run_results):
    failed, succeeded, skipped = [], [], []
    failure_details = {}
    model_info = {}
    for result in run_results.get("results", []):
        unique_id = result.get("unique_id", "")
        model_name = unique_id.split(".")[-1] if unique_id else "unknown"
        status = result.get("status", "")
        message = result.get("message", "")
        exec_time = result.get("execution_time", 0)
        timing = result.get("timing", [])
        completed_at = ""
        for t in timing:
            if t.get("name") == "execute" and t.get("completed_at"):
                completed_at = t["completed_at"]
                break
        model_info[model_name] = {
            "execution_time": exec_time, "status": status,
            "completed_at": completed_at, "unique_id": unique_id
        }
        if status == "error":
            failed.append(model_name)
            failure_details[model_name] = message[:300] if message else "Unknown error"
        elif status in ("success", "pass"):
            succeeded.append(model_name)
        elif status == "skipped":
            skipped.append(model_name)
    return sorted(failed), sorted(succeeded), sorted(skipped), failure_details, model_info

# ─── Rerun Strategy ───────────────────────────────────────────────────────────

def build_select_args(failed_models):
    if not failed_models:
        return "run"
    return f"run --select {'' ''.join(f''{m}+'' for m in failed_models)}"


def build_exclude_args(succeeded_models):
    if not succeeded_models:
        return "run"
    return f"run --exclude {'' ''.join(succeeded_models)}"


# ─── Snowflake Helpers ────────────────────────────────────────────────────────

def query_checkpoint_by_status(session, run_id, status):
    rows = session.sql(
        f"SELECT DISTINCT model_name FROM {CHECKPOINT_TABLE} "
        f"WHERE run_id = ''{run_id}'' AND status = ''{status}''"
    ).collect()
    return [row[0] for row in rows]


def query_latest_run_id(session):
    rows = session.sql(
        f"SELECT run_id FROM {CHECKPOINT_TABLE} ORDER BY run_start_timestamp DESC LIMIT 1"
    ).collect()
    return rows[0][0] if rows else None


def update_checkpoint_after_run(session, failed_models, skipped_models, failure_details, run_id):
    for model in failed_models:
        error_msg = failure_details.get(model, "Unknown error").replace("''", "''''")[:2000]
        session.sql(
            f"UPDATE {CHECKPOINT_TABLE} SET status = ''FAILED'', error_message = ''{error_msg}'' "
            f"WHERE model_name = ''{model}'' AND run_id = ''{run_id}'' AND status = ''RUNNING''"
        ).collect()
    for model in skipped_models:
        session.sql(
            f"UPDATE {CHECKPOINT_TABLE} SET status = ''SKIPPED'' "
            f"WHERE model_name = ''{model}'' AND run_id = ''{run_id}'' AND status = ''RUNNING''"
        ).collect()


def update_all_running_to_failed(session, run_id, error_message):
    """Update all RUNNING models to FAILED when dbt execution fails completely"""
    error_msg = error_message.replace("''", "''''")[:2000]
    result = session.sql(
        f"UPDATE {CHECKPOINT_TABLE} SET status = ''FAILED'', error_message = ''{error_msg}'' "
        f"WHERE run_id = ''{run_id}'' AND status = ''RUNNING''"
    ).collect()
    # Return count of updated rows
    rows = session.sql(
        f"SELECT COUNT(*) FROM {CHECKPOINT_TABLE} "
        f"WHERE run_id = ''{run_id}'' AND status = ''FAILED''"
    ).collect()
    return rows[0][0] if rows else 0


def full_cross_validate(session, run_id, rr_failed, rr_succeeded, rr_skipped):
    cp_succeeded = set(query_checkpoint_by_status(session, run_id, "SUCCESS"))
    cp_failed = set(query_checkpoint_by_status(session, run_id, "FAILED"))
    cp_skipped = set(query_checkpoint_by_status(session, run_id, "SKIPPED"))
    issues = []
    if cp_succeeded != set(rr_succeeded):
        issues.append(f"SUCCESS mismatch: {sorted(cp_succeeded.symmetric_difference(set(rr_succeeded)))}")
    if cp_failed != set(rr_failed):
        issues.append(f"FAILED mismatch: {sorted(cp_failed.symmetric_difference(set(rr_failed)))}")
    if cp_skipped != set(rr_skipped):
        issues.append(f"SKIPPED mismatch: {sorted(cp_skipped.symmetric_difference(set(rr_skipped)))}")
    if not issues:
        return {"status": "FULL MATCH", "detail": f"Checkpoint matches run_results.json ({len(rr_succeeded)} SUCCESS, {len(rr_failed)} FAILED, {len(rr_skipped)} SKIPPED)"}
    return {"status": "MISMATCH", "detail": " | ".join(issues)}



# ─── Email ─────────────────────────────────────────────────────────────────────

def send_email_report(subject, body_html):
    try:
        creds = json.loads(_snowflake.get_generic_secret_string(''creds''))
        msg = MIMEMultipart("alternative")
        msg["From"] = SENDER_EMAIL
        msg["To"] = ", ".join(RECIPIENT_EMAILS)
        msg["Subject"] = subject
        msg.attach(MIMEText(body_html, "html", "utf-8"))
        with smtplib.SMTP(creds[''host''], int(creds[''port'']), timeout=30) as server:
            server.starttls()
            server.login(creds[''user''], creds[''password''])
            server.send_message(msg)
        return "Email sent successfully"
    except Exception as e:
        return f"Email failed: {str(e)}"

# ─── HTML Report Generator ────────────────────────────────────────────────────

def generate_report_html(report_date, run_mode, overall_status, succeeded_models,
                         failed_models, skipped_models, execution_time, summary,
                         validation_status, query_id, dbt_args_used,
                         failure_details, model_info, full_cross_validation,
                         dbt_execution_failed=False, dbt_error_message="", models_marked_failed=0):
    total = summary.get("total", len(succeeded_models) + len(failed_models) + len(skipped_models))
    duration_str = f"{int(execution_time // 60)}m {int(execution_time % 60)}s"

    # DBT Execution Failure Alert
    dbt_failure_alert = ""
    if dbt_execution_failed:
        dbt_failure_alert = (
            f"<div style=''background:#fde7e9;border:2px solid #d13438;padding:15px;margin-bottom:20px;border-radius:4px''>"
            f"<h3 style=''color:#d13438;margin:0 0 10px''>! DBT Execution Failed</h3>"
            f"<p style=''margin:5px 0''><strong>Error:</strong> {dbt_error_message[:300]}</p>"
            f"<p style=''margin:5px 0''><strong>Models Marked as Failed:</strong> {models_marked_failed} (all RUNNING states updated to FAILED)</p>"
            f"<p style=''margin:5px 0;font-size:12px;color:#666''>Post-hooks did not execute. All models in RUNNING state have been marked as FAILED.</p>"
            f"</div>"
        )

    # Failed models table
    failed_html = ""
    if failed_models:
        failed_rows = ""
        for m in failed_models:
            err = failure_details.get(m, "Unknown error").replace("\\n", " ")[:200]
            exec_t = model_info.get(m, {}).get("execution_time", 0)
            failed_rows += f"<tr style=''background:#fde7e9''><td style=''font-family:monospace;color:#d13438;font-weight:bold''>{m}</td><td>{exec_t:.2f}s</td><td style=''font-size:12px;color:#a80000''>{err}</td></tr>"
        failed_html = (
            f"<div class=''sec''><h3>Failed Models ({len(failed_models)})</h3>"
            f"<table><tr><th>Model</th><th>Exec Time</th><th>Error Message</th></tr>"
            f"{failed_rows}</table></div>"
        )

    # Skipped models table
    skipped_html = ""
    if skipped_models:
        skipped_rows = ""
        for m in skipped_models:
            skipped_rows += f"<tr style=''background:#fff4ce''><td style=''font-family:monospace;color:#856404''>{m}</td></tr>"
        skipped_html = (
            f"<div class=''sec''><h3>Skipped Models ({len(skipped_models)})</h3>"
            f"<table><tr><th>Model</th></tr>{skipped_rows}</table></div>"
        )

    # Succeeded grouped by layer then entity
    layer_entities = {}
    for m in succeeded_models:
        layer = "staging" if m.startswith("stg_") or m.startswith("v_stg") else "raw_vault"
        if layer == "raw_vault":
            entity = "Hubs" if "hub" in m else ("Links" if "lnk" in m else "Satellites")
            layer_entities.setdefault(layer, {}).setdefault(entity, []).append(m)
        else:
            layer_entities.setdefault(layer, {}).setdefault("staging", []).append(m)

    succeeded_rows = ""
    for layer in ["raw_vault", "staging"]:
        if layer not in layer_entities:
            continue
        entities = layer_entities[layer]
        first = True
        for entity, models in entities.items():
            if first:
                succeeded_rows += (
                    f"<tr><td rowspan=''{len(entities)}'' style=''vertical-align:middle;text-align:center;font-weight:bold''>"
                    f"{layer}</td><td>{entity}</td><td>{len(models)}</td>"
                    f"<td style=''font-size:12px;color:#555''>{'', ''.join(models)}</td></tr>"
                )
                first = False
            else:
                succeeded_rows += (
                    f"<tr><td>{entity}</td><td>{len(models)}</td>"
                    f"<td style=''font-size:12px;color:#555''>{'', ''.join(models)}</td></tr>"
                )
    succeeded_html = (
        f"<div class=''sec''><h3>Succeeded ({len(succeeded_models)} models)</h3>"
        f"<table><tr><th>Layer</th><th>Entity</th><th>Count</th><th>Models</th></tr>"
        f"{succeeded_rows}</table></div>"
    ) if succeeded_models else ""

    recs = []
    if dbt_execution_failed:
        recs.append(f"<strong>1. Critical:</strong> DBT execution failed completely - {models_marked_failed} models marked as FAILED")
        recs.append(f"<strong>2. Investigate:</strong> Check error message: {dbt_error_message[:200]}")
        recs.append(f"<strong>3. Rerun:</strong> Call procedure with run_mode=''full'' or ''rerun'' or ''manual'' after fixing")
    elif failed_models:
        recs.append(f"<strong>1. Investigate:</strong> Check model SQL and source tables for: {'', ''.join(failed_models)}")
        recs.append(f"<strong>2. Rerun:</strong> Call procedure with run_mode=''rerun'' or ''manual'' to retry failed + downstream")
    else:
        recs.append("No action needed - all models completed successfully")
    recs_html = "".join(f"<li>{r}</li>" for r in recs)

    timeline_items = [
        f"<li><strong>Step 1:</strong> Procedure called with mode=<code>{run_mode}</code>, ARGS=<code>{dbt_args_used}</code></li>"
    ]
    if dbt_execution_failed:
        timeline_items.append(
            f"<li><strong>Step 2:</strong> DBT execution failed - {models_marked_failed} model(s) marked as FAILED</li>"
        )
        timeline_items.append(
            f"<li><strong>Result:</strong> Fix the root cause and retry</li>"
        )
    elif failed_models:
        timeline_items.append(
            f"<li><strong>Step 2:</strong> Run completed - {len(failed_models)} model(s) failed: {'', ''.join(failed_models)}</li>"
        )
        timeline_items.append(
            f"<li><strong>Result:</strong> ! Rerun required</li>"
        )
    else:
        timeline_items.append(f"<li><strong>Step 2:</strong> All {total} models completed successfully</li>")
    timeline_html = "".join(timeline_items)

    return f"""<!DOCTYPE html><html><head><style>
body{{font-family:Calibri,Arial,sans-serif;background:#f5f5f5;padding:20px}}
.c{{max-width:900px;margin:0 auto;background:#fff;border:1px solid #ddd}}
.h{{background:linear-gradient(135deg,#0078d4,#005a9e);color:#fff;padding:25px 30px}}
.h h1{{margin:0 0 8px;font-size:22px}}.h .s{{font-size:16px;opacity:.95}}
.sm{{display:flex;flex-wrap:wrap;border-bottom:1px solid #ddd}}
.cd{{flex:1;min-width:120px;padding:16px;text-align:center;border-right:1px solid #eee}}
.cd .v{{font-size:28px;font-weight:700}}.cd .l{{font-size:11px;color:#666;text-transform:uppercase}}
.ok{{color:#107c10}}.er{{color:#d13438}}.in{{color:#0078d4}}
.ct{{padding:20px 30px}}.sec{{margin-bottom:20px}}
.sec h3{{margin:0 0 10px;color:#333;border-bottom:2px solid #0078d4;padding-bottom:5px}}
table{{width:100%;border-collapse:collapse;font-size:13px;margin-bottom:15px}}
th{{background:#f0f0f0;padding:8px 12px;text-align:left;border:1px solid #ddd}}
td{{padding:8px 12px;border:1px solid #ddd}}
.ft{{background:#0078d4;color:#fff;padding:15px 30px;text-align:center;font-size:12px}}
ul{{margin:5px 0;padding-left:20px}}
</style></head><body><div class="c">
<div class="h"><h1>MAXI RAW - dbt Execution Report</h1>
<div class="s">{overall_status} | Mode: {run_mode} | {report_date}</div></div>
<div class="sm">
<div class="cd"><div class="v in">{total}</div><div class="l">Total</div></div>
<div class="cd"><div class="v ok">{len(succeeded_models)}</div><div class="l">Succeeded</div></div>
<div class="cd"><div class="v er">{len(failed_models)}</div><div class="l">Failed</div></div>
<div class="cd"><div class="v">{len(skipped_models)}</div><div class="l">Skipped</div></div>
<div class="cd"><div class="v">{duration_str}</div><div class="l">Duration</div></div>
</div><div class="ct">
{dbt_failure_alert}
<div class="sec"><h3>Execution Timeline</h3><ul>{timeline_html}</ul></div>
{failed_html}
{skipped_html}
{succeeded_html}
<div class="sec"><h3>Technical Details</h3><ul>
<li>Query ID: <code>{query_id}</code></li>
<li>Cross-validation: <strong>{full_cross_validation.get("status", "N/A")}</strong> - {full_cross_validation.get("detail", "")}</li>
<li>Total Duration: {duration_str}</li></ul></div>
<div class="sec"><h3>Recommended Actions</h3><ul>{recs_html}</ul></div>
</div><div class="ft">Bajaj General Insurance - DPM Team - Automated Report</div>
</div></body></html>"""

# ─── Main Handler ─────────────────────────────────────────────────────────────

def main(session, RUN_MODE=''full'', FAILED_RUN_ID='''', MODEL_NAMES=''''):
    run_mode = RUN_MODE.lower().strip()
    failed_run_id = FAILED_RUN_ID.strip()
    model_names = MODEL_NAMES.strip()

    session.sql(f"USE WAREHOUSE {WAREHOUSE}").collect()
    session.sql(f"USE DATABASE {DBT_DATABASE}").collect()
    session.sql(f"USE SCHEMA {DBT_SCHEMA}").collect()

    # ─── RERUN MODE ───────────────────────────────────────────────────────────
    if run_mode == "rerun":
        target_run_id = failed_run_id or query_latest_run_id(session)
        if not target_run_id:
            return "ERROR: No run_id found for rerun"
        failed_from_checkpoint = query_checkpoint_by_status(session, target_run_id, "FAILED")
        if failed_from_checkpoint:
            dbt_args = build_select_args(failed_from_checkpoint)
        else:
            dbt_args = None
    elif run_mode == "manual":
        # ─── MANUAL MODE ──────────────────────────────────────────────────────
        if not model_names:
            return "ERROR: MODEL_NAMES parameter is required for manual mode"
        models = [m.strip() for m in model_names.split('','') if m.strip()]
        dbt_args = f"run --select {'' ''.join(models)}"
    else:
        # ─── FULL MODE ────────────────────────────────────────────────────────
        dbt_args = "run"

    # ─── Check if execution is needed ─────────────────────────────────────────
    if dbt_args is None:
        return json.dumps({
            "status": "NO_ACTION_REQUIRED",
            "run_mode": run_mode,
            "message": "No failed models found. No execution needed.",
            "total_models": 0,
            "succeeded": 0,
            "failed": 0,
            "skipped": 0
        })

    # ─── Execute dbt Project ──────────────────────────────────────────────────
    run_start = datetime.utcnow().isoformat()
    # run_start_utc = datetime.utcnow()
    # curr_time = run_start_utc + timedelta(hours=5, minutes=30)
    # run_start = curr_time.strftime(''%Y-%m-%d %H:%M:%S.%f'')[:-3]
    start_time = time.time()
    dbt_execution_failed = False
    dbt_error_message = ""

    try:
        execute_sql = f"EXECUTE DBT PROJECT {DBT_PROJECT_FQN} ARGS = ''{dbt_args}''"
        result = session.sql(execute_sql).collect()
    except Exception as e:
        dbt_execution_failed = True
        dbt_error_message = str(e)[:500]
        # Continue execution even if dbt fails

    # Get query ID from the execution
    qid_rows = session.sql("SELECT LAST_QUERY_ID(-1)").collect()
    query_id = qid_rows[0][0] if qid_rows else ""
    execution_time = time.time() - start_time

    # ─── Parse Results ────────────────────────────────────────────────────────
    run_results = get_run_results_from_artifacts(session, query_id)
    if run_results:
        failed_models, succeeded_models, skipped_models, failure_details, model_info = parse_run_results(run_results)
        summary = {
            "pass": len(succeeded_models), "error": len(failed_models),
            "skip": len(skipped_models),
            "total": len(succeeded_models) + len(failed_models) + len(skipped_models),
            "warn": 0
        }
    else:
        failed_models, succeeded_models, skipped_models = [], [], []
        summary, failure_details, model_info = {"total": 0}, {}, {}

    # ─── Get Invocation ID from Checkpoint ────────────────────────────────────
    inv_rows = session.sql(
        f"SELECT DISTINCT run_id FROM {CHECKPOINT_TABLE} "
        f"WHERE run_start_timestamp >= ''{run_start}''::TIMESTAMP_NTZ LIMIT 1"
    ).collect()
    invocation_id = inv_rows[0][0] if inv_rows else ""

    # ─── Handle dbt Execution Failure ─────────────────────────────────────────
    models_marked_failed = 0
    if dbt_execution_failed and invocation_id:
        # Update all RUNNING states to FAILED since post-hooks won''t execute
        error_msg = f"DBT execution failed: {dbt_error_message}"
        models_marked_failed = update_all_running_to_failed(session, invocation_id, error_msg)

    # ─── Cross-Validation ─────────────────────────────────────────────────────
    full_cross_validation = {}
    if invocation_id:
        # Update checkpoint with final statuses (only if dbt didn''t fail completely)
        if not dbt_execution_failed:
            update_checkpoint_after_run(session, failed_models, skipped_models, failure_details, invocation_id)
        
        full_cross_validation = full_cross_validate(session, invocation_id, failed_models, succeeded_models, skipped_models)

    # ─── Retention Cleanup ────────────────────────────────────────────────────
    session.sql(
        f"DELETE FROM {CHECKPOINT_TABLE} WHERE created_at < DATEADD(day, -{RETENTION_DAYS}, CURRENT_TIMESTAMP())"
    ).collect()

    # ─── Send Email Report ────────────────────────────────────────────────────
    if dbt_execution_failed:
        overall_status = "DBT EXECUTION FAILED"
    elif not failed_models:
        overall_status = "SUCCESS"
    else:
        overall_status = "FAILURE"

    report_date = (datetime.utcnow() + timedelta(hours=5, minutes=30)).strftime("%B %d, %Y at %I:%M %p IST")
    validation_status = full_cross_validation.get("status", "N/A")
    html_body = generate_report_html(
        report_date=report_date, run_mode=run_mode, overall_status=overall_status,
        succeeded_models=succeeded_models, failed_models=failed_models, skipped_models=skipped_models,
        execution_time=execution_time, summary=summary, validation_status=validation_status,
        query_id=query_id, dbt_args_used=dbt_args,
        failure_details=failure_details, model_info=model_info, full_cross_validation=full_cross_validation,
        dbt_execution_failed=dbt_execution_failed, dbt_error_message=dbt_error_message,
        models_marked_failed=models_marked_failed
    )
    subject = f"MAXI RAW dbt Run - {overall_status} - {(datetime.utcnow() + timedelta(hours=5, minutes=30)).strftime(''%Y-%m-%d'')}"
    email_status = send_email_report(subject, html_body)

    # ─── Return Summary ───────────────────────────────────────────────────────
    return json.dumps({
        "status": overall_status,
        "run_mode": run_mode,
        "total_models": summary.get("total", 0),
        "succeeded": len(succeeded_models),
        "failed": len(failed_models),
        "skipped": len(skipped_models),
        "execution_time_seconds": round(execution_time, 2),
        "query_id": query_id,
        "invocation_id": invocation_id,
        "validation": validation_status,
        "email": email_status,
        "failed_models": failed_models,
        "dbt_execution_failed": dbt_execution_failed,
        "dbt_error": dbt_error_message if dbt_execution_failed else ""
    })
';