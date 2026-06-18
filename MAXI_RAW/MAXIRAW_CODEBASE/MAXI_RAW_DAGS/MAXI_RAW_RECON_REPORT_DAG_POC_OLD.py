import json
import logging
import smtplib
from datetime import datetime, timedelta
from typing import List, Dict, Any

import pandas as pd
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

import pytz
from airflow import DAG
from airflow.models import Variable
from airflow.operators.python_operator import PythonOperator
from airflow.operators.trigger_dagrun import TriggerDagRunOperator
from airflow.providers.snowflake.hooks.snowflake import SnowflakeHook

# ---------------------------------------
# Configuration & Constants
# ---------------------------------------
IST = pytz.timezone('Asia/Kolkata')
CONFIG_JSON_PATH = "/opt/airflow/dags/Config/maxiraw_recon_queries.json"
SENDER_EMAIL = "DPM_L1_Team@bajajallianz.co.in"
RECIPIENT_EMAILS = [
    "ashraf.shaik01@bajajgeneral.com", "pratik.kulkarni@bajajgeneral.com", "satish.phirke@bajajgeneral.com"
]

# ---------------------------------------
# DAG Definition
# ---------------------------------------
default_args = {
    "owner": "empower",
    "start_date": datetime(2025, 1, 1),
    "retries": 0,
    "retry_delay": timedelta(seconds=30),
    "provide_context": True,
}

dag = DAG(
    dag_id="MAXI_RAW_RECON_REPORT_DAG",
    default_args=default_args,
    description="Maximus Raw Reconciliation Report",
    schedule_interval=None,
    catchup=False,
    tags=["MAXIRAW", "RECON", "REPORTING"],
)


