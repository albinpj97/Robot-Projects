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
Resource        SquareMonthlySales.robot

*** Variables ***
# ${DownloadLoc}   C:/Robocorp/Analytix_SalesValidation/Input
#${DownloadLoc}       ${CURDIR}/Downloads
#${Move_folder}       ${CURDIR}/Temp_Downloads
# +

*** Keywords ***
Select Each Client
    [Arguments]       ${ClientDetails}    ${list_all_data}    ${location_mapping_dic}    ${ConfigSettings} 

    ${current_date} =	Get Current Date    result_format=%m/%d/%Y

    IF    '${ConfigSettings}[Run]' == 'Monthly'
        Extract Monthly Squareup Sales Data    ${ClientDetails}    ${list_all_data}    ${location_mapping_dic}    ${ConfigSettings}

    ELSE
        FOR    ${ClientRow}    IN    @{ClientDetails}
            
            ${ClientName}=    Set Variable    ${ClientRow}[Client]
            ${ClientNameSelect}=    Set Variable    ${ClientRow}[POSName]   
            ${FromDate}=    Set Variable    ${ClientRow}[FromDate]
            ${ToDate}=    Set Variable    ${ClientRow}[ToDate]

            #loop through all clients that read from config and pass them into a variable called ${ClientName} 
            # Sleep  3s
            Run Keyword And Ignore Error   Wait Until Element Is Visible  //*[@id="launchpad-wrapper"]

            ${ClientWindow}    Is Element Visible     //*[@id="launchpad-wrapper"]

            IF    ${ClientWindow}
                #Wait Until Keyword Succeeds    5    10s    Wait Until Element Is Visible  //*[@id="launchpad-wrapper"]
                Wait Until Keyword Succeeds    5    10s    Wait Until Element Is Visible  //div[contains(text(),"${ClientNameSelect}")]/..

                Click Element    //div[contains(text(),"${ClientNameSelect}")]/..
            END

            ${list_all_data}    Select Start And End Dates        ${FromDate}    ${ToDate}    ${ClientRow}[Client]    ${ClientRow}[POSName]    ${list_all_data}    ${location_mapping_dic}

            Run Keyword And Ignore Error    Redirect back
                
                #${ClientExist}    Is Element Visible     //div[contains(text(),"${ClientNameSelect}")]/..
                # IF    ${ClientExist}
                #     Write Status To Run Report    ${ClientNameSelect}    ${current_date}     Client Exist In SquareUp.
                    
                #     Click Element    //div[contains(text(),"${ClientNameSelect}")]/..

                #     #${Status}    ${list_all_data}    Run Keyword And Ignore Error    Select Start And End Dates        ${FromDate}    ${ToDate}    ${ClientRow}[Client]    ${list_all_data}
            
                #     ${Status}    ${list_all_data}    Run Keyword And Ignore Error    Select Start And End Dates        ${FromDate}    ${ToDate}    ${ClientRow}[Client]    ${list_all_data}
                #     #lib_remove_all_csv_files    ${DownloadLoc}
                
                #     Run Keyword And Ignore Error    Redirect back
                # ELSE
                #     Write Status To Run Report    ${ClientNameSelect}    ${current_date}     Client Doesn't Exist In SquareUp. 
                # END

        END
    END
    [Return]    ${list_all_data}
    

# -

