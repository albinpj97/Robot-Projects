import json
import pandas as pd
import os

def sub(list_all_data, ClientName, POSName, DateVal, GrossSales, NetSales, GuestCount, Discount, KeyVal):
        OutputSheetDetails = {"Client":"","POSName":"","Dates":"","POS Gross Sales":"","POS Net Sales":"","POS Guest Count":"","POS Discount":"","Snapshot Gross Sales":"","Snapshot Net Sales":"","Snapshot Guest Count":"","Snapshot Discount":"","CLR Gross Sales":"","CLR Net Sales":"","CLR Guest Count":"","CLR Discount":"","POS vs Snapshot Gross Sales":"","POS vs Snapshot Net Sales":"","POS vs Snapshot Guest Count":"","POS vs Snapshot Discount":"","POS vs CLR Gross Sales":"","POS vs CLR Net Sales":"","POS vs CLR Guest Count":"","POS vs CLR Discount":""}
        OutputSheetDetails["Client"]=ClientName
        OutputSheetDetails["POSName"]=POSName
        OutputSheetDetails["Dates"]=DateVal
        OutputSheetDetails["Snapshot Gross Sales"]=GrossSales
        OutputSheetDetails["Snapshot Net Sales"]=NetSales
        OutputSheetDetails["Snapshot Guest Count"]=GuestCount
        OutputSheetDetails["Snapshot Discount"]=Discount
        list_all_data[KeyVal]=OutputSheetDetails.copy()
        
        return list_all_data

def sales_data_writing(list_all_data, ClientName, POSName, FromDate, ToDate, GrossSales, NetSales, GuestCount, Discount, KeyVal):
        OutputSheetDetails = {"Client":"","POSName":"","Start Date":"","End Date":"","POS Gross Sales":"","POS Net Sales":"","POS Guest Count":"","POS Discount":"","Snapshot Gross Sales":"","Snapshot Net Sales":"","Snapshot Guest Count":"","Snapshot Discount":"","CLR Gross Sales":"","CLR Net Sales":"","CLR Guest Count":"","CLR Discount":"","POS vs Snapshot Gross Sales":"","POS vs Snapshot Net Sales":"","POS vs Snapshot Guest Count":"","POS vs Snapshot Discount":"","POS vs CLR Gross Sales":"","POS vs CLR Net Sales":"","POS vs CLR Guest Count":"","POS vs CLR Discount":""}
        OutputSheetDetails["Client"]=ClientName
        OutputSheetDetails["POSName"]=POSName
        OutputSheetDetails["Start Date"]=FromDate
        OutputSheetDetails["End Date"]=ToDate
        OutputSheetDetails["Snapshot Gross Sales"]=GrossSales
        OutputSheetDetails["Snapshot Net Sales"]=NetSales
        OutputSheetDetails["Snapshot Guest Count"]=GuestCount
        OutputSheetDetails["Snapshot Discount"]=Discount
        list_all_data[KeyVal]=OutputSheetDetails.copy()
        
        return list_all_data


def dictionary_check(list_all_data, ClientName, POSName, DateVal, GrossSales, NetSales, GuestCount, Discount, KeyVal):

        keys = list(list_all_data.keys())
        for i in range(len(keys)):  
                if  KeyVal == keys[i]:
                        print("exist")
                        list_all_data.get(KeyVal)["CLR Gross Sales"]=GrossSales
                        list_all_data.get(KeyVal)["CLR Net Sales"]=NetSales
                        list_all_data.get(KeyVal)["CLR Guest Count"]=GuestCount
                        list_all_data.get(KeyVal)["CLR Discount"]=Discount

        return list_all_data
        
#v={'FLX Hospitality--F L X Fry Bird_06/03/2022': {'Client': 'FLX Hospitality--F L X Fry Bird', 'Dates': '06/03/2022', 'POS Gross Sales': '', 'POS Net Sales': '', 'POS Guest Count': '', 'POS Discount': '', 'Snapshot Gross Sales': '$3,122.12', 'Snapshot Net Sales': '$3,119.38', 'Snapshot Guest Count': '70', 'Snapshot Discount': '$2.74', 'CLR Gross Sales': '', 'CLR Net Sales': '', 'CLR Guest Count': '', 'CLR Discount': '', 'POS vs Snapshot Gross Sales': '', 'POS vs Snapshot Net Sales': '', 'POS vs Snapshot Guest Count': '', 'POS vs Snapshot Discount': '', 'POS vs CLR Gross Sales': '', 'POS vs CLR Net Sales': '', 'POS vs CLR Guest Count': '', 'POS vs CLR Discount': ''}}
#print(dictionary_check(v,'FLX Hospitality--F L X Feast & Co Catering','06/03/2022','$3735.65','(51.90)','$0.00','166','FLX Hospitality--F L X Feast & Co Catering_06/03/2022'))