# ---------------------------------------
# HTML Template Generation
# ---------------------------------------
def generate_html_report(recon_results: List[Dict[str, Any]], report_date: str) -> str:

    # Calculate summary statistics
    total_queries = len(recon_results)
    successful_queries = sum(1 for r in recon_results if r['status'] == 'success')
    failed_queries = total_queries - successful_queries
    total_records = sum(r.get('record_count', 0) for r in recon_results if r['status'] == 'success')
    
    # Generate sections HTML
    sections_html = []
    for idx, result in enumerate(recon_results, 1):
        section_html = generate_section_html(result, idx)
        sections_html.append(section_html)
    
    sections_content = "\n".join(sections_html)
    
    # Main HTML template
    html_template = f"""
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Maximus Raw Reconciliation Report - {report_date}</title>
    <style>
        * {{
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }}
        
        body {{
            font-family: 'Calibri', 'Arial', sans-serif;
            background-color: #f5f5f5;
            padding: 20px;
            line-height: 1.6;
            color: #333333;
        }}
        
        .email-container {{
            max-width: 100%;
            margin: 0 auto;
            background: #ffffff;
            border: 1px solid #d4d4d4;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }}
        
        .header {{
            background: linear-gradient(135deg, #0078d4 0%, #005a9e 100%);
            color: white;
            padding: 30px 40px;
            border-bottom: 3px solid #004578;
        }}
        
        .header h1 {{
            font-size: 28px;
            font-weight: 600;
            margin-bottom: 8px;
        }}
        
        .header .subtitle {{
            font-size: 16px;
            opacity: 0.95;
            font-weight: 400;
            margin-bottom: 12px;
        }}
        
        .header .date {{
            display: inline-block;
            padding: 6px 16px;
            background-color: rgba(255, 255, 255, 0.15);
            border: 1px solid rgba(255, 255, 255, 0.3);
            border-radius: 3px;
            font-size: 18px;
            font-weight: 500;
        }}
        
        .summary-grid {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 0;
            border-bottom: 1px solid #d4d4d4;
        }}
        
        .summary-card {{
            background: #ffffff;
            padding: 24px;
            border-right: 1px solid #d4d4d4;
            border-bottom: 1px solid #d4d4d4;
            text-align: center;
        }}
        
        .summary-card:last-child {{
            border-right: none;
        }}
        
        .summary-icon {{
            font-size: 40px;
            margin-bottom: 12px;
            filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.1));
            width: 70px;
            height: 70px;
            margin: 0 auto 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: linear-gradient(135deg, #e8f4ff 0%, #d4e8ff 100%);
            border-radius: 50%;
            border: 3px solid #0078d4;
            font-weight: 600;
        }}
        
        .summary-card:nth-child(2) .summary-icon {{
            background: linear-gradient(135deg, #e8f8e8 0%, #d4f0d4 100%);
            border-color: #107c10;
            color: #107c10;
        }}
        
        .summary-card:nth-child(3) .summary-icon {{
            background: linear-gradient(135deg, #ffe8e8 0%, #ffd4d4 100%);
            border-color: #d13438;
            color: #d13438;
        }}
        
        .summary-card:nth-child(4) .summary-icon {{
            background: linear-gradient(135deg, #e8f4ff 0%, #d4e8ff 100%);
            border-color: #0078d4;
        }}
        
        .summary-label {{
            font-size: 13px;
            color: #666666;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 8px;
        }}
        
        .summary-value {{
            font-size: 36px;
            font-weight: 700;
            color: #0078d4;
        }}
        
        .summary-value.success {{
            color: #107c10;
        }}
        
        .summary-value.error {{
            color: #d13438;
        }}
        
        .summary-value.info {{
            color: #0078d4;
        }}
        
        .content {{
            padding: 30px 40px;
        }}
        
        .section {{
            margin-bottom: 30px;
            background: #ffffff;
            border: 1px solid #d4d4d4;
        }}
        
        .section-header {{
            background: linear-gradient(135deg, #0078d4 0%, #005a9e 100%);
            border-bottom: none;
            padding: 16px 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }}
        
        .section-header.error {{
            background: linear-gradient(135deg, #e74856 0%, #d13438 100%);
        }}
        
        .section-title {{
            display: flex;
            align-items: center;
            gap: 12px;
        }}
        
        .section-number {{
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 28px;
            height: 28px;
            background-color: rgba(255, 255, 255, 0.25);
            color: white;
            border-radius: 3px;
            font-weight: 700;
            font-size: 14px;
        }}
        
        .section-number.error {{
            background-color: rgba(255, 255, 255, 0.25);
        }}
        
        .section-label {{
            font-size: 16px;
            font-weight: 600;
            color: #ffffff;
        }}
        
        .record-count {{
            background-color: rgba(255, 255, 255, 0.25);
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            color: #ffffff;
        }}
        
        .record-count.error {{
            background-color: rgba(255, 255, 255, 0.25);
            color: #ffffff;
        }}
        
        .table-container {{
            overflow-x: auto;
            padding: 20px;
        }}
        
        table {{
            width: 100%;
            border-collapse: collapse;
            font-size: 13px;
        }}
        
        thead {{
            background-color: #f8f8f8;
        }}
        
        th {{
            padding: 12px 16px;
            text-align: left;
            font-weight: 600;
            color: #333333;
            border: 1px solid #d4d4d4;
            text-transform: uppercase;
            font-size: 12px;
            letter-spacing: 0.3px;
        }}
        
        tbody tr {{
            border-bottom: 1px solid #d4d4d4;
        }}
        
        tbody tr:hover {{
            background-color: #f9f9f9;
        }}
        
        tbody tr:nth-child(even) {{
            background-color: #fafafa;
        }}
        
        td {{
            padding: 12px 16px;
            color: #333333;
            border: 1px solid #d4d4d4;
            vertical-align: top;
        }}
        
        td.number {{
            text-align: right;
            font-weight: 500;
        }}
        
        .showing-message {{
            padding: 12px 20px;
            background-color: #fff4ce;
            border-top: 1px solid #d4d4d4;
            color: #8a6d3b;
            font-size: 13px;
            text-align: center;
            font-weight: 500;
        }}
        
        .showing-message-icon {{
            margin-right: 6px;
        }}
        
        .error-message {{
            padding: 20px;
            background-color: #fde7e9;
            border-left: 4px solid #d13438;
            color: #a80000;
            font-size: 13px;
            line-height: 1.6;
        }}
        
        .error-message strong {{
            display: block;
            margin-bottom: 8px;
            font-size: 14px;
        }}
        
        .empty-state {{
            padding: 50px 20px;
            text-align: center;
            color: #666666;
            background-color: #f9f9f9;
        }}
        
        .empty-state-icon {{
            font-size: 48px;
            margin-bottom: 12px;
            color: #107c10;
        }}
        
        .empty-state-text {{
            font-size: 15px;
            font-weight: 500;
        }}
        
        .footer {{
            background: linear-gradient(135deg, #0078d4 0%, #005a9e 100%);
            border-top: none;
            padding: 25px 40px;
            text-align: center;
            font-size: 13px;
            color: #ffffff;
        }}
        
        .footer p {{
            margin-bottom: 6px;
            line-height: 1.6;
            color: #ffffff;
        }}
        
        .footer strong {{
            color: #ffffff;
            font-size: 14px;
        }}
        
        .footer-divider {{
            height: 1px;
            background-color: rgba(255, 255, 255, 0.3);
            margin: 15px auto;
            max-width: 600px;
        }}
        
        .footer-note {{
            font-size: 12px;
            color: rgba(255, 255, 255, 0.85);
            font-style: italic;
        }}
        
        @media (max-width: 768px) {{
            body {{
                padding: 10px;
            }}
            
            .header {{
                padding: 20px;
            }}
            
            .header h1 {{
                font-size: 24px;
            }}
            
            .summary-grid {{
                grid-template-columns: 1fr;
            }}
            
            .summary-card {{
                border-right: none;
            }}
            
            .content {{
                padding: 20px;
            }}
            
            .table-container {{
                padding: 10px;
            }}
            
            th, td {{
                padding: 10px 12px;
            }}
        }}
    </style>
</head>
<body>
    <div class="email-container">
        <!-- Header -->
        <div class="header">
            <h1>📊 Maximus Raw Reconciliation Report</h1>
            <div class="date">🗓️ Generated on {report_date}</div>
        </div>
        
        <!-- Summary Cards -->
        <div class="summary-grid">
            <div class="summary-card">
                <div class="summary-icon">📋</div>
                <div class="summary-label">Total Queries</div>
                <div class="summary-value">{total_queries}</div>
            </div>
            <div class="summary-card">
                <div class="summary-icon">✓</div>
                <div class="summary-label">Successful</div>
                <div class="summary-value success">{successful_queries}</div>
            </div>
            <div class="summary-card">
                <div class="summary-icon">✗</div>
                <div class="summary-label">Failed</div>
                <div class="summary-value error">{failed_queries}</div>
            </div>
            <div class="summary-card">
                <div class="summary-icon">∑</div>
                <div class="summary-label">Total Records</div>
                <div class="summary-value info">{total_records:,}</div>
            </div>
        </div>
        
        <!-- Main Content -->
        <div class="content">
            {sections_content}
        </div>
        
        <!-- Footer -->
        <div class="footer">
            <p><strong>Bajaj General Insurance</strong></p>
            <div class="footer-divider"></div>
            <p class="footer-note">
                This is an automated report. For queries or issues, please contact the DPM team.
            </p>
        </div>
    </div>
</body>
</html>
"""
    
    return html_template


