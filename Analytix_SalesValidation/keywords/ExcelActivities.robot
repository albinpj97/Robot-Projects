*** Settings ***
Documentation       All excel operations such as config reading, run report writing etc.
Library             RPA.Browser.Selenium
Library             RPA.Excel.Files
Library             RPA.Tables
Library             Collections

*** Keywords ***
Load Config Details
    [Arguments]    ${SalesValidationConfig}
    
    ${status}  ${reason}  Run Keyword And Ignore Error  Open Workbook   ${SalesValidationConfig}
    
    IF    '${status}' == 'PASS'
        ${SettingsDetails}=    Read Worksheet As Table   name=Settings  header=True
        Log  ${settings_details}

        #Settings set up
        FOR    ${row}    IN    @{SettingsDetails}
            ${ConfigSettings}=    Set Variable  ${row}
        END
        
        IF    '${ConfigSettings}[Run]' == 'Daily'
            ${ClientTable}=   Read Worksheet As Table     name=ClientList_Day  header=True
            Log   ${ClientTable}
        ELSE
           ${ClientTable}=   Read Worksheet As Table     name=ClientList_Mon  header=True
            Log   ${ClientTable} 
        END

        ${SquareupLogins}=   Read Worksheet As Table     name=SquareUpLogins  header=True
        Log   ${SquareupLogins}

        Close Workbook

        #Client details set up
        ${ClientFullDetails}=  Create List
        FOR    ${row}    IN    @{ClientTable}
            Append To List   ${ClientFullDetails}  ${row}
        END
        Log List  ${ClientFullDetails}


        #Client details for SquareUp
        Sort Table By Column    ${ClientTable}    LoginCategory  ascending=${FALSE}
        
        ${loginwise_client_dic}=  Create Dictionary
        
        FOR    ${element}    IN    @{SquareupLogins}
            ${temp_table}=  Copy Table  ${ClientTable}
            Filter Table By Column    ${temp_table}    LoginCategory   ==   ${element}[LoginCategory]
            ${row_count}=  Get Length  ${temp_table}
            IF    ${row_count}>0
                Set To Dictionary    ${loginwise_client_dic}    ${element}[LoginCategory]--${element}[UserName]--${element}[Password]--${element}[Timezone]=${temp_table}
            END
            Log  ${element}
            Log  ${temp_table}
        END
        Log  ${loginwise_client_dic}

        Return From Keyword  PASS    ${ConfigSettings}  ${ClientFullDetails}    ${loginwise_client_dic}    
    ELSE
        Return From Keyword  FAIL    1     1    1
    END 

*** Keywords ***
Write Status To Run Report
    [Arguments]    ${ClientName}    ${RunDate}    ${Status}    
        &{RunDict}=  Create Dictionary
        Set To Dictionary  ${RunDict}  Client=${ClientName}    Run Date=${RunDate}    Status=${Status}
        ${table}=  Create Table  ${RunDict}
        Open Workbook    ${RunReportPath}
        Append Rows To Worksheet    ${table}  header=True
        Save Workbook
        Close Workbook


*** Keywords ***
Write Sales Datas To Report
    [Arguments]    ${ClientName}    ${SingleDate}    ${GrossTotalSales}    ${NetTotalSales}    ${NetGuest}    ${Discount}
    &{SalesDict}=  Create Dictionary
    Set To Dictionary    ${SalesDict}   Client=${ClientName}    Date=${SingleDate}    SnapshotGrossSales=${GrossTotalSales}    SnapshotNetSales=${NetTotalSales}    SnapshotGuestCount=${NetGuest}    SnapshotDiscount=${Discount}
    ${table}=  Create Table  ${SalesDict}
    Open Workbook    ${SalesReportPath}
    Append Rows To Worksheet    ${table}  header=True
    Save Workbook
    Close Workbook


*** Keywords ***
Write Sales Datas To CLR Report
    [Arguments]    ${ClientName}    ${SingleDate}    ${GrossTotalSales}    ${NetTotalSales}    ${NetGuest}    ${Discount}
    &{SalesDict}=  Create Dictionary
    Set To Dictionary    ${SalesDict}   Client=${ClientName}    Date=${SingleDate}    CLRGrossSales=${GrossTotalSales}    CLRNetSales=${NetTotalSales}    CLRGuestCount=${NetGuest}    CLRDiscount=${Discount}
    ${table}=  Create Table  ${SalesDict}
    Open Workbook    ${CLRReportPath}
    Append Rows To Worksheet    ${table}  header=True
    Save Workbook
    Close Workbook


*** Keywords ***
Write Sales Datas To POS Report
    [Arguments]    ${ClientName}    ${SingleDate}    ${GrossTotalSales}    ${NetTotalSales}    ${NetGuest}    ${Discount}
    &{SalesDict}=  Create Dictionary
    Set To Dictionary    ${SalesDict}   Client=${ClientName}    Date=${SingleDate}    POSGrossSales=${GrossTotalSales}    POSNetSales=${NetTotalSales}    POSGuestCount=${NetGuest}    POSDiscount=${Discount}
    ${table}=  Create Table  ${SalesDict}
    Open Workbook    ${POSReportPath}
    Append Rows To Worksheet    ${table}  header=True
    Save Workbook
    Close Workbook


