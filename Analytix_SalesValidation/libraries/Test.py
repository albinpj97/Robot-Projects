import smtplib, ssl
from datetime import date, timedelta, datetime as dt
import pandas as pd
from pandas import *

# port = 587  # For starttls
# smtp_server = "smtp.office365.com"
# sender_email = "rpaautomation@analytix.com"
# # receiver_email = "haritha.hari@quadance.com,mafna.janeefar@quadance.com,surya.suresh@quadance.com"
# receiver_email = "mafna.janeefar@quadance.com",""
# message = """\
# Subject: Hi there

# This message is sent from Python."""

# context = ssl.create_default_context()
# with smtplib.SMTP(smtp_server, port) as server:
#     server.ehlo()  # Can be omitted
#     server.starttls(context=context)
#     server.ehlo()  # Can be omitted
#     server.login(sender_email, "Automation@01801")
#     server.sendmail(sender_email, receiver_email, message)


# Function to convert string to datetime
# def convert():
#     date_time = 'Dec 4 2018'
#     format = '%b %d %Y'  # The format
#     datetime_str = dt.datetime.strptime(date_time, format)
#     print(datetime_str)
# # Driver code




# def date_diff(FromDate, ToDate):
#     #year="2022"
#     #FromDate= "May 31 - Jun 27"
#     splitted_date = FromDate.split("-")
    
#     #May 31
#     from_date= splitted_date[0]
#     to_date= splitted_date[1]

#     #May 31 2022
#     from_date_time = from_date+" "+year
#     to_date_time = to_date+" "+year

#     #avoiding leading and trailing spaces
#     from_date_time=from_date_time.strip()
#     to_date_time=to_date_time.strip()

#     #%m/%d/%Y
#     #2022-05-31 00:00:00
#     format = '%b %d %Y'  #The format
    
#     from_datetime_str = dt.strptime(from_date_time, format)
#     to_datetime_str = dt.strptime(to_date_time, format)
 
#     #05/31/2022
#     from_date_dateformat = from_datetime_str.strftime("%m/%d/%Y")
#     to_date_dateformat = to_datetime_str.strftime("%m/%d/%Y")

#     delta = dt.strptime(from_date_dateformat, "%m/%d/%Y") - dt.strptime(to_date_dateformat, "%m/%d/%Y") 

#     datelist = []
#     for i in range(delta.days + 1):
#         day = dt.strptime(from_date, "%m/%d/%Y") + timedelta(days=i)
#         day= day.strftime('%m/%d/%Y')
#         datelist.append(day)

#     return  from_date_dateformat,to_date_dateformat

#print(date_diff("May 31 - Jun 27","May 31 - Jun 27","2022"))
