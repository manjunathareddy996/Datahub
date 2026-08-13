CREATE OR REPLACE PROCEDURE BAGIC_PREPROD_CURATED_DB.UTILS.MAXI_RAW_DBT_ORCHESTRATOR_SP2("RUN_MODE" VARCHAR DEFAULT 'full', "FAILED_RUN_ID" VARCHAR DEFAULT '', "MODEL_NAMES" VARCHAR DEFAULT '', "DBT_TARGET" VARCHAR DEFAULT 'dev')
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
import socket
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
WAREHOUSE = "BAGIC_DPM_MAXI_RAW_WH"
RETENTION_DAYS = 30
SENDER_EMAIL = "DPM_L1_Team@bajajallianz.co.in"
RECIPIENT_EMAILS = ["ashraf.shaik01@bajajgeneral.com"]

# ─── Email ─────────────────────────────────────────────────────────────────────
def send_email_report(subject, body_html):
    try:
        creds = json.loads(_snowflake.get_generic_secret_string(''creds''))
        if not all(k in creds for k in [''host'', ''port'', ''user'', ''password'']):
            return "Email failed: Missing required credentials in secret"
        
        msg = MIMEMultipart("alternative")
        msg["From"] = SENDER_EMAIL
        msg["To"] = ", ".join(RECIPIENT_EMAILS)
        msg["Subject"] = subject
        msg.attach(MIMEText(body_html, "html", "utf-8"))
        
        with smtplib.SMTP(creds[''host''], int(creds[''port'']), timeout=60) as server:
            server.starttls()
            server.login(creds[''user''], creds[''password''])
            server.send_message(msg)
        return f"Email sent successfully to {len(RECIPIENT_EMAILS)} recipients"
    except Exception as e:
        return f"Email failed: {type(e).__name__} - {str(e)}"

# ─── Error Handler with Email ──────────────────────────────────────────────────
def generate_error_email_html(error_type, error_message, run_mode, params):
    """Generate HTML for parameter validation errors"""
    report_date = (datetime.utcnow() + timedelta(hours=5, minutes=30)).strftime("%B %d, %Y at %I:%M %p IST")
    
    # Build parameter display
    param_rows = ""
    for key, value in params.items():
        display_val = value if value else "(empty)"
        param_rows += f"<tr><td style=''padding:8px;border:1px solid #ddd;font-weight:bold''>{key}</td><td style=''padding:8px;border:1px solid #ddd''>{display_val}</td></tr>"
    
    # Context-specific guidance
    guidance = ""
    if "MODEL_NAMES" in error_message and run_mode == "manual":
        guidance = """
        <li>Provide a comma-separated list of model names in the MODEL_NAMES parameter</li>
        <li>Example: <code>CALL MAXI_RAW_DBT_ORCHESTRATOR_SP2(''manual'', '''', ''model1,model2,model3'', ''dev'')</code></li>
        """
    elif "run_id" in error_message.lower() and run_mode == "rerun":
        guidance = """
        <li>Ensure at least one dbt execution has completed successfully to populate the checkpoint table</li>
        <li>Or provide a specific FAILED_RUN_ID from a previous execution</li>
        <li>Example: <code>CALL MAXI_RAW_DBT_ORCHESTRATOR_SP2(''rerun'', ''abc-123-def-456'', '''', ''dev'')</code></li>
        """
    elif "failed models" in error_message.lower():
        guidance = """
        <li>All models in the specified run succeeded or no failed models found for that run_id</li>
        <li>Use <code>run_mode=''full''</code> to run all models again</li>
        <li>Or use <code>run_mode=''manual''</code> to run specific models</li>
        """
    else:
        guidance = """
        <li>Review the error message above for specific guidance</li>
        <li>Check parameter values and retry with correct parameters</li>
        <li>Contact L2 team if issue persists</li>
        """
    
    return f"""<!DOCTYPE html>
<html>
<head>
<style>
body{{font-family:Calibri,Arial,sans-serif;background:#f5f5f5;padding:20px}}
.c{{max-width:800px;margin:0 auto;background:#fff;border:1px solid #ddd;border-radius:8px;overflow:hidden}}
.h{{background:linear-gradient(135deg,#d13438,#a00000);color:#fff;padding:25px 30px}}
.h h1{{margin:0 0 8px;font-size:22px}}
.h .s{{font-size:14px;opacity:.95}}
.ct{{padding:20px 30px}}
.alert{{background:#fde7e9;border:2px solid #d13438;padding:20px;border-radius:4px;margin-bottom:20px}}
.alert h3{{color:#d13438;margin:0 0 10px}}
.alert p{{font-size:14px;color:#333;margin:5px 0}}
.sec{{margin-bottom:20px}}
.sec h3{{margin:0 0 10px;color:#333;border-bottom:2px solid #d13438;padding-bottom:5px}}
table{{width:100%;border-collapse:collapse;margin:10px 0}}
th,td{{padding:8px 12px;text-align:left;border:1px solid #ddd}}
th{{background:#f0f0f0}}
code{{background:#f5f5f5;padding:2px 6px;border-radius:3px;font-family:monospace;font-size:12px}}
ul{{margin:5px 0;padding-left:20px}}
.ft{{background:#d13438;color:#fff;padding:15px 30px;text-align:center;font-size:12px}}
</style>
</head>
<body>
<div class="c">
    <div class="h">
        <h1>⚠ MAXI RAW - Parameter Validation Error</h1>
        <div class="s">Error | Mode: {run_mode} | {report_date}</div>
    </div>
    <div class="ct">
        <div class="alert">
            <h3>{error_type}</h3>
            <p>{error_message}</p>
        </div>
        <div class="sec">
            <h3>Provided Parameters</h3>
            <table>
                <tr><th>Parameter</th><th>Value</th></tr>
                {param_rows}
            </table>
        </div>
        <div class="sec">
            <h3>How to Fix</h3>
            <ul>{guidance}</ul>
        </div>
        <div class="sec">
            <h3>Available Run Modes</h3>
            <ul>
                <li><strong>full</strong> - Run all models in the project</li>
                <li><strong>retry</strong> - Use dbt retry command (runs failed models from last execution)</li>
                <li><strong>rerun</strong> - Query checkpoint table and rerun failed models + downstream</li>
                <li><strong>manual</strong> - Run specific models (requires MODEL_NAMES parameter)</li>
            </ul>
        </div>
    </div>
    <div class="ft">Bajaj General Insurance - DPM Team - Automated Report</div>
</div>
</body>
</html>"""

