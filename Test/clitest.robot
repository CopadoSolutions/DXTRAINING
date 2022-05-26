*** Settings ***
Documentation                   Test cases related to multicloud back promotion
Resource                        ../Resources/keywords.robot
Suite Setup                     DX Start Suite
Suite Teardown                  DX End Suite


*** Variables ***
${DEVHUB_JSON_NAME}             DXCoreDevHubAuth.json
${AUTOORG_JSON_NAME}            AutoOrgAuth.json
${SFDX_PROJECT_NAME}            DXTRAINING/Metadata repo/DXCoreDataCenter
${KEY}                          sfdxAuthUrl
${DXCOREDEVHUB_ORG_USERNAME}    devhub_automation@copado.com
${DXCORE_DEVHUB_AUTH_URL}       force://PlatformCLI::5Aep861mdLLi91HqFcHZFTlvZKcYoXVHVWA816nz2ZJ43hx8Rxzc2g9cZ8x8JXFE7cYCvmCER_5abzcczrZWViI@copado-c-dev-ed.my.salesforce.com
${PLATFORM_AUTH_URL}            force://PlatformCLI::5Aep861ryecz0qkv5zpJzdOKjyCDhgU7x_sGpx2qF_pEJuYd_iigSdbO90h.DPk0b1Nkb6yg1TwDTuTd6vIGo3X@copado-b6.my.salesforce.com

*** Keywords ***

DX End Suite

    #Empty the repo
    #Create New Directory        "/tmp/execution/DXTRAINING"                             "Pipeline repo"
    #Evaluate                    os.chdir('/tmp/execution/DXTRAINING/Pipeline repo')
    #Clone Private Git Repo      "https://github.com/stalwaria/STMCDXautomationrepo.git"                "stalwaria@copado.com"     "Parveen_2022"
    #${DIRS}=                    Evaluate                    os.listdir(os.getcwd())
    #Log                         ${DIRS}                     console=true
    #Evaluate                    os.chdir('/tmp/execution/DXTRAINING/Pipeline repo/STMCDXautomationrepo')
    #Delete All File From Git Branch                         "main"                      "Delete all stuff"
    #Delete All File From Git Branch                         "dev1"                      "Delete all stuff"

    #Authentication
    Evaluate                    os.chdir('/tmp/execution/DXTRAINING/Metadata repo/DXCoreDataCenter')
    CreateJsonInDirectory       ${DXCORE_DEVHUB_AUTH_URL}                               ${DEVHUB_JSON_NAME}         ${SFDX_PROJECT_NAME}        ${KEY}
    CreateJsonInDirectory       ${PLATFORM_AUTH_URL}        ${AUTOORG_JSON_NAME}        ${SFDX_PROJECT_NAME}        ${KEY}
    AuthorizeToOrg              ${DEVHUB_JSON_NAME}
    AuthorizeToOrg              ${AUTOORG_JSON_NAME}
    Set Default Devhub          ${DXCOREDEVHUB_ORG_USERNAME}

    #Delete the pipeline connection
    Delete Record Using Cli     copado__Deployment_Flow_Step__c                         ${pipelineconnectionid}     ${ORG_USERNAME}

    #Delete the pipeline
    Delete Record Using Cli     copado__Deployment_Flow__c                              ${pipelineid}               ${ORG_USERNAME}

    #Get promotion and destination org ID
    ${OUTPUT}=                  Run Soql Query              "SELECT Id FROM copado__Destination_Org__c WHERE copado__To_Org_Name__c='AutodestEnv' or copado__To_Org_Name__c='AutosrcEnv'"    ${ORG_USERNAME}
    Delete Record Using Cli     copado__Destination_Org__c                              ${OUTPUT}                   ${ORG_USERNAME}
    ${OUTPUT}=                  Run Soql Query              "SELECT Id FROM copado__Promotion__c WHERE copado__Project__c='a0z09000002zG3CAAU'"                    ${ORG_USERNAME}
    Delete Record Using Cli     copado__Promotion__c        ${OUTPUT}                   ${ORG_USERNAME}

    #Delete the credential
    Delete Record Using Cli     copado__Org__c              ${credentialdevoneid}       ${ORG_USERNAME}
    Delete Record Using Cli     copado__Org__c              ${credentialprodid}         ${ORG_USERNAME}

    #Delete the environment
    Delete Record Using Cli     copado__Environment__c      ${environmentdevoneid}      ${ORG_USERNAME}
    Delete Record Using Cli     copado__Environment__c      ${environmentprodid}        ${ORG_USERNAME}

    #Delete the scratch org
    CreateJsonInDirectory       ${scratchoneauthurl}        ScratchOrgOne.json          ${SFDX_PROJECT_NAME}        ${KEY}
    CreateJsonInDirectory       ${scratchtwoauthurl}        ScratchOrgTwo.json          ${SFDX_PROJECT_NAME}        ${KEY}
    AuthorizeToOrg              ScratchOrgOne.json
    AuthorizeToOrg              ScratchOrgTwo.json
    Delete Org Using Cli        ${scratchoneusername}       ${DXCOREDEVHUB_ORG_USERNAME}
    Delete Org Using Cli        ${scratchtwousername}       ${DXCOREDEVHUB_ORG_USERNAME}

    Evaluate                    os.chdir('/tmp/execution/DXTRAINING')
    ${DIRS}=                    Evaluate                    os.listdir(os.getcwd())
    Log                         ${DIRS}                     console=true



