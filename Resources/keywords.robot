*** Settings ***
Documentation                   Contains keywords required for the mcdx test case
Library                         String
Library                         QWeb
Library                         QForce
Library                         Collections
Library                         DateTime
Library                         Github.py
Library                         DeleteSFObject.py
Library                         PackagesCli.py

*** Variables ***
${APPS_WEBELEMENT}              xpath\=//h3[normalize-space()\='Apps']
${SEARCH_APPS_WEBELEMENT}       xpath\=//input[@placeholder\="Search apps and items..."]
${OBJECT_WEBELEMENT}            xpath\=//*[@data-label\='OBJECT']
${CANCEL_BUTTON_WEBELEMENT}     xpath\=//button[@title\='Cancel']
${SELECT_RECORD_WEBELEMENT}     xpath\=//tr[1]/td[1]//a[text()\='RECORD']
${US_TITLE_TEXTBOX_WEBELEMENT}                              //*[@name\="copado__User_Story_Title__c"]
${USID_WEBELEMENT}              xpath\=//lightning-formatted-text[@slot\='primaryField' and contains(text(),'US')]
${REFRESH_BUTTON_WEBELEMENT}    xpath\=//button[@title\='Refresh']//lightning-primitive-icon
${SEARCHED_RECORD_WEBELEMENT}                               xpath\=(//tr[1]//a[normalize-space()\='RECORD'])[1]
${SEARCH_FIELD_WEBELEMENT}      xpath\=//input[@id\='globalQuickfind']
${SEARCHED_FIELD_WEBELEMENT}    xpath\=//a[normalize-space()\='FIELD']/span
${QUICK_FIND_WEBELEMENT}        xpath\=(//input[contains(@placeholder,'Quick Find')])[1]
${FLS_CHECKBOX_WEBELEMENT}      xpath\=//th[text()\='ELEMENT']/parent::tr/child::td[2]
${PULL_CHANGES_WEBELEMENT}      xpath\=//button[@title\='Pull Changes']
${COMMIT_CHANGES_BUTTON_WEBELEMENT}                         xpath\=//lightning-button[@copado-userstorycommitheader_userstorycommitheader]/button[text()\='Commit Changes']
${METADATA_CHECKBOX_WEBELEMENT}                             xpath\=//lightning-base-formatted-text[contains(text(),'{METADATA}')]/ancestor::tr//input[@type\='checkbox']/parent::span/parent::lightning-primitive-cell-checkbox
${JOB_RECORD_WEBELEMENT}        xpath\=(//span[text()\='In Progress']/ancestor::tr//a[contains(text(),'JE')])[1]
${JOB_COMPLETED_WEBELEMENT}     xpath\=//strong[text()\='{JOB}']/ancestor::c-result-detail//div[@class\='info']/div[1]
${GIT_BRANCH_WEBELEMENT}        xpath\=//span[contains(@class,'field-label') and text()\='View in Git']/ancestor::flexipage-field//a
${USERNAME_WEBELEMENT}                            xpath\=//input[@id\='username']
${PASSWORD_WEBELEMENT}                            xpath\=//input[@id\='password']
${EE_LOGINBUTTON_WEBELEMENT}                     xpath\=//input[@id\='Login']
${ALLOW_BUTTON_WEBELEMENT}                        xpath\=//input[@id\='oaapprove'] 
${SAVE_CREDENTIAL_WEBELEMENT}                     xpath\=//input[@id=\'thePage:theForm:pb_createOrg:co_pbb:bottom:cb_save']
${FIRST_PROMOTION_INSIDE_US_WEBELEMENT}                 xpath\=(//lightning-primitive-cell-factory[@data-label\="Promotion Name"]/span/div)[1]
${CREDENTIAL_VALUE_WEBELEMENT}                          xpath\=//span[text()\='Credential']/ancestor::record_flexipage-record-field//a//span
${ENVIRONMENT_VALUE_WEBELEMENT}                         xpath\=//span[text()\='Environment']/ancestor::record_flexipage-record-field//a//span
${METADATAAPI_CHECKBOX_WEBELEMENT}      xpath\=//lightning-base-formatted-text[text()\='{METADATA}']/ancestor::tr//input[@type\='checkbox']/parent::span/parent::lightning-primitive-cell-checkbox

${BROWSER}                      chrome
${LOGIN_URL}                    https://login.salesforce.com/
${MCDX_PIPELINE}                MCDX_Automation_Platform_Pipeline
${MCDX_PROJECT}                 MC-DX-Automation_Platform
${MCDX_DEV1_ORG}                mcdxautomationplatform_dev1
${MCDX_DEV2_ORG}                mcdxautomationplatform_dev2
${MCDX_INT_ORG}                 mcdxautomationplatform_int
${MCDX_STAG_ORG}                mcdxautomationplatform_stg
${MCDX_PROD_ORG}                QKQrMCqDsM@copa.do.sandbox
${MCDX_GIT_REPO}                MCDXAutomation_Platform
${ADMIN_USERNAME}               qa-qentinel-automation@copado.com 
${AUTOMATION_ORG_URL}           https://copado-19e-dev-ed.my.salesforce.com
${TOKEN_ENDPOINT}               https://login.salesforce.com/services/oauth2/token

*** Keywords ***
Switch To Lightning
    [Documentation]             Switch to lightning if classic view opened
    ${CLASSIC_VIEW}=            RunKeywordAndReturnStatus                               VerifyText                  Switch to Lightning Experience                          timeout=2
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

Search Field Inside Object
    [Documentation]             Search field inside the object
    [Arguments]                 ${FIELD}
    FOR                         ${I}                        IN RANGE                    0                           2
        ClickElement            ${SEARCH_FIELD_WEBELEMENT}
        TypeText                ${SEARCH_FIELD_WEBELEMENT}                              ${FIELD}
        ${SEARCHED_RECORD}=     Replace String              ${SEARCHED_FIELD_WEBELEMENT}                            FIELD                       ${FIELD}
        ${ISPRESENT}=           IsText                      ${SEARCHED_RECORD}          timeout=60s
        Exit For Loop If        ${ISPRESENT}
    END
    VerifyText                  ${FIELD}

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
    Run Keyword If              '${OBJECT}' != 'Work Manager' and '${OBJECT}' != 'Pipeline Manager'                 Check object                ${OBJECT}

Check object
    [Documentation]             Check the object/tab name
    [Arguments]                 ${OBJECT}
    RefreshPage
    VerifyPageHeader            ${OBJECT}

Create User Story
    [Documentation]             Create User Story from User Story Object and return the ID/Reference
    [Arguments]                 ${RECORD_TYPE}              ${PROJECT}                  ${CREDENTIAL}
    ClickText                   New
    ${US_NAME}=                 Base method for User Story creation                     ${RECORD_TYPE}              ${PROJECT}                  ${CREDENTIAL}
    SetConfig                   PartialMatch                False
    VerifyText                  Plan                        anchor=Build                        timeout=10s
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
    Run Keyword If              '${RECORD_TYPE}'!='Investigation'                       Select record from lookup field                         Search Credentials...       ${CREDENTIAL}        #There is no Credential for Investigation type.
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
    ${RECORD_WEBELEMENT}=       Replace String              ${SELECT_RECORD_WEBELEMENT}                             RECORD                      ${RECORD}
    ClickText                   ${RECORD_WEBELEMENT}

Generate random name
    [Documentation]             Generate random name and return
    ${RANDOM_STRING1}=          Generate Random String
    ${RANDOM_STRING2}=          Generate Random String      6                           [NUMBERS]
    ${NAME}=                    Evaluate                    "Automation_" + "${RANDOM_STRING1}" + "${RANDOM_STRING2}"                           #Using random string twice to avoid duplicate name
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
    ${ISPRESENT}=               Run Keyword And Return Status                           VerifyText                  All                         timeout=5s
    Run Keyword If              ${ISPRESENT}                ClickText                   All
    Run Keyword And Ignore Error                            ClickText                   ALL Env                     timeout=2s
    VerifyNoText                Loading
    PressKey                    Search this list...         ${RECORD}
    VerifyNoText                Loading
    ClickElement                ${REFRESH_BUTTON_WEBELEMENT}
    VerifyNoText                Loading
    ${SEARCHED_RECORD}=         Replace String              ${SEARCHED_RECORD_WEBELEMENT}                           RECORD                      ${RECORD}
    VerifyElement               ${SEARCHED_RECORD}
    VerifyNoText                No items to display

Add new field to object
    [Documentation]             Add the new field to the opened object on developer ORG and return the field name
    ClickText                   New
    ClickText                   Text
    ClickText                   Next
    VerifyText                  New Custom Field
    ${FIELD}=                   Generate random name
    TypeText                    MasterLabel                 ${FIELD}
    TypeText                    Length                      10
    ClickText                   Next
    ClickText                   Next
    ClickText                   Save
    Sleep                       2s
    #Verify field created
    Search field inside Object                              ${FIELD}
    [Return]                    ${FIELD}

Create Profile From Existing Profile
    [Documentation]             To create a profile from existing profile and return the auto generated profile name
    ...                         Author: Shweta
    ...                         Date: 24 November, 2021
    [Arguments]                 ${EXISTING_PROFILE_NAME}    #Enter the name of any existing profile type available
    Open component on Setup Home tab                        Profiles
    VerifyText                  Didn't find what you're looking for? Try using Global Search.
    ${PROFILE_NAME}=            Generate random name
    VerifyAll                   Edit, Delete, Create New View
    ClickText                   New Profile                 anchor=All Profiles
    VerifyText                  Clone Profile
    DropDown                    Existing Profile            option=${EXISTING_PROFILE_NAME}
    TypeText                    Profile Name                ${PROFILE_NAME}
    ClickText                   Save                        anchor=Cancel
    VerifyText                  ${PROFILE_NAME}
    [Return]                    ${PROFILE_NAME}

Open component on Setup Home tab
    [Documentation]             Open any component from Home tab of the Setup page      Ex: Open Profiles/User/Apex Class
    [Arguments]                 ${COMPONENT}
    VerifyText                  Object Manager
    ClickText                   Home
    TypeText                    ${QUICK_FIND_WEBELEMENT}    ${COMPONENT}
    VerifyTextCount             ${COMPONENT}                1
    ClickText                   ${COMPONENT}

Update FLS To Custom Profile
    [Documentation]             To access profile and update object level security
    [Arguments]                 ${OBJECT}                   ${FIELD}                    ${PROFILE_NAME}
    Open Object on Developer ORG                            ${OBJECT}
    Search field inside Object                              ${FIELD}
    ClickText                   ${FIELD}
    VerifyAll                   Field Information, Set Field-Level Security, View Field Accessibility
    ClickText                   Set Field-Level Security
    VerifyAll                   Save, Cancel
    ${ELEMENT}=                 Replace String              ${FLS_CHECKBOX_WEBELEMENT}                              ELEMENT                     ${PROFILE_NAME}
    ClickElement                ${ELEMENT}
    ClickText                   Save
    VerifyAll                   Set Field-Level Security, View Field Accessibility

Open record from object main page    
    [Documentation]             To open the record like Environment/User from the object main page
    [Arguments]                 ${RECORD}
    Search record on object main page                       ${RECORD}
    ClickText                   ${RECORD}
    Sleep                       2s                          #To load new record page

Pull Changes
    [Documentation]             To pull the metadatas based on the date and time provided
    ...                         Author: Dhanesh
    ...                         Date: 8th NOV 2021
    ...                         Modified: 30th NOV 2021
    [Arguments]                 ${DATE}                     ${TIME}
    SetConfig                   PartialMatch                False
    VerifyAll                   Pull Changes by Date, Get Metadata List, Files
    SetConfig                   PartialMatch                True
    TypeText                    Date                        ${DATE}
    ClickText                   Time
    TypeText                    Time                        ${TIME}
    VerifyText                  Pull Changes
    ClickElement                ${PULL_CHANGES_WEBELEMENT}
    VerifyNoText                Loading

MC Select Metadata
    [Documentation]             To MC Select Metadata from the multicloud commit changes page
    ...                         Author: Dhanesh
    ...                         Date: 8th NOV 2021
    [Arguments]                 ${METADATA}                 #Argument is of List type
    ${LENGTH}=                  Get Length                  ${METADATA}
    FOR                         ${I}                        IN RANGE                    0                           ${LENGTH}
        ${EXPECTED}=            Get From List               ${METADATA}                 ${I}
        ${SELECT_METADATA}=     Replace String              ${METADATA_CHECKBOX_WEBELEMENT}                         {METADATA}                  ${EXPECTED}
        SetConfig               PartialMatch                False
        TypeText                Search                      ${EXPECTED}
        PressKey                Search                      {ENTER}
        SetConfig               PartialMatch                True
        VerifyNoText            Loading
        VerifyText              ${EXPECTED}
        ClickElement            ${SELECT_METADATA}
    END
    VerifyNoText                Loading
    VerifyElement               ${COMMIT_CHANGES_BUTTON_WEBELEMENT}
    ClickElement                ${COMMIT_CHANGES_BUTTON_WEBELEMENT}
    VerifyNoText                Loading
    VerifyAll                   Commit Message, Re-create Feature Branch, Change Base Branch

MC Commit Metadata
    [Documentation]             To commit the selected metadata in MC commit page
    ...                         Author : Dhanesh, 8th Nov, 2021
    SetConfig                   PartialMatch                False
    VerifyText                  Commit                      anchor=Cancel
    ClickText                   Commit                      anchor=Cancel
    SetConfig                   PartialMatch                True
    VerifyNoText                Loading
    VerifyText                  User Story Commit

Verify Commit Job Execution
    [Documentation]             To verify the job execution is succesfully completed after committing any metadata
    ...                         Author: Dhanesh
    ...                         Date: 9th NOV 2021
    ...                         update: 7th JAN 2022
    Open Object                 Job Executions
    VerifyText                  Job Execution Name
    ${ISPRESENT}=               Run Keyword And Return Status                           VerifyElement               ${JOB_RECORD_WEBELEMENT}    timeout=2s
    IF                          '${ISPRESENT}' == 'False'
        Run Keyword And Ignore Error                        ClickText                   Select List View            timeout=2s
        ClickText               All
    END
    ClickElement                ${JOB_RECORD_WEBELEMENT}
    VerifyText                  SFDX Commit
    ${COMPLETED_STATUS}=        Replace String              ${JOB_COMPLETED_WEBELEMENT}                             {JOB}                       Commit
    VerifyElementText           ${COMPLETED_STATUS}         Completed                   timeout=600s                reason=To wait until the job executions to get completed

Get Feature Branch Name
    [Documentation]             To get the feature branch name from the user story
    ...                         Author: Dhanesh
    ...                         Date: 13th Jan, 2022
    VerifyText                  Build
    ClickText                   Build
    VerifyText                  View in Git                 anchor=Information
    ${BRANCH_NAME}=             GetText                     ${GIT_BRANCH_WEBELEMENT}
    Should Not Be Empty         ${BRANCH_NAME}              msg=The Git branch field should not be empty
    [Return]                    ${BRANCH_NAME}

Get Latest Committed Files Path
    [Documentation]             To get the latest committed files path as a list from a branch in the git repository
    ...                         Author: Dhanesh
    ...                         Date: 22th DEC, 2021
    [Arguments]                 ${REPOSITORY_NAME}          ${BRANCH_NAME}
    #REPOSITORY_NAME: The name of the git repository from where the commited files path needs to be retrieved
    #BRANCH_NAME: Name of the git branch for the last commit
    ${FILE_PATH}=               Get Commit Files Path       ${GIT_ACCESS_TOKEN}         ${REPOSITORY_NAME}          ${BRANCH_NAME}
    [Return]                    ${FILE_PATH}

Get Branch File Content
    [Documentation]             To get the file contents from a branch based on the file path
    ...                         Author: Dhanesh; 6th Jan, 2022
    [Arguments]                 ${FILE_PATH}                ${REPOSITORY_NAME}
    ${CONTENT_SHA}=             Get Branch File Content Sha                             ${GIT_ACCESS_TOKEN}         ${REPOSITORY_NAME}          ${FILE_PATH}
    [Return]                    ${CONTENT_SHA}

Delete Source Org Object All Records
    [Documentation]             To invoke the python functions and delete all the the source org object records
    ...                         Author: Dhanesh
    ...                         Date: 16th DEC 2021
    [Arguments]                 ${SOBJECT_API_NAME}         ${SOBJECT_FIELD_API_NAME}                               ${PREFIX_TEXT}
    #SOBJECT_API_NAME: Copado API name of the object which needs to be deleted
    #SOBJECT_FIELD_API_NAME: Copado API name of the perticular field inside object for which the Id needs to be fetched
    ${CONNECTION_RESPONSE}=     Salesforce Connect          ${ADMIN_USERNAME}           ${SOURCE_ORG_CLIENTID}      ${SOURCE_CLIENT_SECRET}     ${SOURCE_SECRET_TOKEN}      ${TOKEN_ENDPOINT}
    ${ACCESS_TOKEN}=            Get Access Token            ${CONNECTION_RESPONSE}
    ${RES_JSON_LIST}=           Get Object List             ${ACCESS_TOKEN}             ${SOBJECT_API_NAME}         ${SOBJECT_FIELD_API_NAME}                               ${AUTOMATION_ORG_URL}
    Delete Automation Records                               ${RES_JSON_LIST}            ${SOBJECT_FIELD_API_NAME}                               ${ACCESS_TOKEN}             ${SOBJECT_API_NAME}    ${AUTOMATION_ORG_URL}    ${PREFIX_TEXT}



CreateJsonInDirectory
    [Documentation]             To create a json file inside the project Directory
    ...                         Author: Dhanesh
    ...                         Date: 17th FEB, 2022
    [Arguments]                 ${VALUE}                    ${FILE_NAME}                ${PROJECT_NAME}             ${KEY}
    #PROJECT_NAME: The name of the project created
    #VALUE: The sfdxAuthUrl value
    #FILE_NAME: The name of the json file which needs to be created
    #KEY: The json key to create the json
    ${PATH}=                    Set Variable                "/tmp/execution/${PROJECT_NAME}"
    Create Auth Json            ${VALUE}                    ${FILE_NAME}                ${KEY}
    ${DIRS}=                    Evaluate                    os.listdir(${PATH})
    Log                         ${DIRS}                     console=true
    Should Contain              ${DIRS}                     ${FILE_NAME}

AuthorizeToOrg
    [Documentation]             To authorize to any org using sfdxauthurl
    ...                         Author: Dhanesh
    ...                         Date: 14th FEB, 2022
    [Arguments]                 ${PATH}
    #PATH: Directory path of the json file created inside the project
    ${OUTPUT}=                  Auth Orgs                   ${PATH}
    Log                         ${OUTPUT}                   console=true
    Should Contain              ${OUTPUT}                   Successfully authorized

Clone Git Repo
    [Documentation]             It will help to clone git on the docker environment
    ...                         Author: Sachin Talwaria
    ...                         Date: 24th March, 2022
    [Arguments]                 ${CLONE_URL}
    ${GIT_CLONE_STATUS}=        Evaluate                    os.system('git clone '+${CLONE_URL})
    Log                         ${GIT_CLONE_STATUS}         console=true
    ${DIRS}=                    Evaluate                    os.listdir(os.getcwd())
    Log                         ${DIRS}                     console=true
    ${GIT_CLONE_STATUS}=        Evaluate                    os.system('git status')
    Log                         ${GIT_CLONE_STATUS}         console=true

Clone Private Git Repo
    [Arguments]    ${CLONE_URL}    ${USER_NAME}    ${PASSWORD}    
    #${STATUS}=           Evaluate       os.system('git config --global user.email '+${USER_NAME})
    #Log                         ${STATUS}         console=true
    #${STATUS}=                  Evaluate       os.system('git config --global user.password '+${PASSWORD})
    #Log                         ${STATUS}         console=true
    ${GIT_CLONE_STATUS}=        Evaluate                    os.system('git clone '+${CLONE_URL})
    Log                         ${GIT_CLONE_STATUS}         console=true
    ${DIRS}=                    Evaluate                    os.listdir(os.getcwd())
    Log                         ${DIRS}                     console=true
    ${GIT_CLONE_STATUS}=        Evaluate                    os.system('git status')
    Log                         ${GIT_CLONE_STATUS}         console=true

Delete All File From Git Branch                        
    [Arguments]    ${BRANCH_NAME}    ${MESSAGE}
    ${GIT_CHECKOUT_STATUS}=     Evaluate       os.system('git checkout '+${BRANCH_NAME})
    Log                         ${GIT_CHECKOUT_STATUS}         console=true
    ${GIT_DELETE_STATUS}=     Evaluate       os.system('git rm -r *')
    Log                         ${GIT_DELETE_STATUS}         console=true
    ${GIT_ADD_STATUS}=     Evaluate       os.system('git add .')
    Log                         ${GIT_ADD_STATUS}         console=true
    ${GIT_COMMIT_STATUS}=     Evaluate       os.system('git commit -a -m ${MESSAGE}')
    Log                         ${GIT_COMMIT_STATUS}         console=true
    ${GIT_STATUS}=        Evaluate                    os.system('git status')
    Log                         ${GIT_STATUS}         console=true
    ${GIT_PUSH}=        Evaluate                    os.system('git push origin '+${BRANCH_NAME})
    Log                         ${GIT_PUSH}         console=true

Create New Directory
    [Documentation]             It will help to create new folder on specific location
    ...                         Author: Sachin Talwaria
    ...                         Date: 24th March, 2022
    [Arguments]                 ${PATH}                     ${DIR_NAME}
    Evaluate                    os.chdir(${PATH})
    ${PATH}=                    Evaluate                    os.path.join(${PATH}, ${DIR_NAME})
    ${TEST}=                    Evaluate                    os.getcwd()
    Log To Console              ${TEST}
    Evaluate                    os.mkdir('${PATH}')
    Evaluate                    os.chdir('${PATH}')
    ${DIR}=                     Evaluate                    os.getcwd()
    Log                         ${DIR}                      console=true

Update Credential Type And User
    [Documentation]             To get the context id from a credential
    ...                         Author: Sachin
    ...                         Date: 11th May 2022
    [Arguments]                 ${CREDENTIAL}               ${USERNAME}                 ${PASSWORD}
    Open Object                 Credentials
    Run Keyword And Ignore Error                            ClickText                   Select List View
    ${ISPRESENT}=               Run Keyword And Return Status                           VerifyText                All           timeout=5s
    Run Keyword If              ${ISPRESENT}                ClickText                   All
    Run Keyword And Ignore Error                            ClickText                   ALL Env                   timeout=2s
    VerifyNoText                Loading
    PressKey                    Search this list...         ${CREDENTIAL}
    VerifyNoText                Loading
    ClickElement                ${REFRESH_BUTTON_WEBELEMENT}
    VerifyNoText                Loading
    VerifyText                  ${CREDENTIAL}               anchor=Credential Name
    ClickText                   ${CREDENTIAL}               anchor=Credential Name
    ClickText                   Hide message                anchor=Loading
    VerifyNoText                Loading
    ClickText                   Authenticate                anchor=Delete
    Sleep                       3s                          #Waiting for the login page
    CloseWindow
    SwitchWindow                NEW
    TypeText                    ${USERNAME_WEBELEMENT}      ${USERNAME}
    TypeText                    ${PASSWORD_WEBELEMENT}      ${PASSWORD}
    ClickElement                ${EE_LOGINBUTTON_WEBELEMENT}                            timeout=5s
    VerifyText                  Allow Access?
    ClickElement                ${ALLOW_BUTTON_WEBELEMENT}
    Sleep                       7s                          #To wait until Page is loaded
    RefreshPage
    Open Object                 Credentials

Enable Promote and Deploy
    [Documentation]             Enable "Promote and Deploy" for User Story
    ClickText                   Deliver
    ClickText                   Edit Promote and Deploy
    ClickText                   Promote and Deploy
    ClickText                   Save

Open Promotion through User Story
    [Documentation]             Open the Promotion available in user story and wait until the deployment creation
    VerifyNoText                Loading
    ClickText                   Plan
    VerifyNoText                Loading
    ClickText                   Deliver
    ScrollText                  User Story Promotions
    VerifyNoText                Loading
    VerifyElement               ${FIRST_PROMOTION_INSIDE_US_WEBELEMENT}
    ClickElement                ${FIRST_PROMOTION_INSIDE_US_WEBELEMENT}
    VerifyText                  Promotion                   #To check promotion page loaded
    ${PROGRESS_WINDOW}=         RunKeywordAndReturnStatus                               VerifyText                  Hide message                timeout=5s
    Run Keyword If              ${PROGRESS_WINDOW}          ClickText                   Hide Message

Verify MC User Story Promotion
    [Documentation]             To verify the user story movement to next environment in user story Page
    ...                         Author: Shweta B
    ...                         Date: 9th November 2021
    [Arguments]                 ${DESTINATION_ENVIRONMENT}
    #To verify the source environment updated in the userstory page. UserStory must be loaded.
    RefreshPage
    VerifyAll                   Plan, Build, Test, Deliver, Related
    ClickText                   Build
    VerifyText                  Credential
    ${CREDENTIAL_VALUE}=        GetText                     ${CREDENTIAL_VALUE_WEBELEMENT}
    Should Be Equal             ${CREDENTIAL_VALUE}         ${DESTINATION_ENVIRONMENT}
    VerifyText                  Environment
    ${ENVIRONMENT_VALUE}=       GetText                     ${ENVIRONMENT_VALUE_WEBELEMENT}
    Should Be Equal             ${ENVIRONMENT_VALUE}        ${DESTINATION_ENVIRONMENT}

Verify Promote And Deploy Job Execution
    [Documentation]             To verify the job execution is succesfully completed after promote and deploy
    ...                         Author: Dhanesh
    ...                         Date: 10th NOV 2021
    ClickText                   Details
    VerifyText                  Promotion Name              anchor=Information
    VerifyText                  SFDX Promote
    ${JOB_NAMES}=               Create List                 Promote                     Encode file names           Deploy
    FOR                         ${I}                        IN RANGE                    0                           3
        ${JOB}=                 Get From List               ${JOB_NAMES}                ${I}
        ${COMPLETED_STATUS}=    Replace String              ${JOB_COMPLETED_WEBELEMENT}                             {JOB}                       ${JOB}
        VerifyElementText       ${COMPLETED_STATUS}         Completed                   timeout=600s                reason=To wait until the job executions to get completed
    END
    VerifyText                  SFDX Deploy
    VerifyText                  Step result:                anchor=Promote
    VerifyText                  Step result:                anchor=Encode file names
    VerifyText                  Step result:                anchor=Deploy

Select Metadata with API Name And Commit
    [Documentation]         To select metadata with API Name and commit in the multicloud commit changes page
    ...                     Author: Sachin Talwaria
    ...                     Modified Date: 22nd FEB, 2022
    [Arguments]             ${METADATA}    ${RECREATE_FEATURE_BRANCH}                 #Input the exact field name as displayed in commit page[Along with the API Name] & Re-create variable will mark chekbox as yes (i.e. true) or no (i.e. false) 
    ${LENGTH}=              Get Length                  ${METADATA}
    FOR                     ${I}                        IN RANGE                    0                          ${LENGTH}
        ${EXPECTED}=        Get From List               ${METADATA}                 ${I}
        ${SELECT_METADATA}=                             Replace String              ${METADATAAPI_CHECKBOX_WEBELEMENT}             {METADATA}    ${EXPECTED}
        SetConfig           PartialMatch                False
        TypeText            Search                      ${EXPECTED}
        PressKey            Search                      {ENTER}
        SetConfig           PartialMatch                True
        VerifyNoText        Loading
        VerifyText          ${EXPECTED}
        ClickElement        ${SELECT_METADATA}
    END
    VerifyNoText            Loading
    VerifyElement           ${COMMIT_CHANGES_BUTTON_WEBELEMENT}
    ClickElement            ${COMMIT_CHANGES_BUTTON_WEBELEMENT}
    VerifyNoText            Loading
    VerifyAll               Commit Message, Re-create Feature Branch, Change Base Branch
    IF                     "${RECREATE_FEATURE_BRANCH}" == "TRUE"
        ClickCheckbox       Re-create Feature Branch    on
    END
    SetConfig               PartialMatch                False
    VerifyText              Commit                      anchor=Change Base Branch                        timeout=10s
    ClickText               Commit                      anchor=Change Base Branch                        timeout=10s
    SetConfig               PartialMatch                True
    VerifyNoText            Loading
    VerifyText              User Story Commit