*** Keywords ***
Export Report from Report section
    [Arguments]     ${FromDate}     ${ToDate}    ${ClientName}    ${POSName}    ${list_all_data}    ${location_mapping_dic}

    Select Report From Side Menu

    Set The Date To Dropdown    ${FromDate}     ${ToDate}

    ${LocationVisible}=     RPA.Browser.Selenium.Is Element Visible    xpath://div[@class="filter-merchant-units dropdown ember-view"]
    IF    ${LocationVisible}
        Sleep    1s
        Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://div[@class="filter-merchant-units dropdown ember-view"] 
        
        ${AllLocationSelected}=     RPA.Browser.Selenium.Is Element Visible    xpath://p[contains(text(),"All Locations")]/parent::div/preceding-sibling::span[@class="option-toggle checkbox checkbox--is-checked option-toggle--is-selected ember-view"]   
        IF    ${AllLocationSelected}
            Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://p[contains(text(),"All Locations")]/parent::div/preceding-sibling::span[@class="option-toggle checkbox checkbox--is-checked option-toggle--is-selected ember-view"]/child::input
            Sleep    2s
            
            #Then picking the Location count
            #${LocationCount}=    Get Element Count    xpath://div[@class="location-dropdown__options-list location-dropdown__vertical-collection-list select-all-checkbox-manager__vertical-collection-list ember-view"]/label
            ${LocationCount}=    Get Element Count    xpath://div[@class="location-dropdown__options-list location-dropdown__vertical-collection-list select-all-checkbox-manager__vertical-collection-list ember-view"]/label/child::div[not(small)]
            
            IF    ${LocationCount} > 0
                
                #Loop through the locations
                FOR    ${i}    IN RANGE    1    ${LocationCount+1}
                    IF    ${i} > 1
                        Select Report From Transaction Page

                        Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://div[@class="filter-merchant-units dropdown ember-view"] 

                        #Remove selected location 
                        Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://div[@class="location-dropdown__options-list location-dropdown__vertical-collection-list select-all-checkbox-manager__vertical-collection-list ember-view"]/label[${i-1}]
                        Sleep    3s 
                    END
                    #Click on location one by one 
                    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://div[@class="location-dropdown__options-list location-dropdown__vertical-collection-list select-all-checkbox-manager__vertical-collection-list ember-view"]/label[${i}]
                    Sleep    3s

                    #Store the selected Location name to a variable
                    ${SelectedLocationName}=    Get Text   xpath://div[@class="location-dropdown__options-list location-dropdown__vertical-collection-list select-all-checkbox-manager__vertical-collection-list ember-view"]/label[${i}]/child::div/p


                    ${NoTransactionExist}=     RPA.Browser.Selenium.Is Element Visible    //div[@class="unavailable--header" and contains(text(),"No Transactions in This Time Frame")]
                    IF    '${NoTransactionExist}' != 'True'
                        
                        #Data extraction
                        ${status1}  ${reason1}   Run Keyword And Ignore Error    Sales Data Extraction From Squareup    ${ClientName}    ${POSName}    ${FromDate}    ${list_all_data}    ${SelectedLocationName}    ${location_mapping_dic}

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
            ${status1}  ${reason1}   Run Keyword And Ignore Error    Sales Data Extraction From Squareup    ${ClientName}    ${POSName}    ${FromDate}    ${list_all_data}    ${SelectedLocationName}    ${location_mapping_dic}

        ELSE
            
            Write Status To Run Report    ${ClientName}     ${FromDate}     No sales during this period.
            
            Square Sales No Data Extraction    ${ClientName}    ${POSName}    ${FromDate}    ${list_all_data}    ${SelectedLocationName}    ${location_mapping_dic}
        END
    END



*** Keywords ***
Sales Data Extraction From Squareup
    [Arguments]    ${ClientName}    ${POSName}    ${FromDate}    ${list_all_data}    ${SelectedLocationName}    ${location_mapping_dic}

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
            
            Write Sales Datas To POS Report    ${ClientName}    ${FromDate}    ${Gross_sale}    ${Net_sales}    ${Guest_count}    ${Discounts}

        ELSE
            ${list_all_data}=    dictionary_update_with_squareup_data    ${list_all_data}    ${ClientName}--${SelectedLocationName}    ${POSName}--${SelectedLocationName}    ${FromDate}    ${Gross_sale}    ${Net_sales}    ${Guest_count}    ${Discounts}    ${ClientName}--${SelectedLocationName}_${FromDate}    ${location_mapping_dic} 

            #Write the extracted Squareup sales data to excel
            Write Sales Datas To POS Report    ${ClientName}    ${FromDate}    ${Gross_sale}    ${Net_sales}    ${Guest_count}    ${Discounts}
        END

        