def dictionary_check_monthly_sales(list_all_data, ClientName, POSName, FromDate, ToDate, GrossSales, NetSales, GuestCount, Discount, KeyVal):

        keys = list(list_all_data.keys())
        for i in range(len(keys)):  
                if  KeyVal == keys[i]:
                        print("exist")
                        list_all_data.get(KeyVal)["CLR Gross Sales"]=GrossSales
                        list_all_data.get(KeyVal)["CLR Net Sales"]=NetSales
                        list_all_data.get(KeyVal)["CLR Guest Count"]=GuestCount
                        list_all_data.get(KeyVal)["CLR Discount"]=Discount

        return list_all_data


def dictionary_update_with_squareup_data(list_all_data,ClientName,POSName,DateVal,GrossSales,NetSales,GuestCount,Discount,KeyVal,location_mapping_dic):
        SplittedKeyWithUnderscore = KeyVal.split('_')
        ClientNamePart1 = SplittedKeyWithUnderscore[0]

        SplittedKeyWithHiffon = ClientNamePart1.split('--')
        ClientNamePart = SplittedKeyWithHiffon[0]

        keys = list(list_all_data.keys())


        givenstrkey = []
        for j in range(len(keys)):
                if  ClientNamePart in keys[j]:
                        givenstrkey.append(keys[j])

        # gross_sum = 0.0
        # net_sum = 0.0
        # guest_sum = 0.0
        # discount_sum = 0.0
        # clr_gross_sum = 0.0
        # clr_net_sum = 0.0
        # clr_guest_sum = 0.0
        # clr_discount_sum = 0.0
        
        for k in range(len(givenstrkey)):
                if  ClientNamePart1 in givenstrkey[k]:
                        Key1 = givenstrkey[k]
                else:
                       location_split = ClientNamePart1.split('--')
                       client_name = location_split[0] 
                       location_name = location_split[1]
                       if  client_name in givenstrkey[k]:
                                Key1= key_generation(location_mapping_dic,client_name,location_name,DateVal)

                #replacing Snapshot datas  $ as "" and , as "" 
                SnpGrossSale = (list_all_data.get(Key1)["Snapshot Gross Sales"]).replace("$","",1)
                SnpNetSale = (list_all_data.get(Key1)["Snapshot Net Sales"]).replace("$","",1)
                SnpGuestCount = (list_all_data.get(Key1)["Snapshot Guest Count"]).replace("$","",1)
                SnpDiscount = (list_all_data.get(Key1)["Snapshot Discount"]).replace("$","",1)
                SnpGrossSale=SnpGrossSale.replace(",","")
                SnpNetSale=SnpNetSale.replace(",","")
                SnpGuestCount=SnpGuestCount.replace(",","")
                SnpDiscount=SnpDiscount.replace(",","")

                # if SnpGrossSale != "":
                #         gross_sum = gross_sum + float(SnpGrossSale)
                # if SnpNetSale != "":
                #         net_sum = net_sum + float(SnpNetSale)
                # if SnpGuestCount != "":
                #         guest_sum = guest_sum + float(SnpGuestCount)
                # if SnpDiscount != "":        
                #         discount_sum = discount_sum + float(SnpDiscount)

                #replacing CLR datas  $ as "" and , as "" 
                ClrGrossSale = (list_all_data.get(Key1)["CLR Gross Sales"]).replace("$","",1)
                ClrNetSale = (list_all_data.get(Key1)["CLR Net Sales"]).replace("$","",1)
                ClrGuestCount = (list_all_data.get(Key1)["CLR Guest Count"]).replace("$","",1)
                ClrDiscount = (list_all_data.get(Key1)["CLR Discount"]).replace("$","",1)
                ClrGrossSale=ClrGrossSale.replace(",","")
                ClrNetSale=ClrNetSale.replace(",","")
                ClrGuestCount=ClrGuestCount.replace(",","")
                ClrDiscount=ClrDiscount.replace(",","")

                # if ClrGrossSale != "":
                #         clr_gross_sum = clr_gross_sum + float(ClrGrossSale)
                # if ClrNetSale != "":
                #         clr_net_sum = clr_net_sum + float(ClrNetSale)
                # if ClrGuestCount != "":        
                #         clr_guest_sum = clr_guest_sum + float(ClrGuestCount)
                # if ClrDiscount != "":
                #         clr_discount_sum = clr_discount_sum + float(ClrDiscount)

                KeyVal = Key1
                                
                if "(" in Discount:
                        Discount = Discount.lstrip("(")
                if ")" in Discount:
                        Discount = Discount.rstrip(")")
                Discount=Discount.replace("$","",1)
                Discount=Discount.replace(",","")

                #POS Squareup Sales Datas
                list_all_data.get(KeyVal)["POS Gross Sales"]=GrossSales
                list_all_data.get(KeyVal)["POS Net Sales"]=NetSales
                list_all_data.get(KeyVal)["POS Guest Count"]=GuestCount
                list_all_data.get(KeyVal)["POS Discount"]=Discount

                #replacing POS Squareup datas  $ as "" and , as "" 
                GrossSales=GrossSales.replace("$","",1)
                GrossSales=GrossSales.replace(",","")
                NetSales=NetSales.replace("$","",1)
                NetSales=NetSales.replace(",","")
                GuestCount=GuestCount.replace("$","",1)
                GuestCount=GuestCount.replace(",","")

                #convert POS Squareup entries and Snapshot entries to double and calculate difference
                POSGrossVsSNPGross = float(GrossSales)-float(SnpGrossSale)
                POSGrossVsSNPGross=round(float(POSGrossVsSNPGross),2)

                POSNetVsSNPNet = float(NetSales)-float(SnpNetSale)
                POSNetVsSNPNet=round(float(POSNetVsSNPNet),2)

                POSGuestVsSNPGuest = float(GuestCount)-float(SnpGuestCount)
                POSGuestVsSNPGuest=round(float(POSGuestVsSNPGuest),2)
                #print(PSvsSNPgc)

                POSDiscountVsSNPDiscount = float(Discount)-float(SnpDiscount)
                POSDiscountVsSNPDiscount=round(float(POSDiscountVsSNPDiscount),2)
                #print(PSvsSNPd)
                
                #Adding the difference into dictionary
                list_all_data.get(KeyVal)["POS vs Snapshot Gross Sales"]=POSGrossVsSNPGross
                list_all_data.get(KeyVal)["POS vs Snapshot Net Sales"]=POSNetVsSNPNet
                list_all_data.get(KeyVal)["POS vs Snapshot Guest Count"]=POSGuestVsSNPGuest
                list_all_data.get(KeyVal)["POS vs Snapshot Discount"]=POSDiscountVsSNPDiscount


                #------------------------------------------------------------------------
                
                #convert POS Squareup entries and CLR entries to double and calculate difference
                POSGrossVsCLRGross = float(GrossSales)-float(ClrGrossSale)
                POSGrossVsCLRGross=round(float(POSGrossVsCLRGross),2)

                POSNetVsCLRNet = float(NetSales)-float(ClrNetSale)
                POSNetVsCLRNet=round(float(POSNetVsCLRNet),2)

                POSGuestVsCLRGuest = float(GuestCount)-float(ClrGuestCount)
                POSGuestVsCLRGuest=round(float(POSGuestVsCLRGuest),2)
                #print(PSvsSNPgc)

                POSDiscountVsCLRDiscount = float(Discount)-float(ClrDiscount)
                POSDiscountVsCLRDiscount=round(float(POSDiscountVsCLRDiscount),2)
                print(POSDiscountVsCLRDiscount)
                

                #Adding the difference into excel
                list_all_data.get(KeyVal)["POS vs CLR Gross Sales"]=POSGrossVsCLRGross
                list_all_data.get(KeyVal)["POS vs CLR Net Sales"]=POSNetVsCLRNet
                list_all_data.get(KeyVal)["POS vs CLR Guest Count"]=POSGuestVsCLRGuest
                list_all_data.get(KeyVal)["POS vs CLR Discount"]=POSDiscountVsCLRDiscount

        return list_all_data
        
