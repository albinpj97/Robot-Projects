
*** Settings ***
Documentation       Template robot main suite.
Library             RPA.Browser.Selenium
Library             RPA.Tables
Library             DateTime
Library             RPA.Excel.Files
Library             Collections
Library             String
Library             Test

*** Tasks ***
testrunning
    ${FromRange}    Set Variable    May 31 - Jun 27
    ${ToRange}    Set Variable    May 31 - Jun 27
    ${Year}    Set Variable    2022
    ${datelist}=    date_diff    ${FromRange}    ${ToRange}

