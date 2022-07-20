*** Settings ***
Documentation       Kitchensync Process
Library             RPA.Browser.Selenium
Library             Log
Library             html_tables
Library             Excel_Operations
Library             Functions
Library             DateManipulation
Library             String
Library             DateTime
Resource            ExcelActivities.robot
Resource            KitchensyncProcess.robot
Resource            Functions.robot
Library             RPA.Tables

*** Keywords ***
Monthly Sales Validation Process
    [Arguments]        ${client}
    #-------------------------------------- Snapshot and primecost report extraction started ------------------------------------------------------------------------
        
    #Looping through dates between fromdate and todate
    #FOR    ${SingleDate}    IN    @{datelist}
        #Log    ${SingleDate}
        
        #----------Prepare the from_date and to_date for the process. Current format is "May 31 - Jun 27". 
        #          Need to change this date format to 05/31/2022 and 06/27/2022 --------------

        ${from_date}    ${to_date}    date_convert_to_date    ${client}[FromRange]    ${client}[ToRange]   ${client}[Year]

        #Input from date prepare and set the date to datepicker in UI
        ${Day}    ${Month}    ${Year}=    Input Date Prepare     ${from_date}
        ${ToDay}    ${ToMonth}    ${ToYear}=    Input Date Prepare     ${to_date}
        

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
                            Sleep    3s
                            ${spinner_visible}=     RPA.Browser.Selenium.Is Element Visible    xpath://div[@class="spinner-wrap local active"]
                            IF    ${spinner_visible}
                                Wait Until Page Does Not Contain Element    xpath://div[@class="spinner-wrap local active"]    timeout=90s
                            END 

                            #Select the sales option, day, date
                            Select Month Options    ${client}

                            #Month setting
                            Month Setting Process    ${Day}    ${Month}    ${Year}    ${client}
                            #Sleep    10s

                            ${NoDataWindowVisible}=    RPA.Browser.Selenium.Is Element Visible    xpath:(//div[contains(text(),"No sales during this period")])[1]
        
                            IF    '${NoDataWindowVisible}' != 'True'
                                #Data extraction from Gross and Net option
                                ${status1}  ${reason1}   Run Keyword And Ignore Error    Monthly Sales Data Extraction    ${client}[Client]    ${client}[POSName]    ${from_date}    ${to_date}    ${Day}    ${Month}    ${Year}    ${list_all_data}    ${SelectedLocationName}    ${client}

                            ELSE
                                write_log_text  'Capture Sales Details From Kitchensync P3:'    'No sales during this period'     Output    log
                                Write Status To Run Report    ${client}[Client]--${SelectedLocationName}     ${from_date}-${to_date}     No sales during this period.

                                Monthly Sales No Data Extraction    ${client}[Client]    ${client}[POSName]    ${from_date}    ${to_date}    ${list_all_data}    ${SelectedLocationName}
                            END

                        END
                    ELSE
                        Log    Location not visible
                        #Write Status To Run Report    ${client}[Client]     ${current_date}     Locations not visible for this client.
                        
                        #Click on Apply button
                        Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://button[@class="btn btn--primary" and contains(text(),"Apply")]

                        ${spinner_visible}=     RPA.Browser.Selenium.Is Element Visible    xpath://div[@class="spinner-wrap local active"]
                        IF    ${spinner_visible}
                            Wait Until Page Does Not Contain Element    xpath://div[@class="spinner-wrap local active"]    timeout=90s
                        END 

                        #//h2[contains(text(),"Concepts")]/following-sibling::div[@class="childscrll scroll-custom"]//div[@class="ng-star-inserted"][${i}]

                        #Select the sales option, month, date
                        Select Month Options    ${client}

                        #Month setting
                        Month Setting Process    ${Day}    ${Month}    ${Year}    ${client}
                        #Sleep    10s

                        ${NoDataWindowVisible}=    RPA.Browser.Selenium.Is Element Visible    xpath:(//div[contains(text(),"No sales during this period")])[1]
    
                        IF    '${NoDataWindowVisible}' != 'True'
                            #Data extraction from Gross and Net
                            ${SelectedLocationName}=    Set Variable    ${EMPTY}
                            ${status1}  ${reason1}   Run Keyword And Ignore Error    Monthly Sales Data Extraction    ${client}[Client]    ${client}[POSName]    ${from_date}    ${to_date}    ${Day}    ${Month}    ${Year}    ${list_all_data}    ${SelectedLocationName}    ${client}
                        ELSE
                            write_log_text  'Capture Sales Details From Kitchensync P3:'    'No sales during this period'     Output    log
                            Write Status To Run Report    ${client}[Client]     ${from_date}-${to_date}     No sales during this period.

                            Monthly Sales No Data Extraction    ${client}[Client]    ${client}[POSName]    ${from_date}    ${to_date}    ${list_all_data}    ${SelectedLocationName}
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
                        Sleep    2s

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
                        Sleep    3s
                        ${spinner_visible}=     RPA.Browser.Selenium.Is Element Visible    xpath://div[@class="spinner-wrap local active"]
                        IF    ${spinner_visible}
                            Wait Until Page Does Not Contain Element    xpath://div[@class="spinner-wrap local active"]    timeout=90s
                        END 

                        #Select the sales option, month, date
                        Select Month Options    ${client}

                        #Month setting
                        Month Setting Process    ${Day}    ${Month}    ${Year}    ${client}
                        #Sleep    10s

                        ${NoDataWindowVisible}=    RPA.Browser.Selenium.Is Element Visible    xpath:(//div[contains(text(),"No sales during this period")])[1]
    
                        IF    '${NoDataWindowVisible}' != 'True'
                            #Data extraction from Gross and Net
                            ${status1}  ${reason1}   Run Keyword And Ignore Error    Monthly Sales Data Extraction    ${client}[Client]    ${client}[POSName]    ${from_date}    ${to_date}    ${Day}    ${Month}    ${Year}    ${list_all_data}    ${SelectedLocationName}    ${client}
                        ELSE
                            write_log_text  'Capture Sales Details From Kitchensync P3:'    'No sales during this period'     Output    log
                            Write Status To Run Report    ${client}[Client]--${SelectedLocationName}     ${from_date}-${to_date}     No sales during this period.

                            Monthly Sales No Data Extraction    ${client}[Client]    ${client}[POSName]    ${from_date}    ${to_date}    ${list_all_data}    ${SelectedLocationName}
                        END

                    END
                        
                END

                Log    Concept not visible
                Write Status To Run Report    ${client}[Client]     ${from_date}-${to_date}     Concept not visible for this client.
            END

        ELSE
            #Select the sales option, month, date
            Select Month Options    ${client}

            #Month setting
            Month Setting Process    ${Day}    ${Month}    ${Year}    ${client}
            #Sleep    10s

            ${NoDataWindowVisible}=    RPA.Browser.Selenium.Is Element Visible    xpath:(//div[contains(text(),"No sales during this period")])[1]

            ${SelectedLocationName}=    Set Variable    ${EMPTY}

            IF    '${NoDataWindowVisible}' != 'True'
                #Data extraction from Gross and Net
                ${status1}  ${reason1}   Run Keyword And Ignore Error    Monthly Sales Data Extraction    ${client}[Client]    ${client}[POSName]    ${from_date}    ${to_date}    ${Day}    ${Month}    ${Year}    ${list_all_data}    ${SelectedLocationName}    ${client}
            ELSE
                write_log_text  'Capture Sales Details From Kitchensync P3:'    'No sales during this period'     Output    log
                Write Status To Run Report    ${client}[Client]     ${from_date}-${to_date}     No sales during this period.

                Monthly Sales No Data Extraction    ${client}[Client]    ${client}[POSName]    ${from_date}    ${to_date}    ${list_all_data}    ${SelectedLocationName}
            END
            Log    3 ... not visible
            Write Status To Run Report    ${client}[Client]     ${from_date}-${to_date}     client have single concept and single location.
        END
    #END
    #-------------------------------------- Snapshot and primecost report extraction ended ------------------------------------------------------------------------


    #-------------------------------------- CLR report extraction started ------------------------------------------------------------------------
        
        #Looping through dates between fromdate and todate for CLR extraction
        #FOR    ${SingleDate}    IN    @{datelist}
            #Log    ${SingleDate}
            
            #Checking if the client has single or multiple concepts
            ${status1}  ${reason1}   Run Keyword And Ignore Error    Single Or Multiple Concepts Checking For Monthly Report    ${from_date}    ${client}[Client]    ${to_date}    ${client}[POSName]

        #END
        #-------------------------------------- CLR report extraction ended ------------------------------------------------------------------------
        
        #Convert the dictionary to json
        Convert Dictionary To Json


*** Keywords ***
Select Month Options
    [Arguments]    ${client}
    #Select Sales Dropdown
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Wait Until Element Is Visible    xpath://button[@id="w-dropdown"]
    Sleep    1s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://button[@id="w-dropdown"]
    Sleep    1s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://button[@id="w-dropdown"]/following::ul//li[@name="salesReport"]
    
    ${spinner_visible}=     RPA.Browser.Selenium.Is Element Visible    xpath://div[@class="spinner-wrap local active"]
    IF    ${spinner_visible}
        Wait Until Page Does Not Contain Element    xpath://div[@class="spinner-wrap local active"]    timeout=90s
    END 
    
    Sleep    2s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element   xpath://button[@name="btnByTypeReportFilter"]
    Sleep    2s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://button[@name="btnByTypeReportFilter"]//following::ul//li//a[contains(text()," Period ")]
    Sleep    2s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://span[@id="monthdropdown"]

    #//div[@class="popover w-dropdown under right subheader_drpdwm"]


*** Keywords ***
Month Setting Process
    [Arguments]    ${Day}    ${Month}    ${Year}    ${client}
    #From Month and year setting
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element       xpath://select[@name="fromYearSelectPeriodReport"]
    Sleep    2s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element        xpath://select[@name="fromYearSelectPeriodReport"]/option[contains(text()," ${client}[Year] ")]
    Sleep    2s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element        xpath://select[@name="fromMonthSelectPeriodReport"]
    Sleep    2s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element        xpath://select[@name="fromMonthSelectPeriodReport"]/option[contains(text()," ${client}[FromRange] ")]
    Sleep    2s
    
    #To month and year setting
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element       xpath://select[@name="toYearSelectPeriodReport"]
    Sleep    2s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element        xpath://select[@name="toYearSelectPeriodReport"]/option[contains(text()," ${client}[Year] ")]
    Sleep    2s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element        xpath://select[@name="toMonthSelectPeriodReport"]
    Sleep    2s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element        xpath://select[@name="toMonthSelectPeriodReport"]/option[contains(text()," ${client}[FromRange] ")]
    Sleep    3s 

    ${spinner_visible}=     RPA.Browser.Selenium.Is Element Visible    xpath://div[@class="spinner-wrap local active"]
    IF    ${spinner_visible}
        Wait Until Page Does Not Contain Element    xpath://div[@class="spinner-wrap local active"]    timeout=120s
    END
    #Sleep    20s  

    #Click the refresh button  
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element        xpath://button[@name="btnRefreshReportFilter"]
    Sleep    3s
    ${spinner_visible}=     RPA.Browser.Selenium.Is Element Visible    xpath://div[@class="spinner-wrap local active"]
    IF    ${spinner_visible}
        Wait Until Page Does Not Contain Element    xpath://div[@class="spinner-wrap local active"]    timeout=90s
    END 


*** Keywords ***
Monthly Sales Data Extraction
    [Arguments]    ${ClientName}    ${POSName}    ${from_date}    ${to_date}    ${Day}    ${Month}    ${Year}    ${list_all_data}    ${SelectedLocationName}    ${client}
    Sleep    3s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Wait Until Element Is Enabled    xpath:((//div[@class="chart-result__row-label" and contains(text(),"Total Sales")])[1]//following::div[@class="chart-result__row-data"])[1]//child::div[1]//child::strong
    Sleep    2s
    ${GrossTotalSales}=    Set Variable    $0.00
    ${NetTotalSales}=    Set Variable    $0.00
    ${NetGuest}=    Set Variable    0
    ${PrimecostDiscount}=    Set Variable    $0.00

    ${GrossVisible}=    RPA.Browser.Selenium.Is Element Visible    xpath://input[@value="grossales"]/parent::label/parent::div[@class="switch__status switch__status--left current"]
    Sleep    2s
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
        Sleep    2s
        ${NetVisible}=    RPA.Browser.Selenium.Is Element Visible    xpath://input[@value="netsales"]/parent::label/parent::div[@class="switch__status switch__status--right current"]
        Sleep    1s
        IF    ${NetVisible}
            #Getting Net Total Sales amount
            ${NetTotalSales}=   Get Text   xpath:((//div[@class="chart-result__row-label" and contains(text(),"Total Sales")])[1]//following::div[@class="chart-result__row-data"])[1]//child::div[1]//child::strong 
            Sleep    2s

            #Getting Net Guests amount
            ${NetGuest}=   Get Text   xpath:((//div[@class="chart-result__row-label" and contains(text(),"Guests")])[1]//following::div[@class="chart-result__row-data"])[1]//child::div[1]//strong
            Sleep    3s

            #Change Net option to Gross option
            Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element If Visible    xpath:(//div[@class="switch switch--multiple w-switch-parent flex-right"])[1]
            Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element If Visible    xpath:(//div[@class="switch switch--multiple w-switch-parent flex-right ng-star-inserted"])[1]
            Sleep    2s

            #Getting Gross Total Sales amount
            ${GrossTotalSales}=    Get Text   xpath:((//div[@class="chart-result__row-label" and contains(text(),"Total Sales")])[1]//following::div[@class="chart-result__row-data"])[1]//child::div[1]//child::strong
            Sleep    3s
        END
    END
    
    #Select sales and click Primecost to extract discount
    ${PrimecostDiscount}=    Extract Monthly Discount From Primecost    ${Day}    ${Month}    ${Year}    ${client}
    Sleep    3s
    
    #Writing the sales data to dictionary
    IF    '${SelectedLocationName}' == '${EMPTY}'
        ${list_all_data}=    sales_data_writing    ${list_all_data}    ${ClientName}    ${POSName}    ${from_date}    ${to_date}    ${GrossTotalSales}    ${NetTotalSales}    ${NetGuest}    ${PrimecostDiscount}    ${ClientName}_${from_date} 
        
        #Write the extracted Snapshot sales data to excel
        #Write Sales Datas To Report    ${ClientName}    ${from_date}    ${to_date}    ${GrossTotalSales}    ${NetTotalSales}    ${NetGuest}    ${PrimecostDiscount} 

    ELSE
        ${list_all_data}=    sales_data_writing    ${list_all_data}    ${ClientName}--${SelectedLocationName}    ${POSName}    ${from_date}    ${to_date}    ${GrossTotalSales}    ${NetTotalSales}    ${NetGuest}    ${PrimecostDiscount}    ${ClientName}--${SelectedLocationName}_${from_date} 

        #Write the extracted Snapshot sales data to excel
        #Write Sales Datas To Report    ${ClientName}--${SelectedLocationName}    ${from_date}    ${to_date}    ${GrossTotalSales}    ${NetTotalSales}    ${NetGuest}    ${PrimecostDiscount} 
    END


*** Keywords ***
Monthly Sales No Data Extraction
    [Arguments]    ${ClientName}    ${POSName}    ${from_date}    ${to_date}    ${list_all_data}    ${SelectedLocationName}    
    
    ${GrossZeroSales}=    Set Variable    $0.00
    ${NetZeroSales}=    Set Variable    $0.00
    ${NetZeroGuest}=    Set Variable    0
    ${PrimecostZeroDiscount}=    Set Variable    $0.00

    #Writing the sales data to dictionary
    IF    '${SelectedLocationName}' == '${EMPTY}'
        ${list_all_data}=    sales_data_writing    ${list_all_data}    ${ClientName}    ${POSName}    ${from_date}    ${to_date}    ${GrossZeroSales}    ${NetZeroSales}    ${NetZeroGuest}    ${PrimecostZeroDiscount}    ${ClientName}_${from_date}
        
        #Write the extracted Snapshot sales data to excel
        Write Sales Datas To Report    ${ClientName}    ${from_date}-${to_date}    ${GrossZeroSales}    ${NetZeroSales}    ${NetZeroGuest}    ${PrimecostZeroDiscount} 

    ELSE
        ${list_all_data}=    sales_data_writing    ${list_all_data}    ${ClientName}--${SelectedLocationName}    ${POSName}    ${from_date}    ${to_date}    ${GrossZeroSales}    ${NetZeroSales}    ${NetZeroGuest}    ${PrimecostZeroDiscount}    ${ClientName}--${SelectedLocationName}_${from_date}

        #Write the extracted Snapshot sales data to excel
        Write Sales Datas To Report    ${ClientName}--${SelectedLocationName}    ${from_date}-${to_date}    ${GrossZeroSales}    ${NetZeroSales}    ${NetZeroGuest}    ${PrimecostZeroDiscount} 
    END


*** Keywords ***
Extract Monthly Discount From Primecost
    [Arguments]    ${Day}    ${Month}    ${Year}    ${client}
    #Select Sales Dropdown
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Wait Until Element Is Visible    xpath://button[@id="w-dropdown"]
    Sleep    1s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://button[@id="w-dropdown"]
    Sleep    1s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://button[@id="w-dropdown"]/following::ul//li[@name="primeCostReport"]
    Sleep    3s
    
    ${spinner_visible}=     RPA.Browser.Selenium.Is Element Visible    xpath://div[@class="spinner-wrap local active"]
    IF    ${spinner_visible}
        Wait Until Page Does Not Contain Element    xpath://div[@class="spinner-wrap local active"]    timeout=120s
    END    
    #Sleep    20s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element   xpath://button[@name="btnByTypeReportFilter"]
    Sleep    2s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://button[@name="btnByTypeReportFilter"]//following::ul//li//a[contains(text()," Period ")]
    Sleep    2s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://span[@id="monthdropdown"]
    
    #Need to set date once again. So calling the same keyword
    Month Setting Process    ${Day}    ${Month}    ${Year}    ${client}
    #Sleep    10s
    Sleep    3s

    #Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Wait Until Element Is Visible    xpath:(//div[@class="chart-result__row-label" and contains(text(),"Discounts ")]/following-sibling::div/child::div)[2]
    ${discount_visible}=    RPA.Browser.Selenium.Is Element Visible    xpath:(//div[@class="chart-result__row-label" and contains(text(),"Discounts ")]/following-sibling::div/child::div)[2]
    IF    ${discount_visible}
        ${PrimecostDiscount}=   Get Text    xpath:(//div[@class="chart-result__row-label" and contains(text(),"Discounts ")]/following-sibling::div/child::div)[2]
    ELSE
        ${cogs_visible}=    RPA.Browser.Selenium.Is Element Visible    xpath:(//div[@class="chart-result__row-label" and contains(text(),"COGS ")]/following-sibling::div/child::div)[2]
        IF    ${cogs_visible}
            ${PrimecostDiscount}=   Get Text    xpath:(//div[@class="chart-result__row-label" and contains(text(),"COGS ")]/following-sibling::div/child::div)[2]
        ELSE
            ${PrimecostDiscount}=    Set Variable    $0.00
        END
    END

    [Return]    ${PrimecostDiscount}
    


*** Keywords ***
Single Or Multiple Concepts Checking For Monthly Report
    [Arguments]     ${from_date}   ${ClientName}    ${to_date}    ${POSName}

    #Check the client has single concept with multiple locations by checking if the Internal tab exist or not in the left menu.
    #${InternExist}=    RPA.Browser.Selenium.Is Element Visible    xpath:(//span[contains(text(),"Internal")]/preceding-sibling::span/parent::li)[1]
    
    ${InternExist}=    RPA.Browser.Selenium.Is Element Visible    xpath:(//span[(contains(text(),'Internal')) and not(contains(text(),'Internal Reports'))]/preceding-sibling::span/parent::li)[1]
    
    #Client has single concept, but may have multiple locations
    IF    ${InternExist}
        
        #Setting the date for CLR report extracting
        CLR Data Extracting Common Steps For Monthly Report    ${from_date}    ${to_date}

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
                
                ${spinner_visible}=     RPA.Browser.Selenium.Is Element Visible    xpath://div[@class="spinner-wrap local active"]
                IF    ${spinner_visible}
                    Wait Until Page Does Not Contain Element    xpath://div[@class="spinner-wrap local active"]    timeout=90s
                END 
                
                #Click on Refresh Button
                Refresh Button Click
                
                #Sleep    10s    
                Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Wait Until Element Is Visible    xpath://p-table[@id="mainTalbe"]
                
                #Extract The CLR Report
                ${status1}  ${reason1}   Run Keyword And Ignore Error    Extract The Monthly CLR Report As Table    ${ClientName}    ${POSName}    ${from_date}    ${to_date}    yes

            END
        ELSE
            #Click on Refresh Button
            Refresh Button Click
            
            #Sleep    10s
            Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Wait Until Element Is Visible    xpath://p-table[@id="mainTalbe"]
            
            #Extract The CLR Report
            ${status1}  ${reason1}   Run Keyword And Ignore Error    Extract The Monthly CLR Report As Table    ${ClientName}    ${POSName}    ${from_date}    ${to_date}    No
        END
    ELSE
        Monthly CLR Report For Multiple Concept    ${ClientName}    ${POSName}    ${from_date}    ${to_date}
    END

*** Keywords ***
CLR Data Extracting Common Steps For Monthly Report
    [Arguments]    ${from_date}    ${to_date}

    ${Day}    ${Month}    ${Year}=    Input Date Prepare     ${from_date}
    ${ToDay}    ${ToMonth}    ${ToYear}=    Input Date Prepare      ${to_date}

    #Click on Internal
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath:(//span[(contains(text(),'Internal ')) and not(contains(text(),'Internal Reports'))])[1]//..//parent::li
    Sleep    3s
    
    #Click on Sales Validation In case of single concept
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element If Visible    xpath:(//div[contains(text(),"Sales Validation ")])[1]/parent::li
    
    #Click on Sales Validation In case of multiple concept
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element If Visible    xpath:(//a[contains(text()," Sales Validation ")])[1]/parent::li

    ${spinner_visible}=     RPA.Browser.Selenium.Is Element Visible    xpath://div[@class="spinner-wrap local active"]
    IF    ${spinner_visible}
        Wait Until Page Does Not Contain Element    xpath://div[@class="spinner-wrap local active"]    timeout=90s
    END 
    
    Datepicker Setting In UI    ${Day}    ${Month}    ${Year}    1

    Datepicker Setting In UI    ${ToDay}    ${ToMonth}    ${ToYear}    2


*** Keywords ***
Extract The Monthly CLR Report As Table
    [Arguments]    ${ClientName}    ${POSName}    ${from_date}    ${to_date}    ${LocationExist}
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
    Log    ${ClientName}--${ClientNameStr}_${from_date}-${to_date}

    IF    '${LocationExist}' == 'yes'
        ${list_all_data}=    dictionary_check_monthly_sales    ${list_all_data}    ${ClientName}--${ClientNameStr}    ${POSName}    ${from_date}    ${to_date}    ${GrossSales}    ${NetSales}    ${GuestCount}    ${Discount}    ${ClientName}--${ClientNameStr}_${from_date}

        #Write the extracted CLR sales data to excel
        Write Sales Datas To CLR Report    ${ClientName}--${ClientNameStr}    ${from_date}-${to_date}    ${GrossSales}    ${NetSales}    ${GuestCount}    ${Discount} 

    ELSE
        ${list_all_data}=    dictionary_check_monthly_sales    ${list_all_data}    ${ClientName}    ${from_date}    ${to_date}    ${POSName}    ${GrossSales}    ${NetSales}    ${GuestCount}    ${Discount}    ${ClientName}_${from_date}

        #Write the extracted CLR sales data to excel
        Write Sales Datas To CLR Report    ${ClientName}    ${from_date}-${to_date}    ${GrossSales}    ${NetSales}    ${GuestCount}    ${Discount} 
    END
    Sleep    5s


*** Keywords ***
Monthly CLR Report For Multiple Concept
    [Arguments]    ${ClientName}    ${POSName}    ${from_date}    ${to_date}
     
    ${LiCount}=    Get Element Count    xpath:(//p[@class="ul-parent-title capital" and contains(text(),"CROSS LOCATION REPORTS")]//following-sibling::ul)[1]//li
    IF    ${LiCount} > 0
        FOR    ${i}    IN RANGE    1    ${LiCount+1}

            Click Element    xpath:((//p[@class="ul-parent-title capital" and contains(text(),"CROSS LOCATION REPORTS")]//following-sibling::ul)[1]//li)[${i}]        
            
            CLR Data Extracting Common Steps For Monthly Report    ${from_date}    ${to_date} 

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
                    
                    ${spinner_visible}=     RPA.Browser.Selenium.Is Element Visible    xpath://div[@class="spinner-wrap local active"]
                    IF    ${spinner_visible}
                        Wait Until Page Does Not Contain Element    xpath://div[@class="spinner-wrap local active"]    timeout=90s
                    END 
                    
                    #Click on Refresh Button
                    Refresh Button Click
                    
                    #Sleep    10s    
                    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Wait Until Element Is Visible    xpath://p-table[@id="mainTalbe"]
                    
                    #Extract The CLR Report
                    ${status1}  ${reason1}   Run Keyword And Ignore Error    Extract The Monthly CLR Report As Table    ${ClientName}    ${POSName}    ${from_date}    ${to_date}    yes

                END
            ELSE
                #Click on Refresh Button
                Refresh Button Click
                #Sleep    10s
                Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Wait Until Element Is Visible    xpath://p-table[@id="mainTalbe"]
                #Extract The CLR Report
                ${status1}  ${reason1}   Run Keyword And Ignore Error    Extract The Monthly CLR Report As Table    ${ClientName}    ${POSName}    ${from_date}    ${to_date}    No
            END
            
            #Clicking the Back button to pick next date
            Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath:(//li[@class="sidepanel-li"])[7]
            Sleep    2s
            Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath:(//li[@class="sidepanel-li"])[6]
            Sleep    2s
        END
    ELSE
        Log    Client have single concept
        write_log_text  'KitchensyncProcess- Monthly CLR Report For Multiple Concept:'    ${ClientName} 'Doesn't Exist In Kitchensync.'     Output    log
        Write Status To Run Report    ${ClientName}     ${from_date}-${to_date}     Client have single concept.
    END
    
    