DX Start Suite
    [Documentation]             Metadata Creation, pipeline and environment creation
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

    
    #Repo Clone
    Create New Directory        "/tmp/execution/DXTRAINING"                             "Metadata repo"
    Clone Git Repo              "https://github.com/stalwaria/DXCoreDataCenter.git"
    Evaluate                    os.chdir('/tmp/execution/DXTRAINING/Metadata repo/DXCoreDataCenter')
    ${DIRS}=                    Evaluate                    os.listdir(os.getcwd())
    Log                         ${DIRS}                     console=true

    #Authentication
    CreateJsonInDirectory       ${DXCORE_DEVHUB_AUTH_URL}                               ${DEVHUB_JSON_NAME}         ${SFDX_PROJECT_NAME}        ${KEY}
    CreateJsonInDirectory       ${PLATFORM_AUTH_URL}        ${AUTOORG_JSON_NAME}        ${SFDX_PROJECT_NAME}        ${KEY}
    AuthorizeToOrg              ${DEVHUB_JSON_NAME}
    AuthorizeToOrg              ${AUTOORG_JSON_NAME}
    Set Default Devhub          ${DXCOREDEVHUB_ORG_USERNAME}

    #DX setup
    #Scratch Org 1
    ${ORG_NAME}                 Set Variable                AutosrcEnv
    ${OUTPUT}=                  Create Scratch Org          ${ORG_NAME}                 "/tmp/execution/DXTRAINING/Metadata repo/DXCoreDataCenter/config/ctx2-dev-scratch.json"    ${DXCOREDEVHUB_ORG_USERNAME}    1
    ${ORG_DETAILS}=             String.Split String         ${OUTPUT}                   ;
    Set Suite variable          ${scratchoneorgid}          ${ORG_DETAILS}[0]
    Set Suite variable          ${scratchoneusername}       ${ORG_DETAILS}[1]
    ${OUTPUT}=                  Get Scratch Org Auth Url    ${scratchoneusername}
    Set Suite variable          ${scratchoneauthurl}        ${OUTPUT}
    ${PASSWORD}=                Reset Org Password          ${ORG_NAME}                 ${DXCOREDEVHUB_ORG_USERNAME}
    Set Copado Org              ${ORG_USERNAME}
    Set Suite variable          ${scratchonepassword}       ${PASSWORD}
    ${OUTPUT}=                  Push Metadata From Git      ${ORG_NAME}
    ${OUTPUT}=                  Create New Environment      ${ORG_NAME}                 ${scratchoneusername}
    Set Suite variable          ${credentialdevoneid}       ${OUTPUT}
    ${OUTPUT}=                  Get Environmentid           ${credentialdevoneid}       ${ORG_USERNAME}
    Set Suite variable          ${environmentdevoneid}      ${OUTPUT}
    sleep                       5s
    ${scratchoneinstanceurl}    Get Org User Details        ${scratchoneusername}       ${DXCOREDEVHUB_ORG_USERNAME}
    Update Record Using Cli     copado__Environment__c      ${environmentdevoneid}      copado__Platform__c         SFDX                        ${ORG_USERNAME}
    Update Record Using Cli     copado__Org__c              ${credentialdevoneid}       copado__Org_Type__c         Custom Domain               ${ORG_USERNAME}
    Update Record Using Cli     copado__Org__c              ${credentialdevoneid}       copado__Custom_Domain__c    ${scratchoneinstanceurl}    ${ORG_USERNAME}
    Update User Ip Ranges       ${scratchoneusername}       52.0.0.0-52.255.255.255,18.0.0.0-18.255.255.255,3.0.0.0-3.255.255.255,75.0.0.0-75.255.255.255
    Update Credential Type And User                         ${ORG_NAME}                 ${scratchoneusername}       ${scratchonepassword}

    #Scratch Org 2
    ${ORG_NAME}                 Set Variable                AutodestEnv
    ${OUTPUT}=                  Create Scratch Org          ${ORG_NAME}                 "/tmp/execution/DXTRAINING/Metadata repo/DXCoreDataCenter/config/ctx2-dev-scratch.json"    ${DXCOREDEVHUB_ORG_USERNAME}    1
    ${ORG_DETAILS}=             String.Split String         ${OUTPUT}                   ;
    Set Suite variable          ${scratchtwoorgid}          ${ORG_DETAILS}[0]
    Set Suite variable          ${scratchtwousername}       ${ORG_DETAILS}[1]
    ${OUTPUT}=                  Get Scratch Org Auth Url    ${scratchtwousername}
    Set Suite variable          ${scratchtwoauthurl}        ${OUTPUT}
    ${PASSWORD}=                Reset Org Password          ${ORG_NAME}                 ${DXCOREDEVHUB_ORG_USERNAME}
    Set Copado Org              ${ORG_USERNAME}
    Set Suite variable          ${scratchtwopassword}       ${PASSWORD}
    ${OUTPUT}=                  Create New Environment      ${ORG_NAME}                 ${scratchtwousername}
    Set Suite variable          ${credentialprodid}         ${OUTPUT}
    ${OUTPUT}=                  Get Environmentid           ${credentialprodid}         ${ORG_USERNAME}
    Set Suite variable          ${environmentprodid}        ${OUTPUT}
    sleep                       5s
    ${scratchtwoinstanceurl}    Get Org User Details        ${scratchtwousername}       ${DXCOREDEVHUB_ORG_USERNAME}
    Update Record Using Cli     copado__Environment__c      ${environmentprodid}        copado__Platform__c         SFDX                        ${ORG_USERNAME}
    Update Record Using Cli     copado__Org__c              ${credentialprodid}         copado__Org_Type__c         Custom Domain               ${ORG_USERNAME}
    Update Record Using Cli     copado__Org__c              ${credentialprodid}         copado__Custom_Domain__c    ${scratchtwoinstanceurl}    ${ORG_USERNAME}
    Update User Ip Ranges       ${scratchtwousername}       52.0.0.0-52.255.255.255,18.0.0.0-18.255.255.255,3.0.0.0-3.255.255.255,75.0.0.0-75.255.255.255
    Update Credential Type And User                         ${ORG_NAME}                 ${scratchtwousername}       ${scratchtwopassword}

    #Pipeline Creation
    ${PIPELINE_NAME}            Set Variable                SFDX_Pipeline
    ${OUTPUT}                   Create New Pipeline         ${PIPELINE_NAME}            a0p09000001839RAAQ          main                        SFDX
    Set Suite variable          ${pipelineid}               ${OUTPUT}

    #Pipeline Connection
    ${OUTPUT}                   Create New Pipeline Connection                          ${pipelineid}               ${environmentprodid}        ${environmentdevoneid}     dev1    main
    Set Suite variable          ${pipelineconnectionid}     ${OUTPUT}
    Update Record Using Cli     copado__Deployment_Flow__c                              ${pipelineid}               copado__CommitJobTemplate__c                   a2009000000arEKAAY    ${ORG_USERNAME}
    Update Record Using Cli     copado__Deployment_Flow__c                              ${pipelineid}               copado__Promotion_Job_Template__c              a2009000000arEMAAY    ${ORG_USERNAME}
    Update Record Using Cli     copado__Deployment_Flow__c                              ${pipelineid}               copado__Deployment_Job_Template__c             a2009000000arELAAY    ${ORG_USERNAME}


    #Pipeline connection update
    Update Record Using Cli     copado__Deployment_Flow_Step__c                         ${pipelineconnectionid}     copado__Source_Environment__c                  ${environmentdevoneid}    ${ORG_USERNAME}
    Update Record Using Cli     copado__Deployment_Flow_Step__c                         ${pipelineconnectionid}     copado__Destination_Environment__c             ${environmentprodid}    ${ORG_USERNAME}

    #Add Pipeline to the project
    Update Record Using Cli     copado__Project__c          a0z09000002zG3CAAU          copado__Deployment_Flow__c                              ${pipelineid}      ${ORG_USERNAME}


