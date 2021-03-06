# +
# Import the following module
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from email.mime.application import MIMEApplication
from email.mime.multipart import MIMEMultipart
import smtplib
import os
  
# send our email message 'msg' to our boss
def send_mail(subject="",
            text="",
            attachment=None,
            reciep1="", reciep2="", reciep3="", reciep4=""):
    # initialize connection to our
    # email server, here using smtp.office365.com
    smtp = smtplib.SMTP('smtp.office365.com', 587)
    smtp.ehlo()
    smtp.starttls()
    
    # Login with your email and password
    smtp.login('rpaautomation@analytix.com', 'Automation@01801')

    msg = MIMEMultipart()
    msg['Subject'] = subject
    msg.attach(MIMEText(text))
    
    if attachment is not None:
        if type(attachment) is not list:
            attachment = [attachment]
  
        for one_attachment in attachment:
            with open(one_attachment, 'rb') as f:
                file = MIMEApplication(
                    f.read(),
                    name=os.path.basename(one_attachment)
                )
            file['Content-Disposition'] = f'attachment;\
            filename="{os.path.basename(one_attachment)}"'
            msg.attach(file)
    
    to = [reciep1,reciep2,reciep3,reciep4]
    
    smtp.sendmail(from_addr="rpaautomation@analytix.com",
              to_addrs=to, msg=msg.as_string())
    
    smtp.quit()
 
#to = ["jibinjoseph0077@gmail.com",'mafna.janeefar@quadance.com']

# Call the message function
#send_mail("Message Generated By Robot", "Hi Team, \n\nPlease find the attached sales validation report. \n\nThank You,\nBot",
              #r"C:\Robocorp\Analytix_SalesValidation\Output\OutputSheet.xlsx","mafna.janeefar@quadance.com","mansi.shah@analytix.com","pratik.gohil@analytix.com","deepu.thompson@quadance.com")