def return_error_with_email(run_mode, error_type, error_message, params):
    """Centralized error handler with email notification"""
    html_body = generate_error_email_html(error_type, error_message, run_mode, params)
    subject = f"MAXI RAW dbt Run - PARAMETER ERROR - {(datetime.utcnow() + timedelta(hours=5, minutes=30)).strftime(''%Y-%m-%d'')}"
    email_status = send_email_report(subject, html_body)
    
    return json.dumps({
        "status": "ERROR",
        "error_type": error_type,
        "message": error_message,
        "run_mode": run_mode,
        "params": params,
        "email": email_status,
        "total_models": 0,
        "succeeded": 0,
        "failed": 0,
        "skipped": 0,
        "execution_time_seconds": 0,
        "query_id": "",
        "invocation_id": ""
    })

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
        row = session.sql("SELECT $1 FROM @MAXI_RAW_TMP_ARTIFACTS/run_results.json (FILE_FORMAT => ''BAGIC_PREPROD_CURATED_DB.UTILS.JSON_FORMAT'')").collect()
        
        if not row or not row[0][0]:
            return None
        data = row[0][0]
        return json.loads(data) if isinstance(data, str) else data
    except Exception as e:
        return None

def parse_run_results(run_results, invocation_id):
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
            "execution_time": exec_time,
            "status": status,
            "completed_at": completed_at,
            "unique_id": unique_id,
            "run_id": invocation_id  # Add run_id for tracking
        }
        
        if status == "error":
            failed.append(model_name)
            failure_details[model_name] = message if message else "Unknown error"
        elif status in ("success", "pass"):
            succeeded.append(model_name)
        elif status == "skipped":
            skipped.append(model_name)
    
    return sorted(failed), sorted(succeeded), sorted(skipped), failure_details, model_info

# ─── Rerun Strategy ───────────────────────────────────────────────────────────
def build_select_args(failed_models):
    if not failed_models:
        return None
    return f"run --select {'' ''.join(f''{m}+'' for m in failed_models)}"