#v={'Park Bars--Bar Flores_06/05/2022': {'Client': 'Park Bars--Bar Flores', 'Dates': '06/05/2022', 'POS Gross Sales': '', 'POS Net Sales': '', 'POS Guest Count': '', 'POS Discount': '', 'Snapshot Gross Sales': '$13,070.00', 'Snapshot Net Sales': '$12,804.50', 'Snapshot Guest Count': '423', 'Snapshot Discount': '$265.50', 'CLR Gross Sales': '$12,804.50', 'CLR Net Sales': '430.00', 'CLR Guest Count': '$13,070.00', 'CLR Discount': '$47.00', 'POS vs Snapshot Gross Sales': '', 'POS vs Snapshot Net Sales': '', 'POS vs Snapshot Guest Count': '', 'POS vs Snapshot Discount': '', 'POS vs CLR Gross Sales': '', 'POS vs CLR Net Sales': '', 'POS vs CLR Guest Count': '', 'POS vs CLR Discount': '', 'POSName': 'Park Hospitality'}, 'Park Bars--Lowboy_06/05/2022': {'Client': 'Park Bars--Lowboy', 'Dates': '06/05/2022', 'POS Gross Sales': '', 'POS Net Sales': '', 'POS Guest Count': '', 'POS Discount': '', 'Snapshot Gross Sales': '$9,236.00', 'Snapshot Net Sales': '$9,004.10', 'Snapshot Guest Count': '382', 'Snapshot Discount': '$231.90', 'CLR Gross Sales': '$9,004.10', 'CLR Net Sales': '400.00', 'CLR Guest Count': '$9,236.00', 'CLR Discount': '$67.40', 'POS vs Snapshot Gross Sales': '', 'POS vs Snapshot Net Sales': '', 'POS vs Snapshot Guest Count': '', 'POS vs Snapshot Discount': '', 'POS vs CLR Gross Sales': '', 'POS vs CLR Net Sales': '', 'POS vs CLR Guest Count': '', 'POS vs CLR Discount': '', 'POSName': 'Park Hospitality'}, 'Park Bars--Wolf & Crane Bar_06/05/2022': {'Client': 'Park Bars--Wolf & Crane Bar', 'Dates': '06/05/2022', 'POS Gross Sales': '', 'POS Net Sales': '', 'POS Guest Count': '', 'POS Discount': '', 'Snapshot Gross Sales': '$5,029.47', 'Snapshot Net Sales': '$4,763.24', 'Snapshot Guest Count': '157', 'Snapshot Discount': '$266.23', 'CLR Gross Sales': '', 'CLR Net Sales': '', 'CLR Guest Count': '', 'CLR Discount': '', 'POS vs Snapshot Gross Sales': '', 'POS vs Snapshot Net Sales': '', 'POS vs Snapshot Guest Count': '', 'POS vs Snapshot Discount': '', 'POS vs CLR Gross Sales': '', 'POS vs CLR Net Sales': '', 'POS vs CLR Guest Count': '', 'POS vs CLR Discount': '', 'POSName': 'Park Hospitality'}, 'Firetrail Pizza--FIRETRAIL PIZZA - Reno_06/07/2022': {'Client': 'Firetrail Pizza--FIRETRAIL PIZZA - Reno', 'Dates': '06/07/2022', 'POS Gross Sales': '', 'POS Net Sales': '', 'POS Guest Count': '', 'POS Discount': '', 'Snapshot Gross Sales': '$946.00', 'Snapshot Net Sales': '$940.00', 'Snapshot Guest Count': '51', 'Snapshot Discount': '$6.00', 'CLR Gross Sales': '$946.00', 'CLR Net Sales': '$940.00', 'CLR Guest Count': '51.00', 'CLR Discount': '$0.00', 'POS vs Snapshot Gross Sales': '', 'POS vs Snapshot Net Sales': '', 'POS vs Snapshot Guest Count': '', 'POS vs Snapshot Discount': '', 'POS vs CLR Gross Sales': '', 'POS vs CLR Net Sales': '', 'POS vs CLR Guest Count': '', 'POS vs CLR Discount': '', 'POSName': 'FIRETRAIL PIZZA LLC'}, 'Firetrail Pizza--FIRETRAIL PIZZA - Spark_06/07/2022': {'Client': 'Firetrail Pizza--FIRETRAIL PIZZA - Spark', 'Dates': '06/07/2022', 'POS Gross Sales': '', 'POS Net Sales': '', 'POS Guest Count': '', 'POS Discount': '', 'Snapshot Gross Sales': '$4,175.00', 'Snapshot Net Sales': '$4,159.40', 'Snapshot Guest Count': '216', 'Snapshot Discount': '$0.00', 'CLR Gross Sales': '$4,175.00', 'CLR Net Sales': '$4,159.40', 'CLR Guest Count': '216.00', 'CLR Discount': '$0.00', 'POS vs Snapshot Gross Sales': '', 'POS vs Snapshot Net Sales': '', 'POS vs Snapshot Guest Count': '', 'POS vs Snapshot Discount': '', 'POS vs CLR Gross Sales': '', 'POS vs CLR Net Sales': '', 'POS vs CLR Guest Count': '', 'POS vs CLR Discount': '', 'POSName': 'FIRETRAIL PIZZA LLC'}}
#print(dictionary_update_with_squareup_data(v,'Park Bars','06/06/2022','$0.00','$0.00','$0.00','0','Park Bars_06/06/2022'))

