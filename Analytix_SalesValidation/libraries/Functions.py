from datetime import date, timedelta, datetime as dt
import pandas as pd
from pandas import *

def date_diff_fun(FromDate, ToDate):
    from_date = FromDate.strftime("%m/%d/%Y") 
    to_date = ToDate.strftime("%m/%d/%Y")

    delta = dt.strptime(to_date, "%m/%d/%Y") - dt.strptime(from_date, "%m/%d/%Y")

    datelist = []
    for i in range(delta.days + 1):
        day = dt.strptime(from_date, "%m/%d/%Y") + timedelta(days=i)
        day= day.strftime('%m/%d/%Y')
        datelist.append(day)

    return  datelist


def add_leading_zero(Number):
    
    return  Number.zfill(2) 

#
def lib_add_to_dict(dictionary,key,value):

    dictionary[key]=str(value).replace('$','')

    return  dictionary



def lib_add_dict_to_list(L,dictionary):

    #print(L)

    d2=dictionary.copy()

    #print(d2)

    L.append(d2)

    #print(dictionary)

    return L
     
def Emptydict():

    return {}



def pd_to_excel(output_client, report_loc):
    #df = pd.DataFrame.from_dict(output_client)
    df = pd.DataFrame.from_dict(output_client, orient ='index')
    df.to_excel(report_loc)


def remove_percentage(GuestCount):
    if '%' in GuestCount: 
        after_process = GuestCount.replace("%", "")
    else:
        after_process = GuestCount
    return    after_process 


# def excel_to_dictionary():
#     xls = ExcelFile('C:\Robocorp\Analytix_SalesValidation\Input\SalesValidationConfigFullClient.xlsx')
#     data = xls.parse(xls.sheet_names[1])
#     print(data.to_dict())

# print(excel_to_dictionary())