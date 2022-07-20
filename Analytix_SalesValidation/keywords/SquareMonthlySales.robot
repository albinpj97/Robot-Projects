*** Settings ***
Documentation   Template robot main suite.
Library         RPA.Browser.Selenium
Library         RPA.core.notebook
Library         DateManipulation
Library         DateTime
Library         RPA.PDF
Library         Functions 
Library         ClearInput
Library         Excel_Operations
Resource        ExcelActivities.robot
Resource        Square.robot


*** Keywords ***
Extract Monthly Squareup Sales Data
    [Arguments]       ${ClientDetails}    ${list_all_data}    ${location_mapping_dic}    ${ConfigSettings} 

    FOR    ${ClientRow}    IN    @{ClientDetails}
            
        ${ClientName}=    Set Variable    ${ClientRow}[Client]
        ${ClientNameSelect}=    Set Variable    ${ClientRow}[POSName]   
        #${FromDate}=    Set Variable    ${ClientRow}[FromRange]
        #${ToDate}=    Set Variable    ${ClientRow}[ToRange]

        ${FromDate}    ${ToDate}    date_convert_to_date    ${ClientRow}[FromRange]    ${ClientRow}[ToRange]   ${ClientRow}[Year]

        #loop through all clients that read from config and pass them into a variable called ${ClientName} 
        # Sleep  3s
        Run Keyword And Ignore Error   Wait Until Element Is Visible  //*[@id="launchpad-wrapper"]

        ${ClientWindow}    Is Element Visible     //*[@id="launchpad-wrapper"]

        IF    ${ClientWindow}
            #Wait Until Keyword Succeeds    5    10s    Wait Until Element Is Visible  //*[@id="launchpad-wrapper"]
            Wait Until Keyword Succeeds    5    10s    Wait Until Element Is Visible  //div[contains(text(),"${ClientNameSelect}")]/..

            Click Element    //div[contains(text(),"${ClientNameSelect}")]/..
        END

        ${list_all_data}    Select Start And End Dates For Monthly Validation        ${FromDate}    ${ToDate}    ${ClientRow}[Client]    ${ClientRow}[POSName]    ${list_all_data}    ${location_mapping_dic}

        Run Keyword And Ignore Error    Redirect back
    END

*** Keywords ***
Select Start And End Dates For Monthly Validation
    [Arguments]   ${FromDate}    ${ToDate}    ${ClientName}    ${POSName}    ${list_all_data}    ${location_mapping_dic}
    Log  ${list_all_data}

    # ${correct_from_date}  ${correct_end_date}   Change Date Formate  ${FromDate}    ${ToDate}
    # ${Date_difference}    Date Diff    ${FromDate}    ${ToDate}
    
    
    #FOR    ${counter}    IN RANGE    0    ${Date_difference+1}
        ${GrossSales}=    Set Variable    $0.00
        ${NetSales}=    Set Variable    $0.00
        ${GuestCount}=    Set Variable    0
        ${Discount}=    Set Variable    $0.00
        
        ${Report_status}    ${Reason}    Run Keyword And Ignore Error    Extract CLR Report from Report section        ${FromDate}    ${ToDate}    ${ClientName}    ${POSName}    ${list_all_data}    ${location_mapping_dic}
    
      
        Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Wait Until Element Is Visible   //button[@class="app-drawer__trigger"]
        Sleep    2s
        Click Element    //button[@class="app-drawer__trigger"]
      
        #${correct_from_date}  Date Adding  ${correct_from_date}

    #END
    [Return]    ${list_all_data}


