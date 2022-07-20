
from datetime import date, timedelta, datetime as dt


def date_diff(from_date,last_date):
    print(type(from_date))
    print(type(last_date))
    start_date = dt.strftime(from_date, "%m/%d/%Y")
    end_date = dt.strftime(last_date,  "%m/%d/%Y")
    res = (dt.strptime(end_date,"%m/%d/%Y") - dt.strptime(start_date,"%m/%d/%Y")).days
    print(res)
    return int(res)


def date_adding(from_date):
    # start_date = dt.strftime(from_date, "%m/%d/%Y")'
    print(type(from_date))
    Begindate = dt.strptime(from_date, "%m/%d/%Y")
    Enddate = Begindate + timedelta(days=1)
    Enddate= dt.strftime(Enddate, "%m/%d/%Y")
    print(Enddate)
    return Enddate
#print(date_adding('12/20/2022'))


def date_convert_to_date(FromDate, ToDate, year: str):
    #year="2022"
    #FromDate= "May 31 - Jun 27"
    splitted_date = FromDate.split("-")
    
    #May 31
    from_date= splitted_date[0]
    to_date= splitted_date[1]

    #May 31 2022
    from_date_time = from_date+" "+year
    to_date_time = to_date+" "+year

    #avoiding leading and trailing spaces
    from_date_time=from_date_time.strip()
    to_date_time=to_date_time.strip()

    #%m/%d/%Y
    #2022-05-31 00:00:00
    format = '%b %d %Y'  #The format
    
    from_datetime_str = dt.strptime(from_date_time, format)
    to_datetime_str = dt.strptime(to_date_time, format)
 
    #05/31/2022
    from_date_dateformat = from_datetime_str.strftime("%m/%d/%Y")
    to_date_dateformat = to_datetime_str.strftime("%m/%d/%Y")

    return  from_date_dateformat,to_date_dateformat

