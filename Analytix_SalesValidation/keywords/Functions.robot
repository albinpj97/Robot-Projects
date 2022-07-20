*** Settings ***
Documentation       String MAnipulations and Other Functions
Library            RPA.Browser.Selenium
Library            String
Library            DateTime
Library            RPA.Tables
Library            RPA.Excel.Files
Library            Collections
Library            ExcelRemove
Library            RPA.FileSystem


*** Keywords ***
Init Process
    #Setting the SalesValidationConfig.xlsx path and RunReport.xlsx path to globel variables. This variable availble every where in this process.
    Set Suite Variable    ${SalesValidationConfig}      ${EXECDIR}/Input/SalesValidationConfig.xlsx
    Set Suite Variable    ${RunReportPath}    ${EXECDIR}/Output/RunReport.xlsx  
    Set Suite Variable    ${SalesReportPath}    ${EXECDIR}/Input/ExtractTemplate.xlsx
    Set Suite Variable    ${CLRReportPath}    ${EXECDIR}/Input/ExtractTemplateClr.xlsx
    Set Suite Variable    ${POSReportPath}    ${EXECDIR}/Input/ExtractTemplatePos.xlsx
    Set Suite Variable    ${AUTO_DOWNLOAD_FOLDER_PATH}        ${EXECDIR}${/}DownloadTemp
    Set Suite Variable    ${Retry}    10
    Set Suite Variable    ${RetrySeconds}    5
    Set Suite Variable    ${JsonFilePath}      ${EXECDIR}/Input
    Set Suite Variable    ${MonthlyOutputSheetPath}    ${EXECDIR}/Output/MonthlyOutputSheet.xlsx
    Set Suite Variable    ${OutputSheetPath}    ${EXECDIR}/Output/OutputSheet.xlsx


*** Keywords ***
Reset Reports
    Empty Directory   path=${AUTO_DOWNLOAD_FOLDER_PATH}
    clear_excel_value    ${RunReportPath}    2
    clear_excel_value    ${SalesReportPath}    2
    clear_excel_value    ${CLRReportPath}    2
    clear_excel_value    ${POSReportPath}    2
    clear_excel_value    ${OutputSheetPath}    4
    clear_excel_value    ${MonthlyOutputSheetPath}    4


*** Keywords ***
Input Date Prepare 
    [Arguments]    ${InputDate} 

    ${ConvertedDate}=    Convert Date    ${InputDate}    date_format=%m/%d/%Y    result_format=%b/%\#d/%Y
    @{DateSplit}=    Split String    ${ConvertedDate}    /
    ${Month}=   Set Variable    ${DateSplit}[0]
    ${Day}=   Set Variable     ${DateSplit}[1]    
    ${Year}=    Set Variable    ${DateSplit}[2]
    [Return]    ${Day}    ${Month}    ${Year}


*** Keywords ***
Prepare Outputsheet
    [Arguments]    ${list_all_data}    ${OutputSheetPathToClient}
    Open Workbook    ${OutputSheetPathToClient}
    FOR    ${client}    IN    @{list_all_data}

        ${clientData}=  Get From Dictionary    ${list_all_data}    ${client}
        Append Rows to Worksheet  ${clientData}  #header=${TRUE}
        
    END
    Save Workbook





    