# ─── Snowflake Helpers ────────────────────────────────────────────────────────
def query_checkpoint_by_status(session, run_id, status):
    rows = session.sql(
        f"SELECT DISTINCT model_name FROM {CHECKPOINT_TABLE} "
        f"WHERE run_id = ''{run_id}'' AND status = ''{status}''"
    ).collect()
    return [row[0] for row in rows]

def query_latest_run_id(session):
    rows = session.sql(
        f"SELECT run_id FROM {CHECKPOINT_TABLE} "
        f"ORDER BY run_start_timestamp DESC LIMIT 1"
    ).collect()
    return rows[0][0] if rows else None

def update_checkpoint_after_run(session, failed_models, skipped_models, failure_details, run_id):
    for model in failed_models:
        error_msg = failure_details.get(model, "Unknown error").replace("''", "''''")[:4000]
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
    error_msg = error_message.replace("''", "''''")[:4000]
    session.sql(
        f"UPDATE {CHECKPOINT_TABLE} SET status = ''FAILED'', error_message = ''{error_msg}'' "
        f"WHERE run_id = ''{run_id}'' AND status = ''RUNNING''"
    ).collect()
    
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
        return {
            "status": "FULL MATCH",
            "detail": f"Checkpoint matches run_results.json ({len(rr_succeeded)} SUCCESS, {len(rr_failed)} FAILED, {len(rr_skipped)} SKIPPED)"
        }
    return {"status": "MISMATCH", "detail": " | ".join(issues)}