def generate_section_html(result: Dict[str, Any], section_number: int) -> str:

    label = result['label']
    status = result['status']
    df = result.get('dataframe')
    error = result.get('error')
    issue = result.get('issue')
    total_record_count = result.get('record_count', 0)
    
    if status == 'error':
        return f"""
        <div class="section">
            <div class="section-header error">
                <div class="section-title">
                    <span class="section-number error">{section_number}</span>
                    <span class="section-label">{label}</span>
                </div>
                <span class="record-count error">✗ ERROR</span>
            </div>
            <div class="error-message">
                <strong>⚠ Query Execution Failed:</strong>
                {error}
            </div>
        </div>
        """
    
    if status == 'issue':
        return f"""
        <div class="section">
            <div class="section-header error">
                <div class="section-title">
                    <span class="section-number error">{section_number}</span>
                    <span class="section-label">{label}</span>
                </div>
                <span class="record-count error">! ISSUE</span>
            </div>
            <div class="error-message">
                <strong>⚠ Issue in Data:</strong>
                {issue}
            </div>
        </div>
        """
    
    # Success case
    if total_record_count == 0:
        return f"""
        <div class="section">
            <div class="section-header">
                <div class="section-title">
                    <span class="section-number">{section_number}</span>
                    <span class="section-label">{label}</span>
                </div>
                <span class="record-count">0 records</span>
            </div>
            <div class="empty-state">
                <div class="empty-state-icon">✓</div>
                <div class="empty-state-text">No discrepancies found - All records reconciled successfully!</div>
            </div>
        </div>
        """
    
    # Display top 5 records
    showing_top_5 = total_record_count > 5
    
    # Generate table HTML with proper formatting
    table_html = generate_table_html(df)
    
    # Add message if showing only top 5
    showing_message = ""
    if showing_top_5:
        remaining = total_record_count - 5
        showing_message = f"""
        <div class="showing-message">
            <span class="showing-message-icon">ⓘ</span>
            Showing top 5 records out of {total_record_count:,} total records ({remaining:,} more records not displayed)
        </div>
        """
    
    return f"""
    <div class="section">
        <div class="section-header">
            <div class="section-title">
                <span class="section-number">{section_number}</span>
                <span class="section-label">{label}</span>
            </div>
            <span class="record-count">{total_record_count:,} records</span>
        </div>
        <div class="table-container">
            {table_html}
        </div>
        {showing_message}
    </div>
    """


