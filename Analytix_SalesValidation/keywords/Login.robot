*** Settings ***
Documentation   Template robot main suite.
Library         RPA.Browser.Selenium
Library         RPA.core.notebook
Library         RPA.Tables
Library         Collections
Library         Process
Library         DateTime
Resource        ExcelActivities.robot
Library         String


*** Keywords ***
Login to SquareUp
    [Arguments]    ${ConfigSettings}    ${LoginCredentialsKey}

    ${UserName}    ${Password}    ${Timezone}    Get Credentials   ${LoginCredentialsKey} 

    Run Process    powershell    tzutil    /s     '${Timezone}'
    Sleep    2s
    
    FOR    ${i}    IN RANGE    1    3
        ${status}    ${reason}    Run Keyword And Ignore Error    Launch And Login To Squareup    ${ConfigSettings}    ${UserName}    ${Password}    ${LoginCredentialsKey}
        IF    '${status}' == 'PASS'
            Exit For Loop
        ELSE
            Continue For Loop
        END
    END


*** Keywords ***
Get Credentials
    [Arguments]    ${LoginCredentials}
    @{credentials} =	Split String	${LoginCredentials}    --
    [Return]    ${credentials}[1]    ${credentials}[2]    ${credentials}[3]    


*** Keywords ***
Launch And Login To Squareup
     [Arguments]    ${ConfigSettings}    ${UserName}    ${Password}    ${LoginCredentialsKey}
     
     ${current_date} =	Get Current Date    result_format=%m/%d/%Y
     
     Close All Browsers   
     
     Open Chrome Browser   ${ConfigSettings}[SquareUpUrl]
     Maximize Browser Window
     
     Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Wait Until Element Is Visible   xpath://a[@href="/login"]  

     ${LoginVisible}=     RPA.Browser.Selenium.Is Element Visible    xpath://a[@href="/login"]
     
     IF    ${LoginVisible}
         Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element If Visible    xpath://a[@href="/login"]

         Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Wait Until Element Is Visible   xpath://input[@id="email"]
         Sleep    2s
         Input Text When Element Is Visible    xpath://input[@id="email"]   ${UserName}
     
         Sleep    1s
         Input Password  //input[@name="password"]   ${Password}
         Sleep    2s
        
         #Checking if captcha is visible or not
         Captcha Checking
        
         Sleep    2s
         Click Element   //*[@name="sign-in-button"]

         #Checking if captcha is visible or not
         Captcha Checking

         Sleep    15s
    ELSE
        ${EmailVisible}=     RPA.Browser.Selenium.Is Element Visible    xpath://input[@id="email"]
        IF    ${EmailVisible}
            Sleep    2s
             Input Text    xpath://input[@id="email"]   ${UserName}    
     
             Sleep    1s
             Input Password  //input[@name="password"]   ${Password}         
             Sleep    2s

             #Checking if captcha is visible or not
             Captcha Checking

             Sleep    2s
             Click Element   //*[@name="sign-in-button"]

             #Checking if captcha is visible or not
             Captcha Checking

             Sleep    15s
        ELSE
            Login to SquareUp    ${ConfigSettings}    ${LoginCredentialsKey}
        END
    END

*** Keywords ***
Captcha Checking
    ${captcha_visible}=    RPA.Browser.Selenium.Is Element Visible    xpath://div[@class="recaptcha-checkbox-border"]
    IF    ${captcha_visible}
        Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://div[@class="recaptcha-checkbox-border"]
    END

    ${captcha_visible1}=    RPA.Browser.Selenium.Is Element Visible    xpath://span[@id="recaptcha-anchor"]
    IF    ${captcha_visible1}
        Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://span[@id="recaptcha-anchor"]
    END

    # ${captcha_visible2}=    RPA.Browser.Selenium.Is Element Visible    xpath://div[@id="captcha"]
    # IF    ${captcha_visible2}
    #     Wait Until Keyword Succeeds    ${Retry}x    ${RetrySeconds}s    Click Element    xpath://div[@id="captcha"]
    # END

    


    #  Wait Until Keyword Succeeds    4x    5s    Wait Until Element Is Visible   xpath://div[@class="instructions" and contains(text(),"Choose a business or service to manage")]
        
    #  ${HomeAppear}    Is Element Visible    //div[@class="instructions" and contains(text(),"Choose a business or service to manage")]
    #  IF    ${HomeAppear}
    #      Write Status To Run Report    ${EMPTY}    ${current_date}    ${UserLoginDetails}[UserName] login Succesfully.
    #  ELSE
    #      ${HomeAppearOtherClients}    Is Element Visible    //div[@class="app-drawer__title"]
    #      IF    ${HomeAppearOtherClients}
    #          Write Status To Run Report    ${EMPTY}    ${current_date}    ${UserLoginDetails}[UserName] login Succesfully.
    #     ELSE
    #         Write Status To Run Report    ${EMPTY}    ${current_date}    ${UserLoginDetails}[UserName] login failed. Retrying once again.
    #         Login to SquareUp    ${ConfigSettings}    ${UserLoginDetails}
    #     END   
    #  END