*** Keywords ***
Square Sales No Data Extraction
    [Arguments]    ${ClientName}    ${POSName}    ${SingleDate}    ${list_all_data}    ${SelectedLocationName}    ${location_mapping_dic}    
    
    ${GrossZeroSales}=    Set Variable    $0.00
    ${NetZeroSales}=    Set Variable    $0.00
    ${NetZeroGuest}=    Set Variable    0
    ${PrimecostZeroDiscount}=    Set Variable    $0.00

    #Writing the sales data to dictionary
    IF    '${SelectedLocationName}' == '${EMPTY}'
        ${list_all_data}=    dictionary_update_with_squareup_data    ${list_all_data}    ${ClientName}    ${POSName}    ${SingleDate}    ${GrossZeroSales}    ${NetZeroSales}    ${NetZeroGuest}    ${PrimecostZeroDiscount}    ${ClientName}_${SingleDate}     ${location_mapping_dic}
        
        #Write the extracted Squareup sales data to excel
        Write Sales Datas To POS Report    ${ClientName}    ${SingleDate}    ${GrossZeroSales}    ${NetZeroSales}    ${NetZeroGuest}    ${PrimecostZeroDiscount} 

    ELSE
        ${list_all_data}=    dictionary_update_with_squareup_data    ${list_all_data}    ${ClientName}--${SelectedLocationName}    ${POSName}--${SelectedLocationName}    ${SingleDate}    ${GrossZeroSales}    ${NetZeroSales}    ${NetZeroGuest}    ${PrimecostZeroDiscount}    ${ClientName}--${SelectedLocationName}_${SingleDate}    ${location_mapping_dic} 

        #Write the extracted Squareup sales data to excel
        Write Sales Datas To POS Report    ${ClientName}--${SelectedLocationName}    ${SingleDate}    ${GrossZeroSales}    ${NetZeroSales}    ${NetZeroGuest}    ${PrimecostZeroDiscount} 
    END


*** Keywords ***
Select Report From Side Menu
    #Click on the right side panel to select the Reports section   
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Wait Until Element Is Visible   //span[@class="app-drawer__section__item-list__item__label" and contains(text(),"Reports")]
    Sleep  2s
    
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element  //span[@class="app-drawer__section__item-list__item__label" and contains(text(),"Reports")]    # //*[@data-app ="REPORTS"]



*** Keywords ***
Set The Date To Dropdown
    [Arguments]    ${FromDate}     ${ToDate}
    Wait Until Keyword Succeeds    3x    10s    Click Element   //div[@class="dropdown ember-view filter-date"] 
 
    #Start date 
    Sleep  3s
    Wait Until Keyword Succeeds    3x    10s    Wait Until Element Is Visible   //div[contains(text(),"Start")]//following::input[1]  
    
    Click Element When Visible    xpath://div[contains(text(),"Start")]//following::input[1] 
    
    Clear Element Text  //div[contains(text(),"Start")]//following::input[1]
    RPA.Browser.Selenium.Press Keys    xpath://div[contains(text(),"Start")]//following::input[1]   ENTER
    
    Input Text   //div[contains(text(),"Start")]//following::input[1]    ${FromDate} 
    RPA.Browser.Selenium.Press Keys    xpath://div[contains(text(),"Start")]//following::input[1]   ENTER
    
    #End Date
    Sleep  3s
    Wait Until Keyword Succeeds    3x    10s    Wait Until Element Is Visible   //div[contains(text(),"Start")]//following::input[2] 
    
    Click Element When Visible  //div[contains(text(),"Start")]//following::input[2] 
    
    Clear Element Text   //div[contains(text(),"Start")]//following::input[2]
    
    Input Text    //div[contains(text(),"Start")]//following::input[2]    ${ToDate}
    #RPA.Browser.Selenium.Press Keys    xpath://div[contains(text(),"Start")]//following::input[2]   ENTER	
    
    Clear Element Text  //div[contains(text(),"Start")]//following::input[1]
    Input Text   //div[contains(text(),"Start")]//following::input[1]    ${FromDate} 
    RPA.Browser.Selenium.Press Keys    xpath://div[contains(text(),"Start")]//following::input[1]   ENTER
    Click Element When Visible  //div[contains(text(),"Start")]//following::input[2] 

    Sleep    5s



