*** Settings ***
Documentation     Template robot main suite.
Library           Collections
Library           MyLibrary.py
Resource          keywords.robot
Variables         MyVariables.py

*** Tasks ***
Orange HR Process
    table extraction


