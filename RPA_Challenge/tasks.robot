*** Settings ***
Documentation     Template robot main suite.
...               RPA Challenge
Library           RPA.Browser
Library           RPA.HTTP
Library           RPA.Excel.Files
Library           RPA.core.notebook
Library           RPA.Database

*** Keywords ***
 Fill And Submit The Form From Excel
     [Arguments]    ${row}
     Input Text    //input[@ng-reflect-name="labelFirstName"]       ${row}[First Name]
     Input Text    //input[@ng-reflect-name="labelLastName"]        ${row}[Last Name ]
     Input Text    //input[@ng-reflect-name="labelCompanyName"]     ${row}[Company Name]
     Input Text    //input[@ng-reflect-name="labelRole"]            ${row}[Role in Company]
     Input Text    //input[@ng-reflect-name="labelAddress"]         ${row}[Address]
     Input Text    //input[@ng-reflect-name="labelEmail"]           ${row}[Email]
     Input Text    //input[@ng-reflect-name="labelPhone"]           ${row}[Phone Number]
     Click Button When Visible    //input[@value="Submit"]


*** Keywords ***
Download And Get File Content
    #Download  http://rpachallenge.com/assets/downloadFiles/challenge.xlsx  overwrite=True
    Open Workbook    challenge.xlsx
    ${rows}=        Read Worksheet     header=True
    Close Workbook
    Return From Keyword  ${rows}

*** Keywords ***
Update Row Data To DB
    Connect To Database     pymssql     Robocorp_DB     sa      Albin@12345     127.0.0.1
    # Connect To Database     pymssql     Robocorp_DB     sa      Albin@12345     52.152.134.214
    ${table_data}   Download And Get File Content
    FOR    ${row}   IN  @{table_data}
        
        IF    '${row}[First Name]' != 'None'
            #Notebook Print  Hello
            #Notebook Print  ${row}[First Name]
            Query  INSERT INTO Client_Details (FirstName,LastName,CompanyName,RoleInCompany,Address,Email,PhoneNumber,Logs) VALUES ('${row}[First Name]','${row}[Last Name ]','${row}[Company Name]','${row}[Role in Company]','${row}[Address]','${row}[Email]','${row}[Phone Number]','Pending')
        END
        # Query  INSERT INTO Client_Details (FirstName,LastName,CompanyName,RoleInCompany,Address,Email,PhoneNumber,Logs) VALUES ('${row}[First Name]','${row}[Last Name ]','${row}[Company Name]','${row}[Role in Company]','${row}[Address]','${row}[Email]','${row}[Phone Number]','Pending')
       # Notebook Print  ${row}
    END 
    # Query  INSERT INTO Client_Details (FirstName,LastName,CompanyName,RoleInCompany,Address,Email,PhoneNumber,Logs) Values ('John','Smith','IT Solutions','Analyst','98 North Road','jsmith@itsolutions.co.uk','40716543298','Pending')


*** Keywords ****
Get Data From MSSQL DB
    # Connect To Database     pymssql     Robocorp_DB     sa      Albin@12345     127.0.0.1
    # Connect To Database     pymssql     Robocorp_DB     sa      Albin@12345     52.152.134.214
    ${orders}            Query    Select Top(1) * FROM Client_Details Where Logs = 'Pending'
    # Query  UPDATE Client_Details SET Logs = 'InProgress' Where FirstName = 'Lara' and LastName = 'Palmer'
    Query  UPDATE Client_Details SET Logs = 'InProgress' Where FirstName = '${orders}[0][0]' and LastName = '${orders}[0][1]'
    Notebook Print  ${orders}[0]
    Return From Keyword  ${orders}[0]

*** Keywords ***
 Fill And Submit The Form DB
     [Arguments]    ${row}
     Input Text    //input[@ng-reflect-name="labelFirstName"]       ${row}[0]
     # sleep  3
     Input Text    //input[@ng-reflect-name="labelLastName"]        ${row}[1]
     Input Text    //input[@ng-reflect-name="labelCompanyName"]     ${row}[2]
     Input Text    //input[@ng-reflect-name="labelRole"]            ${row}[3]
     Input Text    //input[@ng-reflect-name="labelAddress"]         ${row}[4]
     Input Text    //input[@ng-reflect-name="labelEmail"]           ${row}[5]
     # sleep  3
     Input Text    //input[@ng-reflect-name="labelPhone"]           ${row}[6]
     # sleep  3
     Click Button When Visible    //input[@value="Submit"]

*** Keywords ***
Get Data And Fill The Form
    ${row}   Get Data From MSSQL DB
    ${error_info}  ${error_msg}  Run Keyword And Ignore Error   Fill And Submit The Form DB  ${row}
    Return From Keyword     ${row}  ${error_info}

*** Keywords ***
Open RPA Challenge DB
    Open Available Browser  https://rpachallenge.com/
    # ${rows}     Download And Get File Content
    # Notebook Print  ${rows}
    Click Button When Visible    //button[contains(.,"Start")]
    Connect To Database     pymssql     Robocorp_DB     sa      Albin@12345     127.0.0.1
    # Connect To Database     pymssql     Robocorp_DB     sa      Albin@12345     52.152.134.214
    ${starter}      Set Variable    1
    ${client_count}    Query   SELECT COUNT(FirstName) FROM Client_Details Where Logs = 'Pending'
    ${client_count}   Set Variable   ${client_count}[0][0]
    Notebook Print  ${client_count}
    FOR  ${i}  IN RANGE   ${starter}   ${client_count+1}
        # ${current_client}   Get Data And Fill The Form
        # Notebook Print  ${current_client}
        ${current_client}   ${error_info}    Get Data And Fill The Form
        IF   '${error_info}' == 'PASS'
             Query  UPDATE Client_Details SET Logs = 'Finished' Where FirstName = '${current_client}[0]' and LastName = '${current_client}[1]'
        END 
          
        ${starter}      Set Variable    1
        ${client_count}   Query  SELECT COUNT(FirstName) FROM Client_Details Where Logs = 'Pending'
    END
    #FOR    ${row}   IN  @{rows}
        # Notebook Print  ${row}
        #Fill And Submit The Form    ${row}
    #END

*** Keywords ***
Open RPA Challenge
    Open Available Browser  https://rpachallenge.com/
    ${rows}     Download And Get File Content
    # Notebook Print  ${rows}
    Click Button When Visible    //button[contains(.,"Start")]
    
    FOR    ${row}   IN  @{rows}
        Exit For Loop If    '${row}[First Name]' == 'None'
        Notebook Print  ${row}
        Fill And Submit The Form From Excel    ${row}
        
    END
    Close Browser

*** Tasks ***
Minimal task
    Open RPA Challenge 
    Log    Done.




