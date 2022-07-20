*** Settings ***
Documentation       Template robot main suite.
Library             RPA.Browser.Selenium
Library             RPA.Tables
Library             DateTime
Library             RPA.Excel.Files
Library             Collections
Library         String


*** Variables ***
${current_date} =	Get Current Date    result_format=%m/%d/%Y



*** Tasks ***
testrunning
    

    # ${columns}=  Create list     One  Two  Three
    # ${TEMP_CLIENT_TABLE}=    Create table    columns=${columns}
    # ${type string}=    Evaluate     type($current_date)
    # Log To Console    ${type string}

    #C:\Robocorp\Analytix_SalesValidation\Input\SalesValidationConfigFullClient.xlsx

    Open Workbook   ${EXECDIR}/Input/SalesValidationConfigFullClient.xlsx

    ${SettingsDetails}=    Read Worksheet As Table   name=ClientList  header=True
    Log To Console  ${settings_details}

    ${SquareupDetails}=    Read Worksheet As Table   name=SquareUpLogins  header=True
    Log To Console  ${SquareupDetails}

    Sort Table By Column    ${SettingsDetails}    LoginCategory  ascending=${FALSE}
    #Sort Table By Column    ${SettingsDetails}    UserName  ascending=${FALSE}
    
    # &{dict} =	Create Dictionary

    # FOR    ${row}    IN    @{SettingsDetails}
    #     Set To Dictionary	${dict}    key=${row}[UserName]_${row}[Timezone]    value=${row}
    # END

    # Log    ${dict}

    ${clientwise_workers_dic}=  Create Dictionary
    FOR    ${element}    IN    @{SquareupDetails}
        ${temp_table}=  Copy Table  ${SettingsDetails}
        Filter Table By Column    ${temp_table}    LoginCategory   ==   ${element}[LoginCategory]
        ${row_count}=  Get Length  ${temp_table}
        IF    ${row_count}>0
            Set To Dictionary    ${clientwise_workers_dic}    ${element}[LoginCategory]--${element}[UserName]--${element}[Password]=${temp_table}
        END
        Log  ${element}
        Log  ${temp_table}
    END
    Log  ${clientwise_workers_dic}

    FOR    ${key}    IN    @{clientwise_workers_dic.keys()}
        Log    ${key}
        @{credentials} =	Split String	${key}    --
        Log    ${credentials}[0]
        Log    ${credentials}[1]
        Log    ${credentials}[2]
        Log    ${clientwise_workers_dic["${key}"]}
    END





    
    