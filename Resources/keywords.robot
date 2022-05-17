*** Settings ***
Documentation                   Contains keywords required for the mcdx test case
Library                         String
Library                         QWeb
Library                         QForce
Library                         Collections
Library                         DateTime

*** Variables ***

*** Keywords ***
Switch To Lightning
    [Documentation]             Switch to lightning if classic view opened
    ${CLASSIC_VIEW}=            RunKeywordAndReturnStatus                               VerifyText                  Switch to Lightning Experience    timeout=2
    RunKeywordIf                ${CLASSIC_VIEW}             ClickText                   Switch to Lightning Experience

Start Suite
    [Documentation]             Setup browser and open Salesforce ORG
    #SearchMode- To get the blue box as visualization on the screen while element interaction
    #MultipleAnchors- Automation will not give an error if it finds multiple similar anchors, but tries to find/click the text as per anchor.
    #DefaultTimeout- Automation will try to perform an action until 25s, affecting all keywords

    #Set libraries order
    Set Library Search Order    QWeb                        QForce

    SetConfig                   SearchMode                  draw
    SetConfig                   MultipleAnchors             True
    SetConfig                   DefaultTimeout              25
    Evaluate                    random.seed()               random

    #Steps for test suite setup
    Open Browser                ${LOGIN_URL}                ${BROWSER}
    TypeText                    Username                    ${ORG_USERNAME}
    TypeSecret                  Password                    ${ORG_PASSWORD}
    ClickText                   Log In

    #Switch to lightning if classic view opened and verify logged-in succesfully
    Switch To Lightning
    VerifyAny                   Home, User

End Suite
    [Documentation]             Logout from Salesofrce ORG and Close browser
    #Steps related to test suite teardown- logout and close the browser after the test suite completion
    ${GET_CURRENT_URL}=         GetUrl
    ${LOGOUT_URL}=              Evaluate                    "https://" + '${GET_CURRENT_URL}'.split('/')[2] + "/secur/logout.jsp"
    GoTo                        ${LOGOUT_URL}               #Logout
    Close All Browsers

Open Object
    [Documentation]             Open Object
    [Arguments]                 ${OBJECT}
    #Open App launcher, type and click object
    ClickText                   App Launcher
    VerifyText                  ${APPS_WEBELEMENT}
    TypeText                    ${SEARCH_APPS_WEBELEMENT}                               ${OBJECT}
    ${OBJECT_XPATH}=            Replace String              ${OBJECT_WEBELEMENT}        OBJECT                      ${OBJECT}
    ClickElement                ${OBJECT_XPATH}
    #Refresh and verify object, except for "Work Manager" and "Pipeline Manager" as it works differently
    Run Keyword If              '${OBJECT}' != 'Work Manager' and '${OBJECT}' != 'Pipeline Manager'                 Check object      ${OBJECT}
