import asyncio
import aiosmtplib
import sys

from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

MAIL_PARAMS = {'TLS': True, 'host': 'smtp.gmail.com', 'password': 'cmxmgigksbtjxgzp', 'user': 'gaiercop@gmail.com', 'port': 587}

if sys.platform == 'win32':
    loop = asyncio.get_event_loop()
    if not loop.is_running() and not isinstance(loop, asyncio.ProactorEventLoop):
        loop = asyncio.ProactorEventLoop()
        asyncio.set_event_loop(loop)


async def send_mail_async(sender, to, subject, text, textType='plain', **params):
    cc = params.get("cc", [])
    bcc = params.get("bcc", [])
    mail_params = params.get("mail_params", MAIL_PARAMS)

    msg = MIMEMultipart()
    msg.preamble = subject
    msg['Subject'] = subject
    msg['From'] = sender
    msg['To'] = ', '.join(to)
    if len(cc): msg['Cc'] = ', '.join(cc)
    if len(bcc): msg['Bcc'] = ', '.join(bcc)

    msg.attach(MIMEText(text, textType, 'utf-8'))

    host = mail_params.get('host', 'localhost')
    isSSL = mail_params.get('SSL', False)
    isTLS = mail_params.get('TLS', False)
    port = mail_params.get('port', 465 if isSSL else 25)
    smtp = aiosmtplib.SMTP(hostname=host, port=port, use_tls=isSSL)
    await smtp.connect()
    if isTLS:
        await smtp.starttls()
    if 'user' in mail_params:
        await smtp.login(mail_params['user'], mail_params['password'])
    await smtp.send_message(msg)
    await smtp.quit()


#if __name__ == "__main__":
#    email = "gaiercopcyetgaiercopcyet@gmail.com"
#    co1 = send_mail_async(email,
#              [email],
#              "Test 1",
#              'Test 1 Message',
#              textType="plain")
#    co2 = send_mail_async(email,
#              [email],
#              "Test 2",
#              'Test 2 Message',
#              textType="plain")
#    loop = asyncio.get_event_loop()
#    loop.run_until_complete(asyncio.gather(co1, co2))
#    loop.close()