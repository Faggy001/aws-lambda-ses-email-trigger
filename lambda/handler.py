import os
from datetime import date
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
import boto3

# Create clients
ses = boto3.client("ses")
iam = boto3.client("iam")

# Environment variables
EXPIRY = int(os.getenv("SET_EXPIRY", 90))
EXPIRY_DAY_LIMIT = EXPIRY - 10
KEY_USER = os.getenv("KEY_USER_NAME")
TO_EMAILS = os.getenv("TO_EMAILS", "").split(",")
FROM_EMAIL = os.getenv("FROM_EMAIL")

# Log envs
print("ENV FROM_EMAIL:", FROM_EMAIL)
print("ENV TO_EMAILS:", TO_EMAILS)
print("ENV KEY_USER:", KEY_USER)
print("ENV EXPIRY:", EXPIRY)

# Key details
def get_key_details(username=KEY_USER):
    response = iam.list_access_keys(UserName=username)
    access_keys = response.get("AccessKeyMetadata", [])
    for access in access_keys:
        access["active_days"] = (date.today() - access["CreateDate"].date()).days
    return access_keys

# Send email
def send_email(subject, body, to_emails):
    msg = MIMEMultipart()
    msg["Subject"] = subject
    msg["From"] = FROM_EMAIL
    msg["To"] = ", ".join(to_emails)
    msg.attach(MIMEText(body, "plain"))

    response = ses.send_raw_email(
        Source=msg["From"],
        Destinations=to_emails,
        RawMessage={"Data": msg.as_string()},
    )
    print(f"✅ Email sent! Message ID: {response['MessageId']}")

# Handler
def lambda_handler(event, context):
    print("Lambda invoked")
    keys = get_key_details()
    expired_keys = [k for k in keys if k["active_days"] > EXPIRY_DAY_LIMIT]

    if not expired_keys:
        print("No keys near expiry.")
        return {"statusCode": 200, "body": "No keys near expiry"}

    key_messages = "\n".join([
    f"- Access key for IAM user **{key['UserName']}** is expiring in **{EXPIRY - key['active_days']}** days."
    for key in expired_keys
])

    body = f"""Hi Team,

    {key_messages}

    {'Please remove all expired keys. Only one active key should remain.' if len(expired_keys) > 1 else ''}

    Regards,  
    Automated Lambda Function
    """


    send_email("🔐 IAM Access Key Expiry Notification", body, TO_EMAILS)
    return {"statusCode": 200, "body": "Email sent"}