*** Test Cases ***
Commit Existing Metadata 
    [Documentation]             test
    Open Object                 User Stories
    ${US_ID1}=                  Create User Story           User Story                  SFDXProject                 AutosrcEnv
    VerifyText                  Commit Changes
    ClickText                   Commit Changes
    ${CURRENT_DATE}=            Get Current Date            result_format=%d.%m.%Y
    Pull Changes                ${CURRENT_DATE}             00:00
    ${METADATA}=                Create List                 pctxd_customlabel1
    Select Metadata with API Name And Commit                ${METADATA}                 FALSE
    Verify Commit Job Execution
    Open Object                 User Stories
    Open record from object main page                       ${US_ID1}
    Enable Promote and Deploy
    VerifyNoText                Loading
    Open Promotion through User Story
    Verify Promote And Deploy Job Execution
    ExecuteJavascript           window.history.back();
    Open Object                 User Stories
    Open record from object main page                       ${US_ID1}
    Verify MC User Story Promotion                          AutodestEnv

Test Live 
    #Empty the repo
    Create New Directory        "/tmp/execution/DXTRAINING"                             "Pipeline repo"
    Evaluate                    os.chdir('/tmp/execution/DXTRAINING/Pipeline repo')
    Clone Private Git Repo      "https://github.com/stalwaria/STMCDXautomationrepo.git"                "stalwaria@copado.com"     "Parveen_2022"
    ${DIRS}=                    Evaluate                    os.listdir(os.getcwd())
    Log                         ${DIRS}                     console=true
    Evaluate                    os.chdir('/tmp/execution/DXTRAINING/Pipeline repo/STMCDXautomationrepo')
    Delete All File From Git Branch                         "main"                      "Delete all stuff"
    Delete All File From Git Branch                         "dev1"                      "Delete all stuff"