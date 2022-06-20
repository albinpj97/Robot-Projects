*** Settings ***
Documentation       Orange Hr Automation
Library    RPA.Robocorp.Vault
Library    RPA.Browser
Library    MyVariables.py
Library    RPA.Tables
Library    Collections
Library    RPA.core.notebook


*** Keyword ***
Orangehr login
    Open Available Browser      https://opensource-demo.orangehrmlive.com/
    Maximize Browser Window
    ${secret}=    Get Secret    orange_hr_credentials
    Input Text      //input[@id="txtUsername"]   ${secret}[username]
    Input Text      //input[@id="txtPassword"]   ${secret}[password]
    Click Button When Visible       //input[@value="LOGIN"]

*** Keywords ***
table extraction
    Orangehr login
    Click Element When Visible      //b[contains(.,"Recruitment")]
    ${table_data}   Create Table
    ${table_row_count}  Get Element Count   //table[@id="resultTable"]//tbody//tr
    ${table_column_count}    Get Element Count  //table[@id="resultTable"]//tr//th
    FOR     ${counter}  IN RANGE    ${2}    ${table_column_count}
        ${data}     Get Text    //table[@id="resultTable"]//tr//th[${counter}]
        Add Table Column    ${table_data}   ${data}
        Log     ${counter}
    END
    FOR     ${row_counter}  IN RANGE    ${1}    ${table_row_count+1}    ${1}
        ${list_data}    Create list
        FOR     ${column_counter}   IN RANGE    ${2}   ${table_column_count}    ${1}
            ${data}     Get Text    //table[@id="resultTable"]//tbody//tr[${row_counter}]//td[${column_counter}]
            Append To List  ${list_data}    ${data}
        END
        Add Table Row   ${table_data}   ${list_data}
    END
    #Notebook Print ${table_data}
    Write table to CSV  ${table_data}   output/output.csv  overwrite=True