*** Keywords ***
Extract Guest Count From Transaction
    #Go to the Transaction section to get the transaction number 
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Wait Until Element Is Visible   //button[@class="app-drawer__trigger"]
    Sleep    2s
    Click Element    //button[@class="app-drawer__trigger"]

    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Wait Until Element Is Visible    //span[@class="app-drawer__section__item-list__item__label" and contains(text(),"Transactions")]
    Click Element    //span[@class="app-drawer__section__item-list__item__label" and contains(text(),"Transactions")]
    Sleep    3s
    
    ${Transaction_completed}=    Set Variable    0
    
    ${TransactionVisible}=     RPA.Browser.Selenium.Is Element Visible    xpath://div[contains(text(),"No Transactions in This Time Frame")]
        IF    ${TransactionVisible}
            Log    No transactions took place during the time frame you selected.
        ELSE
            ${GuestCountVisible}=     RPA.Browser.Selenium.Is Element Visible    xpath:(//*[@class="key-stats-value"])[1]
            
            IF    ${GuestCountVisible}
                ${Transaction_completed}=    Get Text    (//*[@class="key-stats-value"])[1]
                Log    ${Transaction_completed}
                Sleep    4s
            END
        END

    Return From Keyword    ${Transaction_completed}


*** Keywords ***
Select Report From Transaction Page
    
    #Go to the Report section from transaction page to pick the next location of the current client 
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Wait Until Element Is Visible   //button[@class="app-drawer__trigger"]
    Sleep    2s
    Click Element    //button[@class="app-drawer__trigger"]

    Select Report From Side Menu



*** Keywords ***
Redirect back
   Go To    https://squareup.com/launchpad 


*** Keywords ***
Select Start And End Dates
    [Arguments]   ${FromDate}    ${ToDate}    ${ClientName}    ${POSName}    ${list_all_data}    ${location_mapping_dic}
    Log  ${list_all_data}

    ${correct_from_date}  ${correct_end_date}   Change Date Formate  ${FromDate}    ${ToDate}
    ${Date_difference}    Date Diff    ${FromDate}    ${ToDate}
    
    
    FOR    ${counter}    IN RANGE    0    ${Date_difference+1}
        ${GrossSales}=    Set Variable    $0.00
        ${NetSales}=    Set Variable    $0.00
        ${GuestCount}=    Set Variable    0
        ${Discount}=    Set Variable    $0.00
        
        ${Report_status}    ${Reason}    Run Keyword And Ignore Error    Export Report from Report section        ${correct_from_date}    ${correct_from_date}    ${ClientName}    ${POSName}    ${list_all_data}    ${location_mapping_dic}
    
      
        Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Wait Until Element Is Visible   //button[@class="app-drawer__trigger"]
        Sleep    2s
        Click Element    //button[@class="app-drawer__trigger"]
      
        ${correct_from_date}  Date Adding  ${correct_from_date}

    END
    [Return]    ${list_all_data}

*** Keywords ***
Change Date Formate
    [Arguments]    ${FromDate}    ${ToDate}
    # ${a}=  Set Variable  2022-05-05 00:00:00
    ${start_date}=  Convert Date    ${FromDate}  %m/%d/%Y
    ${end_date}=    Convert Date    ${ToDate}  %m/%d/%Y
    Log    ${start_date}
    Log    ${end_date}
    Return From Keyword     ${start_date}    ${end_date}

# <!-- *** Keywords ***
# sample date Adding
#     ${correct_from_date}=  Set Variable    05/05/2022
#     ${correct_from_date}  Date Adding  ${correct_from_date}
#     Log To Console    ${correct_from_date} -->

