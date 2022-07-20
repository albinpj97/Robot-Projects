*** Settings ***
Documentation       Kitchensync Process
Library             RPA.Browser.Selenium
Library             Log
Library             html_tables
Library             Excel_Operations
Library             Functions
Library             String
Library             DateTime
Resource            ExcelActivities.robot
Resource            KitchensyncMonthlySales.robot
Resource            Functions.robot
Library             RPA.Tables


*** Variables ***
&{list_all_data}   


*** Keywords ***
Capture Sales Details From Kitchensync P3  
    [Arguments]        ${client}    ${monthly_or_daily}
    write_log_text  'Kitchensync Process- Capture Sales Details From Kitchensync:'  'Entered Into Kitchensync'  Output  log

    ${current_date} =	Get Current Date    result_format=%m/%d/%Y
    
    #Select a client
    ${ClientStatus}    Select Client P4    ${client}
    IF    '${ClientStatus}'=='True'
        write_log_text  'KitchensyncProcess- Select Client:'    ${client}[Client] 'Exist In Kitchensync.'     Output    log
        Write Status To Run Report     ${client}[Client]     ${current_date}      Client Exist In Kitchensync.
        
        IF    '${monthly_or_daily}' == 'Monthly'
            #If the config sheet have monthly run, then it goes to "Monthly Sales Validation Process"
            ${status1}  ${reason1}   Run Keyword And Ignore Error    Monthly Sales Validation Process    ${client}
        ELSE
            #To get days between FromDate and ToDate
            ${datelist}=    date_diff_fun    ${client}[FromDate]    ${client}[ToDate]  
            Log    ${datelist}
        
            #-------------------------------------- Snapshot and primecost report extraction started ------------------------------------------------------------------------
            
            #Looping through dates between fromdate and todate
            FOR    ${SingleDate}    IN    @{datelist}
                Log    ${SingleDate}
                #Input from date prepare and setting the date to datepicker.
                ${Day}    ${Month}    ${Year}=    Input Date Prepare     ${SingleDate}
                

                # Select Snapshot Report from left menu then continue the extraction part
                Select Snapshot Report    ${client}

                ${3DotsVisible}=     RPA.Browser.Selenium.Is Element Visible    xpath://span[contains(text(),"...")]
                IF    ${3DotsVisible}
                    
                    #Checking if ... is visible or not. If yes click on the search box
                    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://span[contains(text(),"...")]//parent::button
                    Sleep    2s
                    
                    #Checking if Concept title is visible or not
                    ${ConceptVisible}=     RPA.Browser.Selenium.Is Element Visible    xpath://h2[contains(text(),"Concepts")]

                    #If Concept title is visible,
                    IF    ${ConceptVisible}
                        
                        #Then picking the concept count
                        ${ConceptCount}=    Get Element Count    xpath://h2[contains(text(),"Concepts")]/following-sibling::div[@class="childscrll scroll-custom"]//div[@class="ng-star-inserted"]

                        #Loop through the concepts
                        FOR    ${i}    IN RANGE    1    ${ConceptCount+1}
                        
                        IF    ${i} > 1 
                            Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://span[contains(text(),"...")]//parent::button
                            Sleep    3s
                        END

                        #Click on Concept one by one
                        Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://h2[contains(text(),"Concepts")]/following-sibling::div[@class="childscrll scroll-custom"]//div[@class="ng-star-inserted"][${i}]
                        Sleep    3s 
                        #Checking if Location is visible
                        ${LocationVisible}=     RPA.Browser.Selenium.Is Element Visible    xpath://h2[contains(text(),"Locations")]

                            #If Location is visible,
                            IF    ${LocationVisible}
                                #Then picking the Location count
                                ${LocationCount}=    Get Element Count    xpath://h2[contains(text(),"Locations")]/following-sibling::div[@class="childscrll scroll-custom"]//div[@class="ng-star-inserted"]
                                
                                #Loop through the locations
                                FOR    ${j}    IN RANGE    1    ${LocationCount+1}
                                    
                                    IF    ${j} > 1
                                        Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://span[contains(text(),"...")]//parent::button
                                        Sleep    3s

                                        #Click on previously selected Concept once again
                                        Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://h2[contains(text(),"Concepts")]/following-sibling::div[@class="childscrll scroll-custom"]//div[@class="ng-star-inserted"][${i}]
                                        Sleep    3s

                                    END

                                    #Click on first location 
                                    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://h2[contains(text(),"Locations")]/following-sibling::div[@class="childscrll scroll-custom"]//div[@class="ng-star-inserted"][${j}]
                                    Sleep    2s

                                    #Store the selected Location name to a variable
                                    ${SelectedLocationName}=    Get Text   xpath://h2[contains(text(),"Locations")]/following-sibling::div[@class="childscrll scroll-custom"]//div[@class="ng-star-inserted"][${j}]//span

                                    #Click on Apply button
                                    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://button[@class="btn btn--primary" and contains(text(),"Apply")]
                                    
                                    #Wait Until Page Does Not Contain Element    xpath://div[@class="spinner-wrap local active"]

                                    #Select the sales option, day, date
                                    Select Options    ${client}

                                    #Date setting
                                    Date Setting Process    ${Day}    ${Month}    ${Year}
                                    #Sleep    10s

                                    ${NoDataWindowVisible}=    RPA.Browser.Selenium.Is Element Visible    xpath:(//div[contains(text(),"No sales during this period")])[1]
                
                                    IF    '${NoDataWindowVisible}' != 'True'
                                        #Data extraction from Gross and Net
                                        ${status1}  ${reason1}   Run Keyword And Ignore Error    Sales Data Extraction    ${client}[Client]    ${client}[POSName]    ${SingleDate}    ${Day}    ${Month}    ${Year}    ${list_all_data}    ${SelectedLocationName}

                                    ELSE
                                        write_log_text  'Capture Sales Details From Kitchensync P3:'    'No sales during this period'     Output    log
                                        Write Status To Run Report    ${client}[Client]--${SelectedLocationName}     ${current_date}     No sales during this period.
                                        Sales No Data Extraction    ${client}[Client]    ${client}[POSName]    ${SingleDate}    ${list_all_data}    ${SelectedLocationName}
                                    END

                                END
                            ELSE
                                Log    Location not visible
                                #Write Status To Run Report    ${client}[Client]     ${current_date}     Locations not visible for this client.
                                
                                #Click on Apply button
                                Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://button[@class="btn btn--primary" and contains(text(),"Apply")]

                                #Wait Until Page Does Not Contain Element    xpath://div[@class="spinner-wrap local active"]

                                #//h2[contains(text(),"Concepts")]/following-sibling::div[@class="childscrll scroll-custom"]//div[@class="ng-star-inserted"][${i}]

                                #Select the sales option, day, date
                                Select Options    ${client}

                                #Date setting
                                Date Setting Process    ${Day}    ${Month}    ${Year}
                                #Sleep    10s

                                ${NoDataWindowVisible}=    RPA.Browser.Selenium.Is Element Visible    xpath:(//div[contains(text(),"No sales during this period")])[1]
            
                                IF    '${NoDataWindowVisible}' != 'True'
                                    #Data extraction from Gross and Net
                                    ${SelectedLocationName}=    Set Variable    ${EMPTY}
                                    ${status1}  ${reason1}   Run Keyword And Ignore Error    Sales Data Extraction    ${client}[Client]    ${client}[POSName]    ${SingleDate}    ${Day}    ${Month}    ${Year}    ${list_all_data}    ${SelectedLocationName}
                                ELSE
                                    write_log_text  'Capture Sales Details From Kitchensync P3:'    'No sales during this period'     Output    log
                                    Write Status To Run Report    ${client}[Client]     ${current_date}     No sales during this period.
                                    Sales No Data Extraction    ${client}[Client]    ${client}[POSName]    ${SingleDate}    ${list_all_data}    ${SelectedLocationName}
                                END
                            END

                        END

                    ELSE
                        #Checking if Location is visible
                        ${LocationVisible}=     RPA.Browser.Selenium.Is Element Visible    xpath://h2[contains(text(),"Locations")]

                        #If Location is visible,
                        IF    ${LocationVisible}
                            
                            #Then picking the Location count
                            ${LocationCount}=    Get Element Count    xpath://h2[contains(text(),"Locations")]/following-sibling::div[@class="childscrll scroll-custom"]//div[@class="ng-star-inserted"]

                            #Loop through the locations
                            FOR    ${j}    IN RANGE    1    ${LocationCount+1}  

                                IF    ${j} > 1
                                    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://span[contains(text(),"...")]//parent::button
                                    Sleep    2s
                                END

                                #Click on first location 
                                Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://h2[contains(text(),"Locations")]/following-sibling::div[@class="childscrll scroll-custom"]//div[@class="ng-star-inserted"][${j}]
                                Sleep    3s

                                #Store the selected Location name to a variable
                                ${SelectedLocationName}=    Get Text   xpath://h2[contains(text(),"Locations")]/following-sibling::div[@class="childscrll scroll-custom"]//div[@class="ng-star-inserted"][${j}]//span

                                #Click on Apply button
                                Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://button[@class="btn btn--primary" and contains(text(),"Apply")]
                                
                                #Wait Until Page Does Not Contain Element    xpath://div[@class="spinner-wrap local active"]

                                #Select the sales option, day, date
                                Select Options    ${client}

                                #Date setting
                                Date Setting Process    ${Day}    ${Month}    ${Year}
                                #Sleep    10s

                                ${NoDataWindowVisible}=    RPA.Browser.Selenium.Is Element Visible    xpath:(//div[contains(text(),"No sales during this period")])[1]
            
                                IF    '${NoDataWindowVisible}' != 'True'
                                    #Data extraction from Gross and Net
                                    ${status1}  ${reason1}   Run Keyword And Ignore Error    Sales Data Extraction    ${client}[Client]    ${client}[POSName]    ${SingleDate}    ${Day}    ${Month}    ${Year}    ${list_all_data}    ${SelectedLocationName}
                                ELSE
                                    write_log_text  'Capture Sales Details From Kitchensync P3:'    'No sales during this period'     Output    log
                                    Write Status To Run Report    ${client}[Client]--${SelectedLocationName}     ${current_date}     No sales during this period.
                                    Sales No Data Extraction    ${client}[Client]    ${client}[POSName]    ${SingleDate}    ${list_all_data}    ${SelectedLocationName}
                                END

                            END
                                
                        END

                        Log    Concept not visible
                        #Write Status To Run Report    ${client}[Client]     ${current_date}     Concept not visible for this client.
                    END

                ELSE
                    #Select the sales option, day, date
                    Select Options    ${client}

                    #Date setting
                    Date Setting Process    ${Day}    ${Month}    ${Year}
                    #Sleep    10s

                    ${NoDataWindowVisible}=    RPA.Browser.Selenium.Is Element Visible    xpath:(//div[contains(text(),"No sales during this period")])[1]

                    ${SelectedLocationName}=    Set Variable    ${EMPTY}

                    IF    '${NoDataWindowVisible}' != 'True'
                        #Data extraction from Gross and Net

                        ${status1}  ${reason1}   Run Keyword And Ignore Error    Sales Data Extraction    ${client}[Client]    ${client}[POSName]    ${SingleDate}    ${Day}    ${Month}    ${Year}    ${list_all_data}    ${SelectedLocationName}
                    ELSE
                        write_log_text  'Capture Sales Details From Kitchensync P3:'    'No sales during this period'     Output    log
                        Write Status To Run Report    ${client}[Client]     ${current_date}     No sales during this period.
                        Sales No Data Extraction    ${client}[Client]    ${client}[POSName]    ${SingleDate}    ${list_all_data}    ${SelectedLocationName}
                    END
                    Log    3 ... not visible
                    Write Status To Run Report    ${client}[Client]     ${current_date}     client have single concept and single location.
                END
            END
            #-------------------------------------- Snapshot and primecost report extraction ended ------------------------------------------------------------------------
            

            #-------------------------------------- CLR report extraction started ------------------------------------------------------------------------
            
            #Looping through dates between fromdate and todate for CLR extraction
            FOR    ${SingleDate}    IN    @{datelist}
                Log    ${SingleDate}
                
                #Input from date prepare and setting the date to datepicker.
                ${Day}    ${Month}    ${Year}=    Input Date Prepare     ${SingleDate}
                
                #Checking if the client has single or multiple concepts
                ${status1}  ${reason1}   Run Keyword And Ignore Error    Single Or Multiple Concepts Checking    ${Day}    ${Month}    ${Year}    ${client}[Client]    ${SingleDate}    ${client}[POSName]

            END
            #-------------------------------------- CLR report extraction ended ------------------------------------------------------------------------
            
            #Convert the dictionary to json
            Convert Dictionary To Json
        END

    ELSE
        write_log_text  'KitchensyncProcess- Select Client:'    ${client}[Client] 'Doesn't Exist In Kitchensync.'     Output    log
        Write Status To Run Report    ${client}[Client]     ${current_date}     Client Doesn't Exist In Kitchensync.
    END


*** Keywords ***
Select Client P4
    [Arguments]      ${client} 
    ${ClientStatus}=    Set Variable    False     
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Wait Until Element Is Visible    xpath://input[@type="search"]
    Sleep    2s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Input Text    xpath://input[@type="search"]    ${client}[Client]
    
    ${Result}=    RPA.Browser.Selenium.Is Element Visible    xpath://div[@class="ccbox"]
    IF    '${Result}' == 'True'
        Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://div[@class="ccbox"]
        #Wait Until Page Does Not Contain Element    xpath://div[@class="spinner-wrap local active"]
        ${ClientStatus}=    Set Variable    True
    ELSE
        ${Result}=    RPA.Browser.Selenium.Is Element Visible    xpath://div[@class="ccbox ng-star-inserted"]
        IF    '${Result}' == 'True'
            Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://div[@class="ccbox ng-star-inserted"]
            #Wait Until Page Does Not Contain Element    xpath://div[@class="spinner-wrap local active"]
            ${ClientStatus}=    Set Variable    True
        END
    END

    [Return]        ${ClientStatus}


*** Keywords ***
Select Snapshot Report
    [Arguments]    ${client}
    #Sleep    15s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Wait Until Element Is Visible    xpath://span[@title="Snapshot Reports"]
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element     xpath://span[@title="Snapshot Reports"]
    Sleep    2s
    Wait Until Page Does Not Contain Element    xpath://div[@class="spinner-wrap local active"]    timeout=90s

    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Wait Until Element Is Visible    xpath://span[contains(text(),"Gross")]

    ${gross_visible}=    RPA.Browser.Selenium.Is Element Visible    xpath://span[contains(text(),"Gross")]

    IF    ${gross_visible}
        Set Focus To Element    xpath://span[contains(text(),"Gross")]    
        Mouse Over    xpath://span[contains(text(),"Gross")]
    ELSE
        Log    Gross not visible
    END
     


*** Keywords ***
Select Options
    [Arguments]    ${client}
    #Select Sales Dropdown
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Wait Until Element Is Visible    xpath://button[@id="w-dropdown"]
    Sleep    1s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://button[@id="w-dropdown"]
    Sleep    1s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://button[@id="w-dropdown"]/following::ul//li[@name="salesReport"]
    
    Sleep    2s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element   xpath://button[@name="btnByTypeReportFilter"]
    Sleep    2s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://button[@name="btnByTypeReportFilter"]//following::ul//li//a[contains(text()," Day ")]
    Sleep    2s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://button[@id="btnDatePicker"]


*** Keywords ***
Date Setting Process
    [Arguments]    ${Day}    ${Month}    ${Year}

    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element       xpath://select[@class="custom-select"][1]
    Sleep    2s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element        xpath://select[@class="custom-select"][1]//option[contains(text(),"${Month}")]
    Sleep    2s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element        xpath://select[@class="custom-select"][2]
    Sleep    2s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element        xpath://select[@class="custom-select"][2]//option[contains(text(),"${Year}")]
    Sleep    2s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element If Visible        xpath:(//div[@class="ngb-dp-day"]//span[@class="custom-day" and contains(text()," ${Day} ")])[1]
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element If Visible        xpath://div[@class="ngb-dp-day ng-star-inserted"]//span[contains(text()," ${Day} ")]
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element If Visible        xpath://div[@class="ngb-dp-day"]//span[contains(text()," ${Day} ")]
    Sleep    4s
    #Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element If Visible        xpath:(//div[@class="ngb-dp-day ng-star-inserted"]//span[@class="custom-day ng-star-inserted" and contains(text()," ${Day} ")])[1]
    
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element        xpath://button[@name="btnRefreshReportFilter"]
    Sleep    10s
   # Wait Until Page Does Not Contain Element    xpath://div[@class="spinner-wrap local active"]

*** Keywords ***
Sales Data Extraction
    [Arguments]    ${ClientName}    ${POSName}    ${SingleDate}    ${Day}    ${Month}    ${Year}    ${list_all_data}    ${SelectedLocationName}
    Sleep    3s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Wait Until Element Is Enabled    xpath:((//div[@class="chart-result__row-label" and contains(text(),"Total Sales")])[1]//following::div[@class="chart-result__row-data"])[1]//child::div[1]//child::strong
    Sleep    3s
    ${GrossTotalSales}=    Set Variable    $0.00
    ${NetTotalSales}=    Set Variable    $0.00
    ${NetGuest}=    Set Variable    0
    ${PrimecostDiscount}=    Set Variable    $0.00

    ${GrossVisible}=    RPA.Browser.Selenium.Is Element Visible    xpath://input[@value="grossales"]/parent::label/parent::div[@class="switch__status switch__status--left current"]
    IF    ${GrossVisible}
        #Getting Gross Total Sales amount
        ${GrossTotalSales}=    Get Text   xpath:((//div[@class="chart-result__row-label" and contains(text(),"Total Sales")])[1]//following::div[@class="chart-result__row-data"])[1]//child::div[1]//child::strong
        #Click Element    xpath://input[@value="netsales"]/parent::label/parent::div[@class="switch__status switch__status--right current"]
        
        #Change Gross option to Net option
        Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element If Visible    xpath:(//div[@class="switch switch--multiple w-switch-parent flex-right"])[1]
        Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element If Visible    xpath:(//div[@class="switch switch--multiple w-switch-parent flex-right ng-star-inserted"])[1]
        Sleep    3s
        
        #Getting Net Total Sales amount
        ${NetTotalSales}=   Get Text   xpath:((//div[@class="chart-result__row-label" and contains(text(),"Total Sales")])[1]//following::div[@class="chart-result__row-data"])[1]//child::div[1]//child::strong 
        
        #Getting Net Guests amount
        ${NetGuest}=   Get Text   xpath:((//div[@class="chart-result__row-label" and contains(text(),"Guests")])[1]//following::div[@class="chart-result__row-data"])[1]//child::div[1]//strong
         Sleep    3s
    ELSE
        ${NetVisible}=    RPA.Browser.Selenium.Is Element Visible    xpath://input[@value="netsales"]/parent::label/parent::div[@class="switch__status switch__status--right current"]
        IF    ${NetVisible}
            #Getting Net Total Sales amount
            ${NetTotalSales}=   Get Text   xpath:((//div[@class="chart-result__row-label" and contains(text(),"Total Sales")])[1]//following::div[@class="chart-result__row-data"])[1]//child::div[1]//child::strong 
            
            #Getting Net Guests amount
            ${NetGuest}=   Get Text   xpath:((//div[@class="chart-result__row-label" and contains(text(),"Guests")])[1]//following::div[@class="chart-result__row-data"])[1]//child::div[1]//strong

            #Change Net option to Gross option
            Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath:(//div[@class="switch switch--multiple w-switch-parent flex-right"])[1]
            Sleep    2s

            #Getting Gross Total Sales amount
            ${GrossTotalSales}=    Get Text   xpath:((//div[@class="chart-result__row-label" and contains(text(),"Total Sales")])[1]//following::div[@class="chart-result__row-data"])[1]//child::div[1]//child::strong
            Sleep    3s
        END
    END
    
    #Select sales and click Primecost to extract discount
    ${PrimecostDiscount}=    Extract Discount From Primecost    ${Day}    ${Month}    ${Year}
    Sleep    3s
    
    #Writing the sales data to dictionary
    IF    '${SelectedLocationName}' == '${EMPTY}'
        ${list_all_data}=    sub    ${list_all_data}    ${ClientName}    ${POSName}    ${SingleDate}    ${GrossTotalSales}    ${NetTotalSales}    ${NetGuest}    ${PrimecostDiscount}    ${ClientName}_${SingleDate} 
        
        #Write the extracted Snapshot sales data to excel
        Write Sales Datas To Report    ${ClientName}    ${SingleDate}    ${GrossTotalSales}    ${NetTotalSales}    ${NetGuest}    ${PrimecostDiscount} 

    ELSE
        ${list_all_data}=    sub    ${list_all_data}    ${ClientName}--${SelectedLocationName}    ${POSName}    ${SingleDate}    ${GrossTotalSales}    ${NetTotalSales}    ${NetGuest}    ${PrimecostDiscount}    ${ClientName}--${SelectedLocationName}_${SingleDate} 

        #Write the extracted Snapshot sales data to excel
        Write Sales Datas To Report    ${ClientName}--${SelectedLocationName}    ${SingleDate}    ${GrossTotalSales}    ${NetTotalSales}    ${NetGuest}    ${PrimecostDiscount} 
    END


*** Keywords ***
Sales No Data Extraction
    [Arguments]    ${ClientName}    ${POSName}    ${SingleDate}    ${list_all_data}    ${SelectedLocationName}    
    
    ${GrossZeroSales}=    Set Variable    $0.00
    ${NetZeroSales}=    Set Variable    $0.00
    ${NetZeroGuest}=    Set Variable    0
    ${PrimecostZeroDiscount}=    Set Variable    $0.00

    #Writing the sales data to dictionary
    IF    '${SelectedLocationName}' == '${EMPTY}'
        ${list_all_data}=    sub    ${list_all_data}    ${ClientName}    ${POSName}    ${SingleDate}    ${GrossZeroSales}    ${NetZeroSales}    ${NetZeroGuest}    ${PrimecostZeroDiscount}    ${ClientName}_${SingleDate} 
        
        #Write the extracted Snapshot sales data to excel
        Write Sales Datas To Report    ${ClientName}    ${SingleDate}    ${GrossZeroSales}    ${NetZeroSales}    ${NetZeroGuest}    ${PrimecostZeroDiscount} 

    ELSE
        ${list_all_data}=    sub    ${list_all_data}    ${ClientName}--${SelectedLocationName}    ${POSName}    ${SingleDate}    ${GrossZeroSales}    ${NetZeroSales}    ${NetZeroGuest}    ${PrimecostZeroDiscount}    ${ClientName}--${SelectedLocationName}_${SingleDate} 

        #Write the extracted Snapshot sales data to excel
        Write Sales Datas To Report    ${ClientName}--${SelectedLocationName}    ${SingleDate}    ${GrossZeroSales}    ${NetZeroSales}    ${NetZeroGuest}    ${PrimecostZeroDiscount} 
    END


*** Keywords ***
Extract Discount From Primecost
    [Arguments]    ${Day}    ${Month}    ${Year}
    #Select Sales Dropdown
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Wait Until Element Is Visible    xpath://button[@id="w-dropdown"]
    Sleep    1s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://button[@id="w-dropdown"]
    Sleep    1s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://button[@id="w-dropdown"]/following::ul//li[@name="primeCostReport"]
    
    Sleep    2s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element   xpath://button[@name="btnByTypeReportFilter"]
    Sleep    2s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://button[@name="btnByTypeReportFilter"]//following::ul//li//a[contains(text()," Day ")]
    Sleep    2s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://button[@id="btnDatePicker"]
    
    #Need to set date once again. So calling the same keyword
    Date Setting Process    ${Day}    ${Month}    ${Year}
    #Sleep    10s

    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Wait Until Element Is Visible    xpath:(//div[@class="chart-result__row-label" and contains(text(),"Discounts ")]/following-sibling::div/child::div)[2]
    Sleep    2s
    ${PrimecostDiscount}=   Get Text    xpath:(//div[@class="chart-result__row-label" and contains(text(),"Discounts ")]/following-sibling::div/child::div)[2]

    [Return]    ${PrimecostDiscount}



*** Keywords ***
Single Or Multiple Concepts Checking
    [Arguments]    ${Day}    ${Month}    ${Year}    ${ClientName}    ${SingleDate}    ${POSName}

    #Check the client has single concept with multiple locations by checking if the Internal tab exist or not in the left menu.
    #${InternExist}=    RPA.Browser.Selenium.Is Element Visible    xpath:(//span[contains(text(),"Internal")]/preceding-sibling::span/parent::li)[1]
    
    ${InternExist}=    RPA.Browser.Selenium.Is Element Visible    xpath:(//span[(contains(text(),'Internal')) and not(contains(text(),'Internal Reports'))]/preceding-sibling::span/parent::li)[1]
    
    #Client has single concept, but may have multiple locations
    IF    ${InternExist}
        
        #Setting the date for CLR report extracting
        CLR Data Extracting Common Steps    ${Day}    ${Month}    ${Year}

        #Checking if the client have multiple locations or not
        ${3DotsVisible}=     RPA.Browser.Selenium.Is Element Visible    xpath://span[contains(text(),"...")]
            
        #If multiple locations visible,
        IF    ${3DotsVisible}  
            
            #Click on the location box ...
            Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://span[contains(text(),"...")]//parent::button
            Sleep    2s

            #Then picking the Location count
            ${LocationCount}=    Get Element Count    xpath://h2[contains(text(),"Locations")]/following-sibling::div[@class="childscrll scroll-custom"]//div[@class="ng-star-inserted"]
            
            #Loop through the locations
            FOR    ${k}    IN RANGE    1    ${LocationCount+1}

                #Untick previously selected option
                IF    ${k} > 1

                    #Click on the location box ...
                    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://span[contains(text(),"...")]//parent::button
                    Sleep    2s

                    #Click on first location 
                    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://h2[contains(text(),"Locations")]/following-sibling::div[@class="childscrll scroll-custom"]//div[@class="ng-star-inserted"][${k-1}]//label[@class="checkbox__pseudo-check"]
                    Sleep    2s
                END

                #Click on first location 
                Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://h2[contains(text(),"Locations")]/following-sibling::div[@class="childscrll scroll-custom"]//div[@class="ng-star-inserted"][${k}]//label[@class="checkbox__pseudo-check"]
                Sleep    2s

                #Click on Apply button
                Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://button[@class="btn btn--primary" and contains(text(),"Apply")]
                
                #Wait Until Page Does Not Contain Element    xpath://div[@class="spinner-wrap local active"]
                
                #Click on Refresh Button
                Refresh Button Click
                #Sleep    10s    
                Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Wait Until Element Is Visible    xpath://p-table[@id="mainTalbe"]
                
                #Extract The CLR Report
                ${status1}  ${reason1}   Run Keyword And Ignore Error    Extract The CLR Report As Table    ${ClientName}    ${POSName}    ${SingleDate}    yes

            END
        ELSE
            #Click on Refresh Button
            Refresh Button Click
            #Sleep    10s
            Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Wait Until Element Is Visible    xpath://p-table[@id="mainTalbe"]
            #Extract The CLR Report
            ${status1}  ${reason1}   Run Keyword And Ignore Error    Extract The CLR Report As Table    ${ClientName}    ${POSName}    ${SingleDate}    No
        END
    ELSE
        Download The CLR Report For Multiple Concept    ${Day}    ${Month}    ${Year}    ${ClientName}    ${POSName}    ${SingleDate}
    END


*** Keywords ***
CLR Data Extracting Common Steps
    [Arguments]    ${Day}    ${Month}    ${Year}
    #Click on Internal
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath:(//span[(contains(text(),'Internal ')) and not(contains(text(),'Internal Reports'))])[1]//..//parent::li
    Sleep    3s
    
    #Click on Sales Validation In case of single concept
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element If Visible    xpath:(//div[contains(text(),"Sales Validation ")])[1]/parent::li
    
    #Click on Sales Validation In case of multiple concept
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element If Visible    xpath:(//a[contains(text()," Sales Validation ")])[1]/parent::li

    #Wait Until Page Does Not Contain Element    xpath://div[@class="spinner-wrap local active"]
    
    Datepicker Setting In UI    ${Day}    ${Month}    ${Year}    1

    Datepicker Setting In UI    ${Day}    ${Month}    ${Year}    2



*** Keywords ***
Refresh Button Click
    Sleep    2s
    #Click on the refresh button
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://button[contains(text(),"Refresh")]
    Sleep    5s

    ${spinner_visible}=     RPA.Browser.Selenium.Is Element Visible    xpath://div[@class="spinner-wrap local active"]
    IF    ${spinner_visible}
        Wait Until Page Does Not Contain Element    xpath://div[@class="spinner-wrap local active"]    timeout=90s
    END 



*** Keywords ***
Datepicker Setting In UI
    [Arguments]    ${Day}    ${Month}    ${Year}    ${DateOption}
    
    ${DayInt} =	Convert To Integer	${Day}

    IF    ${DayInt} < 10
        ${Day}    add_leading_zero    ${Day}
    END

    #Click on Date picker
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath:(//div[@class="dp-input-container"]//input)[${DateOption}]
    Sleep    2s
    
    #Select the date main option
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath:(//button[@class="dp-nav-header-btn"])[${DateOption}]
    Sleep    2s
    
    #Select the month
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element If Visible    xpath:(//div[@class="dp-calendar-wrapper"])[${DateOption}]//button[@class="dp-calendar-month" and contains(text(),"${Month}")]
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element If Visible    xpath:(//div[@class="dp-calendar-wrapper"])[${DateOption}]//button[@class="dp-calendar-month ng-star-inserted" and contains(text(),"${Month}")]
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element If Visible    xpath:(//div[@class="dp-calendar-wrapper"])[${DateOption}]//button[@class="dp-calendar-month dp-current-month ng-star-inserted" and contains(text(),"${Month}")]
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element If Visible    xpath:(//div[@class="dp-calendar-wrapper"])[${DateOption}]//button[@class="dp-calendar-month dp-current-month" and contains(text(),"${Month}")]
    Sleep    2s

    #Select the day
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element If Visible    xpath:(//div[@class="dp-weekdays"]//following::button[@class="dp-calendar-day dp-current-month" and contains(text(),"${Day}")])[1]
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element If Visible    xpath:(//div[@class="dp-weekdays"]//following::button[@class="dp-calendar-day dp-current-month ng-star-inserted" and contains(text(),"${Day}")])[1]
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element If Visible    xpath:(//div[@class="dp-weekdays"]//following::button[@class="dp-calendar-day dp-current-month" and contains(text(),"${Day}")])[1]
    Sleep    2s

*** Keywords ***
Download The CLR Report For Multiple Concept
    [Arguments]    ${Day}    ${Month}    ${Year}    ${ClientName}    ${POSName}    ${SingleDate}
     
    ${LiCount}=    Get Element Count    xpath:(//p[@class="ul-parent-title capital" and contains(text(),"CROSS LOCATION REPORTS")]//following-sibling::ul)[1]//li
    IF    ${LiCount} > 0
        FOR    ${i}    IN RANGE    1    ${LiCount+1}

            Click Element    xpath:((//p[@class="ul-parent-title capital" and contains(text(),"CROSS LOCATION REPORTS")]//following-sibling::ul)[1]//li)[${i}]        
            
            CLR Data Extracting Common Steps     ${Day}    ${Month}    ${Year} 

            #Checking if the client have multiple locations or not
            ${3DotsVisible}=     RPA.Browser.Selenium.Is Element Visible    xpath://span[contains(text(),"...")]

            #If multiple locations visible,
            IF    ${3DotsVisible}

                #Click on the location box ...
                Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://span[contains(text(),"...")]//parent::button
                Sleep    2s

                #Then picking the Location count
                ${LocationCount}=    Get Element Count    xpath://h2[contains(text(),"Locations")]/following-sibling::div[@class="childscrll scroll-custom"]//div[@class="ng-star-inserted"]

                #Loop through the locations
                FOR    ${k}    IN RANGE    1    ${LocationCount+1}

                    #Untick previously selected option
                    IF    ${k} > 1

                        #Click on the location box ...
                        Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://span[contains(text(),"...")]//parent::button
                        Sleep    2s

                        #Click on first location 
                        Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://h2[contains(text(),"Locations")]/following-sibling::div[@class="childscrll scroll-custom"]//div[@class="ng-star-inserted"][${k-1}]//label[@class="checkbox__pseudo-check"]
                        Sleep    2s
                    END

                    #Click on first location 
                    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://h2[contains(text(),"Locations")]/following-sibling::div[@class="childscrll scroll-custom"]//div[@class="ng-star-inserted"][${k}]//label[@class="checkbox__pseudo-check"]
                    Sleep    2s

                    #Click on Apply button
                    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://button[@class="btn btn--primary" and contains(text(),"Apply")]
                    
                    #Wait Until Page Does Not Contain Element    xpath://div[@class="spinner-wrap local active"]
                    
                    #Click on Refresh Button
                    Refresh Button Click
                    #Sleep    10s    
                    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Wait Until Element Is Visible    xpath://p-table[@id="mainTalbe"]
                    #Extract The CLR Report
                    ${status1}  ${reason1}   Run Keyword And Ignore Error    Extract The CLR Report As Table    ${ClientName}    ${POSName}    ${SingleDate}    yes

                END
            ELSE
                #Click on Refresh Button
                Refresh Button Click
                #Sleep    10s
                Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Wait Until Element Is Visible    xpath://p-table[@id="mainTalbe"]
                #Extract The CLR Report
                ${status1}  ${reason1}   Run Keyword And Ignore Error    Extract The CLR Report As Table    ${ClientName}    ${POSName}    ${SingleDate}    No
            END
            
            #Clicking the Back button to pick next date
            Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath:(//li[@class="sidepanel-li"])[7]
            Sleep    2s
            Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath:(//li[@class="sidepanel-li"])[6]
            Sleep    2s
        END
    ELSE
        Log    Client have single concept
        write_log_text  'KitchensyncProcess- Download The CLR Report For Multiple Concept:'    ${ClientName} 'Doesn't Exist In Kitchensync.'     Output    log
        Write Status To Run Report    ${ClientName}     ${SingleDate}     Client have single concept.
    END


*** Keywords ***
Download The CLR Report
    #Clicking export
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://span[contains(text(),"Export")]
    Sleep    3s
    #Clicking As Excel option
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://li//a[contains(text(),"As Excel ")]


*** Keywords ***
Extract The CLR Report As Table
    [Arguments]    ${ClientName}    ${POSName}    ${SingleDate}    ${LocationExist}
    Sleep    3s
    ${rate_html_table}=    Get Element Attribute    xpath://p-table[@id="mainTalbe"]    outerHTML
    ${table}=    Read Table From Html    ${rate_html_table}
    
    ${ClientNameStr}=    Set Variable    ${EMPTY}
    ${GrossSales}=    Set Variable    $0.00
    ${NetSales}=    Set Variable    $0.00
    ${GuestCount}=    Set Variable    0
    ${Discount}=    Set Variable    $0.00
    ${i}=    Set Variable    ${0}

    FOR    ${row}    IN    @{table}
        ${i}=    Set Variable    ${i+1}
        Log    ${row[0]}
        IF    ${i} == 1
            ${ClientNameStr}=    Set Variable   ${row[0]}
        END
        IF    ${i} == 3
            ${GrossSales}=    Set Variable      ${row[0]}  
            ${NetSales}=    Set Variable    ${row[1]}
            ${GuestCount}=    Set Variable    ${row[2]}
            ${Discount}=    Set Variable    ${row[3]}    
        END
    END
    ${GuestCount}    remove_percentage    ${GuestCount}

    Log    ${ClientNameStr}
    Log    ${POSName}
    Log    ${list_all_data}  
    Log    ${GrossSales}    
    Log    ${NetSales}    
    Log    ${GuestCount}   
    Log    ${Discount}    
    Log    ${ClientName}--${ClientNameStr}
    Log    ${ClientName}--${ClientNameStr}_${SingleDate}

    IF    '${LocationExist}' == 'yes'
        ${list_all_data}=    dictionary_check    ${list_all_data}    ${ClientName}--${ClientNameStr}    ${POSName}    ${SingleDate}    ${GrossSales}    ${NetSales}    ${GuestCount}    ${Discount}    ${ClientName}--${ClientNameStr}_${SingleDate}

        #Write the extracted CLR sales data to excel
        Write Sales Datas To CLR Report    ${ClientName}--${ClientNameStr}    ${SingleDate}    ${GrossSales}    ${NetSales}    ${GuestCount}    ${Discount} 

    ELSE
        ${list_all_data}=    dictionary_check    ${list_all_data}    ${ClientName}    ${SingleDate}    ${POSName}    ${GrossSales}    ${NetSales}    ${GuestCount}    ${Discount}    ${ClientName}_${SingleDate}

        #Write the extracted CLR sales data to excel
        Write Sales Datas To CLR Report    ${ClientName}    ${SingleDate}    ${GrossSales}    ${NetSales}    ${GuestCount}    ${Discount} 

    END
    Sleep    5s



*** Keywords ***
Convert Dictionary To Json
    write_json    ${list_all_data}    ${JsonFilePath}

    # ${table}=  Create Table  ${list_all_data}
    # Open Workbook    ${OutputSheetPath}
    # Append Rows To Worksheet    ${table}  header=True
    # Save Workbook
    # Close Workbook


*** Keywords ***
Logout Insight
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://button[@id="profile-btn"]

    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://a[@class="main-menu__profile-menu-item"]

    Sleep    2s

    Close All Browsers

        



    

    