# ─── HTML Report Generator ────────────────────────────────────────────────────
def generate_report_html(report_date, run_mode, overall_status, succeeded_models,
                         failed_models, skipped_models, execution_time, summary,
                         validation_status, query_id, dbt_args_used,
                         failure_details, model_info, full_cross_validation,
                         dbt_execution_failed=False, dbt_error_message="", models_marked_failed=0,
                         dbt_target="dev"):
    total = summary.get("total", len(succeeded_models) + len(failed_models) + len(skipped_models))
    duration_str = f"{int(execution_time // 60)}m {int(execution_time % 60)}s"
    
    # DBT Execution Failure Alert
    dbt_failure_alert = ""
    if dbt_execution_failed:
        error_html = dbt_error_message.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\\n", "<br>").replace("\\t", "&nbsp;&nbsp;&nbsp;&nbsp;")
        dbt_failure_alert = (
            f"<div style=''background:#fde7e9;border:2px solid #d13438;padding:15px;margin-bottom:20px;border-radius:4px''>"
            f"<h3 style=''color:#d13438;margin:0 0 10px''>⚠ DBT Execution Failed</h3>"
            f"<p style=''margin:5px 0''><strong>Models Marked as Failed:</strong> {models_marked_failed} (all RUNNING states updated to FAILED)</p>"
            f"<p style=''margin:5px 0;font-size:12px;color:#666''>Post-hooks did not execute. All models in RUNNING state have been marked as FAILED.</p>"
            f"<div style=''margin-top:10px;background:#fff;padding:10px;border-radius:4px;max-height:400px;overflow-y:auto''>"
            f"<strong>Complete Error Message:</strong><br>"
            f"<pre style=''white-space:pre-wrap;word-wrap:break-word;font-family:monospace;font-size:11px;color:#333;margin:5px 0''>{error_html}</pre>"
            f"</div></div>"
        )
    
    # Failed models table with run_id column
    failed_html = ""
    if failed_models:
        failed_rows = ""
        for m in failed_models:
            err = failure_details.get(m, "Unknown error")
            err_display = err.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\\n", "<br>")
            exec_t = model_info.get(m, {}).get("execution_time", 0)
            run_id = model_info.get(m, {}).get("run_id", "N/A")
            
            failed_rows += (
                f"<tr style=''background:#fde7e9''>"
                f"<td style=''font-family:monospace;color:#d13438;font-weight:bold''>{m}</td>"
                f"<td style=''font-family:monospace;font-size:9px;color:#666;word-wrap:break-word''>{run_id}</td>"
                f"<td>{exec_t:.2f}s</td>"
                f"<td style=''font-size:11px;color:#a80000;max-width:600px;word-wrap:break-word''>{err_display}</td>"
                f"</tr>"
            )
        
        failed_html = (
            f"<div class=''sec''><h3>Failed Models ({len(failed_models)})</h3>"
            f"<table><tr><th>Model</th><th>Run ID</th><th>Exec Time</th><th>Error Message (Full)</th></tr>"
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
    
    # Recommendations
    recs = []
    if dbt_execution_failed:
        recs.append(f"<strong>1. Critical:</strong> DBT execution failed completely - {models_marked_failed} models marked as FAILED")
        recs.append(f"<strong>2. Investigate:</strong> Check complete error message in the failure alert box above")
        recs.append(f"<strong>3. Rerun:</strong> Call procedure with run_mode=''retry'' or ''rerun'' or ''manual'' after fixing")
    elif failed_models:
        recs.append(f"<strong>1. Investigate:</strong> Check model SQL and source tables for: {'', ''.join(failed_models)}")
        recs.append(f"<strong>2. Rerun:</strong> Call procedure with run_mode=''retry'' or ''rerun'' or ''manual'' to retry failed + downstream")
    else:
        recs.append("No action needed - all models completed successfully")
    recs_html = "".join(f"<li>{r}</li>" for r in recs)
    
    # Timeline
    timeline_items = [f"<li><strong>Step 1:</strong> Procedure called with mode=<code>{run_mode}</code>, ARGS=<code>{dbt_args_used} --target {dbt_target}</code></li>"]
    if dbt_execution_failed:
        timeline_items.append(f"<li><strong>Step 2:</strong> DBT execution failed - {models_marked_failed} model(s) marked as FAILED</li>")
        timeline_items.append(f"<li><strong>Result:</strong> Fix the root cause and retry</li>")
    elif failed_models:
        timeline_items.append(f"<li><strong>Step 2:</strong> Run completed - {len(failed_models)} model(s) failed: {'', ''.join(failed_models)}</li>")
        timeline_items.append(f"<li><strong>Result:</strong> ! Rerun required</li>")
    else:
        timeline_items.append(f"<li><strong>Step 2:</strong> All {total} models completed successfully</li>")
    timeline_html = "".join(timeline_items)
    
    return f"""<!DOCTYPE html><html><head><style>body{{font-family:Calibri,Arial,sans-serif;background:#f5f5f5;padding:20px}}.c{{max-width:900px;margin:0 auto;background:#fff;border:1px solid #ddd}}.h{{background:linear-gradient(135deg,#0078d4,#005a9e);color:#fff;padding:25px 30px}}.h h1{{margin:0 0 8px;font-size:22px}}.h .s{{font-size:16px;opacity:.95}}.sm{{display:flex;flex-wrap:wrap;border-bottom:1px solid #ddd}}.cd{{flex:1;min-width:120px;padding:16px;text-align:center;border-right:1px solid #eee}}.cd .v{{font-size:28px;font-weight:700}}.cd .l{{font-size:11px;color:#666;text-transform:uppercase}}.ok{{color:#107c10}}.er{{color:#d13438}}.in{{color:#0078d4}}.ct{{padding:20px 30px}}.sec{{margin-bottom:20px}}.sec h3{{margin:0 0 10px;color:#333;border-bottom:2px solid #0078d4;padding-bottom:5px}}table{{width:100%;border-collapse:collapse;font-size:13px;margin-bottom:15px}}th{{background:#f0f0f0;padding:8px 12px;text-align:left;border:1px solid #ddd}}td{{padding:8px 12px;border:1px solid #ddd}}.ft{{background:#0078d4;color:#fff;padding:15px 30px;text-align:center;font-size:12px}}ul{{margin:5px 0;padding-left:20px}}</style></head><body><div class="c"><div class="h"><h1>MAXI RAW - dbt Execution Report</h1><div class="s">{overall_status} | Mode: {run_mode} | {report_date}</div></div><div class="sm"><div class="cd"><div class="v in">{total}</div><div class="l">Total</div></div><div class="cd"><div class="v ok">{len(succeeded_models)}</div><div class="l">Succeeded</div></div><div class="cd"><div class="v er">{len(failed_models)}</div><div class="l">Failed</div></div><div class="cd"><div class="v">{len(skipped_models)}</div><div class="l">Skipped</div></div><div class="cd"><div class="v">{duration_str}</div><div class="l">Duration</div></div></div><div class="ct">{dbt_failure_alert}<div class="sec"><h3>Execution Timeline</h3><ul>{timeline_html}</ul></div>{failed_html}{skipped_html}{succeeded_html}<div class="sec"><h3>Technical Details</h3><ul><li>Query ID: <code>{query_id}</code></li><li>Cross-validation: <strong>{full_cross_validation.get("status", "N/A")}</strong> - {full_cross_validation.get("detail", "")}</li><li>Total Duration: {duration_str}</li></ul></div><div class="sec"><h3>Recommended Actions</h3><ul>{recs_html}</ul></div></div><div class="ft">Bajaj General Insurance - DPM Team - Automated Report</div></div></body></html>"""

# ─── Main Handler ─────────────────────────────────────────────────────────────
def main(session, RUN_MODE=''full'', FAILED_RUN_ID='''', MODEL_NAMES='''', DBT_TARGET=''dev''):
    run_mode = RUN_MODE.lower().strip()
    failed_run_id = FAILED_RUN_ID.strip()
    model_names = MODEL_NAMES.strip()
    dbt_target = DBT_TARGET.strip() if DBT_TARGET else ''dev''
    
    session.sql(f"USE WAREHOUSE {WAREHOUSE}").collect()
    session.sql(f"USE DATABASE {DBT_DATABASE}").collect()
    session.sql(f"USE SCHEMA {DBT_SCHEMA}").collect()
    
    # ─── Validate Run Mode ─────────────────────────────────────────────────
    valid_modes = [''full'', ''retry'', ''rerun'', ''manual'']
    if run_mode not in valid_modes:
        valid_modes_str = ", ".join(valid_modes)
        return return_error_with_email(
            run_mode=run_mode,
            error_type="Invalid Run Mode",
            error_message=f"Run mode ''{run_mode}'' is not valid. Must be one of: {valid_modes_str}",
            params={
                "run_mode": run_mode,
                "failed_run_id": failed_run_id,
                "model_names": model_names,
                "dbt_target": dbt_target
            }
        )
    
    # ─── RETRY MODE (dbt retry command) ───────────────────────────────────
    if run_mode == "retry":
        dbt_args = "retry"
    
    # ─── RERUN MODE ───────────────────────────────────────────────────────
    elif run_mode == "rerun":
        target_run_id = failed_run_id or query_latest_run_id(session)
        
        if not target_run_id:
            return return_error_with_email(
                run_mode="rerun",
                error_type="No Run ID Found",
                error_message="Could not find any previous run_id in checkpoint table. No dbt executions have been logged yet.",
                params={
                    "run_mode": run_mode,
                    "failed_run_id": failed_run_id,
                    "model_names": model_names,
                    "dbt_target": dbt_target
                }
            )
        
        failed_from_checkpoint = query_checkpoint_by_status(session, target_run_id, "FAILED")
        dbt_args = build_select_args(failed_from_checkpoint)
        
        if dbt_args is None:
            return return_error_with_email(
                run_mode="rerun",
                error_type="No Failed Models Found",
                error_message=f"No failed models found for id ''{target_run_id}''. All models in that run succeeded or were skipped.",
                params={
                    "run_mode": run_mode,
                    "failed_run_id": target_run_id,
                    "model_names": model_names,
                    "dbt_target": dbt_target
                }
            )
    
    # ─── MANUAL MODE ──────────────────────────────────────────────────────
    elif run_mode == "manual":
        if not model_names:
            return return_error_with_email(
                run_mode="manual",
                error_type="Missing Required Parameter",
                error_message="MODEL_NAMES parameter is required for manual mode but was not provided.",
                params={
                    "run_mode": run_mode,
                    "failed_run_id": failed_run_id,
                    "model_names": model_names,
                    "dbt_target": dbt_target
                }
            )
        
        models = [m.strip() for m in model_names.split('','') if m.strip()]
        if not models:
            return return_error_with_email(
                run_mode="manual",
                error_type="Invalid Parameter Value",
                error_message="MODEL_NAMES contains only whitespace or empty values after parsing.",
                params={
                    "run_mode": run_mode,
                    "failed_run_id": failed_run_id,
                    "model_names": model_names,
                    "dbt_target": dbt_target
                }
            )
        
        dbt_args = f"run --select {'' ''.join(models)}"
    
    # ─── FULL MODE ────────────────────────────────────────────────────────
    else:
        dbt_args = "run"
    
    # ─── Execute dbt Project ──────────────────────────────────────────────
    run_start = datetime.utcnow().isoformat()
    start_time = time.time()
    dbt_execution_failed = False
    dbt_error_message = ""
    
    try:
        execute_sql = f"EXECUTE DBT PROJECT {DBT_PROJECT_FQN} ARGS = ''{dbt_args} --target {dbt_target}''"
        result = session.sql(execute_sql).collect()
    except Exception as e:
        dbt_execution_failed = True
        dbt_error_message = str(e)
    
    # Get query ID from the execution
    qid_rows = session.sql("SELECT LAST_QUERY_ID(-1)").collect()
    query_id = qid_rows[0][0] if qid_rows else ""
    execution_time = time.time() - start_time
    
    # ─── Parse Results ────────────────────────────────────────────────────
    run_results = get_run_results_from_artifacts(session, query_id)
    
    # Get invocation ID from checkpoint before parsing
    inv_rows = session.sql(
        f"SELECT DISTINCT run_id FROM {CHECKPOINT_TABLE} "
        f"WHERE run_start_timestamp >= ''{run_start}''::TIMESTAMP_NTZ LIMIT 1"
    ).collect()
    invocation_id = inv_rows[0][0] if inv_rows else ""
    
    if run_results:
        failed_models, succeeded_models, skipped_models, failure_details, model_info = parse_run_results(run_results, invocation_id)
        summary = {
            "pass": len(succeeded_models),
            "error": len(failed_models),
            "skip": len(skipped_models),
            "total": len(succeeded_models) + len(failed_models) + len(skipped_models),
            "warn": 0
        }
    else:
        failed_models, succeeded_models, skipped_models = [], [], []
        summary, failure_details, model_info = {"total": 0}, {}, {}
    
    # ─── Handle dbt Execution Failure ─────────────────────────────────────
    models_marked_failed = 0
    if dbt_execution_failed and invocation_id:
        error_msg = f"DBT execution failed: {dbt_error_message}"
        models_marked_failed = update_all_running_to_failed(session, invocation_id, error_msg)
    
    # ─── Cross-Validation ─────────────────────────────────────────────────
    full_cross_validation = {}
    if invocation_id:
        if not dbt_execution_failed:
            update_checkpoint_after_run(session, failed_models, skipped_models, failure_details, invocation_id)
        full_cross_validation = full_cross_validate(session, invocation_id, failed_models, succeeded_models, skipped_models)
    
    # ─── Retention Cleanup ────────────────────────────────────────────────
    session.sql(
        f"DELETE FROM {CHECKPOINT_TABLE} "
        f"WHERE created_at < DATEADD(day, -{RETENTION_DAYS}, CURRENT_TIMESTAMP())"
    ).collect()
    
    # ─── Send Email Report ────────────────────────────────────────────────
    if dbt_execution_failed:
        overall_status = "DBT EXECUTION FAILED"
    elif not failed_models:
        overall_status = "SUCCESS"
    else:
        overall_status = "FAILURE"
    
    report_date = (datetime.utcnow() + timedelta(hours=5, minutes=30)).strftime("%B %d, %Y at %I:%M %p IST")
    validation_status = full_cross_validation.get("status", "N/A")
    
    html_body = generate_report_html(
        report_date=report_date,
        run_mode=run_mode,
        overall_status=overall_status,
        succeeded_models=succeeded_models,
        failed_models=failed_models,
        skipped_models=skipped_models,
        execution_time=execution_time,
        summary=summary,
        validation_status=validation_status,
        query_id=query_id,
        dbt_args_used=dbt_args,
        failure_details=failure_details,
        model_info=model_info,
        full_cross_validation=full_cross_validation,
        dbt_execution_failed=dbt_execution_failed,
        dbt_error_message=dbt_error_message,
        models_marked_failed=models_marked_failed,
        dbt_target=dbt_target
    )
    
    subject = f"MAXI RAW dbt Run - {overall_status} - {(datetime.utcnow() + timedelta(hours=5, minutes=30)).strftime(''%Y-%m-%d'')}"
    email_status = send_email_report(subject, html_body)
    
    # ─── Return Summary ───────────────────────────────────────────────────
    return json.dumps({
        "status": overall_status,
        "run_mode": run_mode,
        "dbt_target": dbt_target,
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