def generate_table_html(df: pd.DataFrame) -> str:

    if df.empty:
        return '<div class="empty-state"><div class="empty-state-icon">📭</div><div class="empty-state-text">No data available</div></div>'
    
    # Start table
    html_parts = ['<table>']
    
    # Table header
    html_parts.append('<thead><tr>')
    for col in df.columns:
        html_parts.append(f'<th>{col}</th>')
    html_parts.append('</tr></thead>')
    
    # Table body
    html_parts.append('<tbody>')
    for _, row in df.iterrows():
        html_parts.append('<tr>')
        for col in df.columns:
            value = row[col]
            
            # Check if value is numeric for right alignment
            is_numeric = pd.api.types.is_numeric_dtype(type(value)) or isinstance(value, (int, float))
            
            # Format the value
            if pd.isna(value):
                formatted_value = '<em style="color: #999999;">NULL</em>'
                cell_class = ''
            elif is_numeric:
                if isinstance(value, float):
                    formatted_value = f'{value:,.2f}'
                else:
                    formatted_value = f'{value:,}'
                cell_class = ' class="number"'
            else:
                formatted_value = str(value)
                cell_class = ''
            
            html_parts.append(f'<td{cell_class}>{formatted_value}</td>')
        html_parts.append('</tr>')
    html_parts.append('</tbody>')
    
    html_parts.append('</table>')
    
    return ''.join(html_parts)


# ---------------------------------------
# Email Functions
# ---------------------------------------
def send_email(subject: str, body_html: str, recipients: List[str] = None):

    if recipients is None:
        recipients = RECIPIENT_EMAILS
    
    try:
        # Get SMTP settings from Airflow Variables
        smtp_settings_json = Variable.get("smtp_settings_password")
        smtp_settings = json.loads(smtp_settings_json)
        
        smtp_host = smtp_settings.get("smtp_host")
        smtp_port = int(smtp_settings.get("smtp_port"))
        smtp_user = smtp_settings.get("smtp_user")
        smtp_password = smtp_settings.get("smtp_password")
        
        # Create message
        msg = MIMEMultipart('alternative')
        msg["From"] = SENDER_EMAIL
        msg["To"] = ", ".join(recipients)
        msg["Subject"] = subject
        
        # Attach HTML content
        html_part = MIMEText(body_html, "html", "utf-8")
        msg.attach(html_part)
        
        # Send email
        with smtplib.SMTP(smtp_host, smtp_port) as server:
            server.starttls()
            server.login(smtp_user, smtp_password)
            server.send_message(msg)
        
        logging.info(f"✓ Email sent successfully: {subject}")
        logging.info(f"  Recipients: {len(recipients)} addresses")
        
    except Exception as e:
        logging.error(f"✗ Failed to send email: {e}")
        raise


