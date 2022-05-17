*** Settings ***
Documentation                   Contains keywords required for the mcdx test case
Library                         String
Library                         QWeb
Library                         QForce
Library                         Collections
Library                         DateTime

*** Variables ***
${APPS_WEBELEMENT}              xpath\=//h3[normalize-space()\='Apps']
${SEARCH_APPS_WEBELEMENT}       xpath\=//input[@placeholder\="Search apps and items..."]
${OBJECT_WEBELEMENT}            xpath\=//*[@data-label\='OBJECT']
${CANCEL_BUTTON_WEBELEMENT}     xpath\=//button[@title\='Cancel']
${SELECT_RECORD_WEBELEMENT}     xpath\=//tr[1]/td[1]//a[text()\='RECORD']
${US_TITLE_TEXTBOX_WEBELEMENT}                              //*[@name\="copado__User_Story_Title__c"]
${USID_WEBELEMENT}              xpath\=//lightning-formatted-text[@slot\='primaryField' and contains(text(),'US')]
${REFRESH_BUTTON_WEBELEMENT}                            xpath\=//button[@title\='Refresh']//lightning-primitive-icon
${SEARCHED_RECORD_WEBELEMENT}                           xpath\=(//tr[1]//a[normalize-space()\='RECORD'])[1]

*** Keywords ***
Switch To Lightning
    [Documentation]             Switch to lightning if classic view opened
    ${CLASSIC_VIEW}=            RunKeywordAndReturnStatus                               VerifyText                  Switch to Lightning Experience               timeout=2
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
    Run Keyword If              '${OBJECT}' != 'Work Manager' and '${OBJECT}' != 'Pipeline Manager'                 Check object     ${OBJECT}

Check object
    [Documentation]             Check the object/tab name
    [Arguments]                 ${OBJECT}
    RefreshPage
    VerifyPageHeader            ${OBJECT}

Create User Story
    [Documentation]             Create User Story from User Story Object and return the ID/Reference
    [Arguments]                 ${RECORD_TYPE}              ${PROJECT}                  ${CREDENTIAL}
    ClickText                   New
    ${US_NAME}=                 Base method for User Story creation                     ${RECORD_TYPE}              ${PROJECT}       ${CREDENTIAL}
    SetConfig                   PartialMatch                False
    VerifyText                  Plan
    VerifyText                  ${US_NAME}                  anchor=User Story Reference
    SetConfig                   PartialMatch                True
    ${US_ID}=                   GetText                     ${USID_WEBELEMENT}
    [Return]                    ${US_ID}

Base method for User Story creation
    [Documentation]             Create User Story and return the User Story Name
    [Arguments]                 ${RECORD_TYPE}              ${PROJECT}                  ${CREDENTIAL}
    #Open "New User Story" window, select record type as per argument and enter other details
    SetConfig                   PartialMatch                True
    VerifyText                  New User Story
    ClickText                   ${RECORD_TYPE}
    ClickText                   Next
    VerifyText                  New User Story              #Check window loaded properly
    ${US_NAME}=                 Generate random name
    TypeText                    ${US_TITLE_TEXTBOX_WEBELEMENT}                          ${US_NAME}
    Select record from lookup field                         Search Projects...          ${PROJECT}
    Sleep                       2s                          #Wait to hanldle timming issue
    Run Keyword If              '${RECORD_TYPE}'!='Investigation'                       Select record from lookup field              Search Credentials...       ${CREDENTIAL}    #There is no Credential for Investigation type.
    #Save the US and return the user story name
    ClickText                   Save                        2
    [Return]                    ${US_NAME}

Select record from lookup field
    [Documentation]             Search and select the record in the lookup field
    [Arguments]                 ${FIELD}                    ${RECORD}
    PressKey                    ${FIELD}                    ${RECORD}
    VerifyText                  Show All Results
    PressKey                    ${FIELD}                    {ENTER}
    VerifyText                  ${CANCEL_BUTTON_WEBELEMENT}                             #Checking modal openend
    ${RECORD_WEBELEMENT}=       Replace String              ${SELECT_RECORD_WEBELEMENT}                             RECORD           ${RECORD}
    ClickText                   ${RECORD_WEBELEMENT}

Generate random name
    [Documentation]             Generate random name and return
    ${RANDOM_STRING1}=          Generate Random String
    ${RANDOM_STRING2}=          Generate Random String      6                           [NUMBERS]
    ${NAME}=                    Evaluate                    "Automation_" + "${RANDOM_STRING1}" + "${RANDOM_STRING2}"                #Using random string twice to avoid duplicate name
    [Return]                    ${NAME}

Open Object on Developer ORG
    [Documentation]             Open Object on developer ORG
    [Arguments]                 ${OBJECT}
    VerifyText                  Object Manager
    ClickText                   Object Manager
    VerifyText                  Schema Builder
    TypeText                    Quick Find                  ${OBJECT}                   anchor=Schema Builder
    Sleep                       2s                          #Added to wait for page load
    VerifyText                  ${OBJECT}                   2
    ClickText                   ${OBJECT}
    ClickText                   Fields & Relationships

Open Sandbox Developer ORG
    [Documentation]             To open the developer org through sandbox from any user story
    ...                         Author: Dhanesh
    ...                         Date: 11th NOV 2021
    ...                         Modified: 30th NOV 2021
    [Arguments]                 ${ORG}
    LaunchApp                   Credentials
    VerifyNoText                Loading
    Search record on object main page                       ${ORG}
    ClickText                   ${ORG}
    VerifyText                  Open Org
    ClickText                   Open Org
    Sleep                       10s                         reason=To handle the time taken to load to open the next tab
    VerifyNoText                Loading                     anchor=Hide message
    SwitchWindow                2
    VerifyNoText                Loading                     anchor=Hide message
    VerifyText                  Sandbox
    ClickText                   Setup
    VerifyText                  Setup for current app
    ClickText                   Setup for current app
    Sleep                       10s                         reason=To handle the time taken to load to open the next tab
    VerifyNoText                Loading                     anchor=Hide message
    SwitchWindow                3
    VerifyNoText                Loading                     anchor=Hide message
    VerifyText                  Object Manager

Search record on object main page
    [Documentation]             Search record on object main page
    [Arguments]                 ${RECORD}
    Run Keyword And Ignore Error                            ClickText                   Select a List View
    ${ISPRESENT}=               Run Keyword And Return Status                           VerifyText                  All               timeout=5s
    Run Keyword If              ${ISPRESENT}                ClickText                   All
    Run Keyword And Ignore Error                            ClickText                   ALL Env                     timeout=2s
    VerifyNoText                Loading
    PressKey                    Search this list...         ${RECORD}
    VerifyNoText                Loading
    ClickElement                ${REFRESH_BUTTON_WEBELEMENT}
    VerifyNoText                Loading
    ${SEARCHED_RECORD}=         Replace String              ${SEARCHED_RECORD_WEBELEMENT}                           RECORD            ${RECORD}
    VerifyElement               ${SEARCHED_RECORD}
    VerifyNoText                No items to display