import json
import pandas as pd
import os
from pandas import *

def xls_to_dict(config_path):
    #C:\Robocorp\Analytix_SalesValidation\Input\SalesValidationConfigFullClient.xlsx
    df = pd.read_excel(config_path, sheet_name='Location_Mapping')
    drec = dict()
    ncols = df.values.shape[1]
    for line in df.values:
        d = drec
        for j, col in enumerate(line[:-1]):
            if not col in d.keys():
                if j != ncols-2:
                    d[col] = {}
                    d = d[col]
                else:
                    d[col] = line[-1]
            else:
                if j!= ncols-2:
                    d = d[col]
    return drec

#df = pd.read_excel('C:\Robocorp\Analytix_SalesValidation\Input\SalesValidationConfigFullClient.xlsx', sheet_name='Location_Mapping')
#drec= xls_to_dict(df)

#keys = drec.keys()
#print(xls_to_dict(df))

