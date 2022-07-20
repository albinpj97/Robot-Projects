*** Settings ***
Documentation       Login to Insite360 and Square Up site
Library             RPA.Browser.Selenium
Library             DateTime
Resource            ExcelActivities.robot


*** Keywords ***
Open Website To Login P2
    [Arguments]    ${ConfigSettings}

    ${current_date} =	Get Current Date    result_format=%m/%d/%Y

    Close All Browsers
    #Set Download Directory    ${EXECDIR}${/}DownloadTemp
    
    Open Chrome Browser    ${ConfigSettings}[KitchensyncUrl]
    Maximize Browser Window
    Sleep    2s
    Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s  Wait Until Element Is Visible      xpath://input[@id="Email"]
    Input Text      xpath://input[@id="Email"]    ${ConfigSettings}[KitchensyncUserName]
    Input Password      xpath://input[@id="Password"]   ${ConfigSettings}[KitchensyncPassword]
    Sleep    1s
    
    ${Result}=  RPA.Browser.Selenium.Is Element Visible  xpath://button[contains(text(),"Login")]
        IF    '${Result}'=='True'
            Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s  Click Element    xpath://button[contains(text(),"Login")] 
            Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s  Wait Until Element Is Visible      xpath://input[@type="search"]
            
            ${HomeVisible}=  RPA.Browser.Selenium.Is Element Visible    xpath://input[@type="search"]
            IF    '${HomeVisible}' == 'False'
                Write Status To Run Report    ${EMPTY}    ${current_date}    ${ConfigSettings}[KitchensyncUserName] login failed. Retrying once again..
                Open Website To Login P2    ${ConfigSettings}
            ELSE
                Write Status To Run Report    ${EMPTY}    ${current_date}    ${ConfigSettings}[KitchensyncUserName] login Succesfully.
            END
        END