def key_generation(location_mapping_dic,client_name,location_name,selected_date):
    # Iterating over values
    for main_key, value in location_mapping_dic.items():
        #Check client name selected from SquareUp
        if client_name == main_key:
            print("Present")
            print(main_key, ":", value)
            
            for sub_key, sub_value in value.items():
                #check location_name selected from SquareUp
                if location_name in sub_value:
                    print(sub_key)
                    print(sub_key, ":", sub_value)
                    #Picking the Insight location name from mapping dictionary based on selected Squareup location name.
                    map_key= client_name+"--"+sub_key+"_"+selected_date
                    print(map_key)
    return  map_key


def write_json(fulllist,loc): 
    # Serializing json
    json_object = json.dumps(fulllist, indent = 4) 
  
    # Writing to sample.json 
    with open(f'{loc}/ExtractedSalesDetails.json', "w") as outfile: 
        outfile.write(json_object)

def read_json(loc):
    with open(f'{loc}/ExtractedSalesDetails.json') as f:
       data = json.load(f)
    return  data 



def get_init_details():
    #ROOT_DIR = os.path.abspath(os.curdir)
    #print(os.curdir)
    #BASE_PATH=ROOT_DIR.split('\Auto_Posting')[0]+'\Auto_Posting\Config_Files'
    dict_from_csv = pd.read_excel('C:\Robocorp\Analytix_SalesValidation\Input\SalesValidationConfigFullClient.xlsx', squeeze=True, dtype=object).to_dict(orient='records')
    return(dict_from_csv)
    print(dict_from_csv)

#print(get_init_details())
def get_client_details(client_name):
    client=None
    details=get_init_details()
    for i in details:
        print(i.get('Client'))
        if i.get('Client').strip().lower()==client_name.strip().lower():
            #Unposted_stat=True if i.get('Unposted').strip()=='Yes' else False
            #Tax_payment=True if i.get('Tax_payment').strip()=='Yes' else False
            #Funds_Confirmed_stat=True if i.get('Funds_Confirmed').strip()=='Yes' else False
            #Only_current_date_stat=True if i.get('Only_current_date').strip()=='Yes' else False
            #email=str(i.get('Email')).strip().replace(" ", "").replace(',',', ')
            return str(i.get('InsightLocationName')).strip(),str(i.get('SquareUpLocationName')).strip()
#print(get_init_details())
#print(get_client_details('Calmar Inc. dba AR Medical Supply '))

# def test_data(Discount):
#         if "(" in Discount:
#                 Discount = Discount.lstrip("(")
#         if ")" in Discount:
#                 Discount = Discount.rstrip(")")
#         Discount=Discount.replace("$","",1)
#         Discount=Discount.replace(",","")
#         print(Discount)

# print(test_data('($51.90)'))