# ---------------------------------------
# Main Reconciliation Task
# ---------------------------------------
def run_reconciliation_report(**kwargs):
    """
    Executes reconciliation queries and generates beautiful HTML report.
    OPTIMIZED: Fetches count first, then only top 5 records.
    """
    logging.info("=" * 80)
    logging.info("Starting Premium Reconciliation Report Generation (Optimized)")
    logging.info("=" * 80)
    
    # Load configuration
    try:
        with open(CONFIG_JSON_PATH, 'r') as f:
            recon_queries = json.load(f)
        logging.info(f"✓ Loaded {len(recon_queries)} reconciliation queries from config")
    except Exception as e:
        logging.error(f"✗ Failed to load config file: {e}")
        raise
    
    # Initialize Snowflake connection
    try:
        hook = SnowflakeHook(snowflake_conn_id="SNOWFLAKE_USECASES_PROD")
        logging.info("✓ Connected to Snowflake")
    except Exception as e:
        logging.error(f"✗ Failed to connect to Snowflake: {e}")
        raise
    
    # Execute queries and collect results
    recon_results = []
    
    for idx, query_config in enumerate(recon_queries, 1):
        label = query_config.get("label", f"Query_{idx}")
        sql = query_config.get("sql", "")
        issue = query_config.get("issue", "")
        
        logging.info(f"\n[{idx}/{len(recon_queries)}] Executing: {label}")
        logging.info("-" * 60)
        
        if not sql:
            logging.warning(f"  ⚠ Empty SQL query for {label}, skipping...")
            recon_results.append({
                'label': label,
                'status': 'error',
                'error': 'Empty SQL query provided',
                'dataframe': pd.DataFrame(),
                'record_count': 0
            })
            continue

        if issue:
            logging.warning(f"  ⚠ issue for {label}, skipping...")
            recon_results.append({
                'label': label,
                'status': 'issue',
                'issue': issue,
                'dataframe': pd.DataFrame()
            })
            continue
        
        try:
            # OPTIMIZATION 1: First get the count
            count_sql = f"SELECT COUNT(*) as TOTAL_COUNT FROM ({sql})"
            logging.info(f"  → Fetching count...")
            
            count_df = hook.get_pandas_df(count_sql)
            record_count = int(count_df['TOTAL_COUNT'].iloc[0])
            
            logging.info(f"  ✓ Total records found: {record_count:,}")
            
            # OPTIMIZATION 2: Only fetch top 5 records if count > 0
            if record_count > 0:
                limited_sql = f"SELECT * FROM ({sql}) LIMIT 5"
                logging.info(f"  → Fetching top 5 records...")
                df = hook.get_pandas_df(limited_sql)
                logging.info(f"  ✓ Retrieved {len(df)} sample records")
            else:
                df = pd.DataFrame()
                logging.info(f"  ✓ No records to fetch")
            
            recon_results.append({
                'label': label,
                'status': 'success',
                'dataframe': df,
                'record_count': record_count
            })
            
        except Exception as e:
            error_msg = str(e)
            logging.error(f"  ✗ Query failed: {error_msg}")
            
            recon_results.append({
                'label': label,
                'status': 'error',
                'error': error_msg,
                'dataframe': pd.DataFrame(),
                'record_count': 0
            })
    
    # Generate report date
    report_date = datetime.now(IST).strftime('%B %d, %Y at %I:%M %p IST')
    
    # Generate HTML report
    logging.info("\n" + "=" * 80)
    logging.info("Generating HTML Report")
    logging.info("=" * 80)
    
    html_body = generate_html_report(recon_results, report_date)
    
    # Send email
    email_subject = f"📊 Maximus Raw Reconciliation Report - {datetime.now(IST).strftime('%Y-%m-%d')}"
    
    logging.info(f"\nSending email: {email_subject}")
    send_email(email_subject, html_body)
    
    # Summary
    successful = sum(1 for r in recon_results if r['status'] == 'success')
    failed = len(recon_results) - successful
    total_records = sum(r.get('record_count', 0) for r in recon_results if r['status'] == 'success')
    
    logging.info("\n" + "=" * 80)
    logging.info("RECONCILIATION REPORT SUMMARY")
    logging.info("=" * 80)
    logging.info(f"Total Queries:      {len(recon_results)}")
    logging.info(f"Successful:         {successful}")
    logging.info(f"Failed:             {failed}")
    logging.info(f"Total Records:      {total_records:,}")
    logging.info("=" * 80)
    logging.info("✓ Report generation completed successfully!")
    logging.info("=" * 80 + "\n")


# ---------------------------------------
# DAG Tasks
# ---------------------------------------
run_recon_task = PythonOperator(
    task_id="run_reconciliation_report",
    python_callable=run_reconciliation_report,
    dag=dag,
)


run_recon_task