*** Keywords ***
Extract CLR Report from Report section
    [Arguments]     ${FromDate}     ${ToDate}    ${ClientName}    ${POSName}    ${list_all_data}    ${location_mapping_dic}

    Select Report From Side Menu
    
    Wait Until Keyword Succeeds    3x    20s    Wait Until Element Is Visible    //div[@class="dropdown ember-view filter-date"]

    #This method is defined in Square.robot and is common for both Square.robot and SquareMonthlySales.robot
    Set The Date To Dropdown    ${FromDate}     ${ToDate}

    ${LocationVisible}=     RPA.Browser.Selenium.Is Element Visible    xpath://div[@class="filter-merchant-units dropdown ember-view"]
    IF    ${LocationVisible}
        Sleep    3s
        Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://div[@class="filter-merchant-units dropdown ember-view"] 

        Sleep    3s
        ${AllLocationSelected}=     RPA.Browser.Selenium.Is Element Visible    xpath://label[@data-test-option-checkbox="All Locations" and @data-test-option-checkbox-checked=""]
        IF    ${AllLocationSelected}
            Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://label[@data-test-option-checkbox="All Locations" and @data-test-option-checkbox-checked=""]
            Sleep    2s
            
            #Then picking the Location count
            #This selector is used when we need to take the selected location count 
            #${LocationCount}=    Get Element Count    xpath://label[@data-test-option-checkbox="All Locations" and @data-test-option-checkbox-checked=""]/following-sibling::div/child::label

            #This selector is used when we need to take the unselected location count
            ${LocationCount}=    Get Element Count    xpath://label[@data-test-option-checkbox="All Locations"]/following-sibling::div/child::label
            
            IF    ${LocationCount} > 0
                
                #Loop through the locations
                FOR    ${i}    IN RANGE    1    ${LocationCount+1}
                    IF    ${i} > 1
                        Select Report From Transaction Page

                        Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://div[@class="filter-merchant-units dropdown ember-view"] 

                        #Remove selected location 
                        Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://label[@data-test-option-checkbox="All Locations"]/following-sibling::div/child::label[${i-1}]
                        Sleep    3s 
                    END
                    #Click on location one by one 
                    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://label[@data-test-option-checkbox="All Locations"]/following-sibling::div/child::label[${i}]
                    Sleep    3s

                    #Store the selected Location name to a variable
                    ${SelectedLocationName}=    Get Text   xpath://label[@data-test-option-checkbox="All Locations"]/following-sibling::div/child::label[${i}]/child::div/child::p


                    ${NoTransactionExist}=     RPA.Browser.Selenium.Is Element Visible    //div[@class="unavailable--header"]
                    
                    IF    '${NoTransactionExist}' == 'False'
                        
                        #Sales data exist and extract the data
                        ${status1}  ${reason1}   Run Keyword And Ignore Error    Monthly Sales Data Extraction From Squareup    ${ClientName}    ${POSName}    ${FromDate}     ${ToDate}    ${list_all_data}    ${SelectedLocationName}    ${location_mapping_dic}

                    ELSE
                        
                        Write Status To Run Report    ${ClientName}--${SelectedLocationName}     ${FromDate}     No sales during this period.
                        
                        Square Sales No Data Extraction    ${ClientName}    ${POSName}    ${FromDate}    ${list_all_data}    ${SelectedLocationName}    ${location_mapping_dic}
                    END

                END

            ELSE
                Log     No Locations
            END

        ELSE
            Log    Not selected all location
        END

    ELSE
        ${SelectedLocationName}=    Set Variable    ${EMPTY}
        
        ${NoTransactionExist}=     RPA.Browser.Selenium.Is Element Visible    //div[@class="unavailable--header" and contains(text(),"No Transactions in This Time Frame")]
        IF    '${NoTransactionExist}' != 'True'
            
            #Data extraction
            ${status1}  ${reason1}   Run Keyword And Ignore Error    Monthly Sales Data Extraction From Squareup    ${ClientName}    ${POSName}    ${FromDate}     ${ToDate}    ${list_all_data}    ${SelectedLocationName}    ${location_mapping_dic}

        ELSE
            
            Write Status To Run Report    ${ClientName}     ${FromDate}     No sales during this period.
            
            Square Sales No Data Extraction    ${ClientName}    ${POSName}    ${FromDate}    ${list_all_data}    ${SelectedLocationName}    ${location_mapping_dic}
        END
    END

*** Keywords ***
Monthly Sales Data Extraction From Squareup
    [Arguments]    ${ClientName}    ${POSName}    ${FromDate}     ${ToDate}    ${list_all_data}    ${SelectedLocationName}    ${location_mapping_dic}

    ${Gross_sale}=    Set Variable    $0.00
    ${Discounts}=    Set Variable    $0.00
    ${Net_sales}=    Set Variable    $0.00
    ${Guest_count}=    Set Variable    0

    Wait Until Keyword Succeeds    3x    10s    Wait Until Element Is Visible    xpath:(//div[@class="type-align-right table-cell"])[1]

    ${SquareGrossSalesData}=     RPA.Browser.Selenium.Is Element Visible    xpath:(//div[@class="type-align-right table-cell"])[1] 
    IF    ${SquareGrossSalesData}
        ${Gross_sale}=    Get Text   (//div[@class="type-align-right table-cell"])[1]
        Log    ${Gross_sale}
    END

    ${SquareDiscountData}=     RPA.Browser.Selenium.Is Element Visible    xpath:(//div[@class="type-align-right table-cell"])[3]
    IF    ${SquareDiscountData}
        ${Discounts}=    Get Text    (//div[@class="type-align-right table-cell"])[3]
        Log    ${Discounts}
    END

    ${SquareNetSalesData}=     RPA.Browser.Selenium.Is Element Visible    xpath:(//div[@class="type-align-right table-cell"])[4] 
    IF    ${SquareNetSalesData}
        ${Net_sales}=    Get Text    (//div[@class="type-align-right table-cell"])[4]
        Log    ${Net_sales}
    END
    Sleep  2s 

    #Select sales and click Primecost to extract discount
    ${Transaction_status}    ${Guest_count}    Run Keyword And Ignore Error    Extract Guest Count From Transaction
        
        Log    ${ClientName}
        Log    ${list_all_data}  
        Log    ${Gross_sale}    
        Log    ${Net_sales}  
        Log    ${Guest_count}  
        Log    ${Discounts}    
        Log    ${ClientName}_${FromDate}

        ${type string}=    Evaluate     type($list_all_data)
        Log    ${type string}

        IF    '${SelectedLocationName}' == '${EMPTY}'
            # Updating the sales datas from Square up to dictionary
            ${list_all_data}=    dictionary_update_with_squareup_data    ${list_all_data}    ${ClientName}    ${POSName}    ${FromDate}    ${Gross_sale}    ${Net_sales}    ${Guest_count}    ${Discounts}    ${ClientName}_${FromDate}    ${location_mapping_dic}
            
            Write Sales Datas To POS Report    ${ClientName}    ${FromDate}-${ToDate}    ${Gross_sale}    ${Net_sales}    ${Guest_count}    ${Discounts}

        ELSE
            ${list_all_data}=    dictionary_update_with_squareup_data    ${list_all_data}    ${ClientName}--${SelectedLocationName}    ${POSName}--${SelectedLocationName}    ${FromDate}     ${Gross_sale}    ${Net_sales}    ${Guest_count}    ${Discounts}    ${ClientName}--${SelectedLocationName}_${FromDate}    ${location_mapping_dic} 

            #Write the extracted Squareup sales data to excel
            Write Sales Datas To POS Report    ${ClientName}    ${FromDate}-${ToDate}    ${Gross_sale}    ${Net_sales}    ${Guest_count}    ${Discounts}
        END
