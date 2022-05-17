*** Settings ***
Documentation                   Test cases related to multicloud back promotion
Resource                        ../Resources/keywords.robot
Test Setup                      Start Suite
Test Teardown                   End Suite

*** Variables ***
${CONTACT_OBJECT}               Contact

*** Test Cases ***
Verify commit operation for Profiles and Fields
    [Tags]                      MultiCloud
    [Documentation]             Author: Dhanesh
    #Use case:
    #Given: 2 Orgs using an MCDX pipeline, and the Src Org contains a new field and a profile with access to that field
    #When: a MCDX commit in the US-XXX with selection of the field and the profile is performed << this is the action to be tested
    #Then: the repository in the branch US-XXX we will find the right metadata for that profile field permissions and the field XML.

    #Given
    Open Object                 User Stories
    ${US_ID}=                   Create User Story           User Story                ${MCDX_PROJECT}    ${MCDX_DEV1_ORG}
    Open Sandbox Developer ORG                              ${MCDX_DEV1_ORG}
    Open Object on Developer ORG                            ${CONTACT_OBJECT}
    ${FIELD}=                   Add new field to object
    ${PROFILE_NAME}=            Create Profile From Existing Profile                  Marketing User
    Update FLS To Custom Profile                            ${CONTACT_OBJECT}         ${FIELD}           ${PROFILE_NAME}
    CloseWindow
    VerifyNoText                Loading
    CloseWindow

    #when
    Open Object                 User Stories
    Open record from object main page                       ${US_ID}
    VerifyText                  Commit Changes
    ClickText                   Commit Changes
    ${CURRENT_DATE}=            Get Current Date            result_format=%d.%m.%Y
    Pull Changes                ${CURRENT_DATE}             00:00
    ${METADATA}=                Create List                 ${FIELD}                  ${PROFILE_NAME}
    MC Select Metadata          ${METADATA}
    MC Commit Metadata

    #Then
    Verify Commit Job Execution
    Open Object                 User Stories
    Open record from object main page                       ${US_ID}
    ${FEATURE_BRANCH_NAME}=     Get Feature Branch Name

    #Then: Git assertion
    #${FILES_PATH}=             Get Latest Committed Files Path                       ${MCDX_GIT_REPO}                        ${BRANCH_NAME}
    #${CONTENT_SHA}=            Get Branch File Content     ${FILES_PATH}[0]?ref=${BRANCH_NAME}          ${MCDX_GIT_REPO}
    #${EXPECTED}=               Set Variable                <recordTypes> <description></description> <label>${TRANSLATION_NAME}</label> <name>${RECORDTYPE_NAME}</name> </recordTypes>
    #Should Contain             ${CONTENT_SHA}[0]           ${EXPECTED}               strip_spaces=True                       collapse_spaces=True
