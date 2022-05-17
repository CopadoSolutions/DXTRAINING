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
    ${US_ID}=                   Create User Story           User Story                  ${MCDX_PROJECT}      ${MCDX_DEV1_ORG}
    Open Sandbox Developer ORG                              ${MCDX_DEV1_ORG}
    Open Object on Developer ORG                            ${CONTACT_OBJECT}
    ${FIELD}=                   Add new field to object
    ${PROFILE_NAME}=            Create Profile From Existing Profile                    Marketing User
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
    ${METADATA}=                Create List                 ${FIELD}                    ${PROFILE_NAME}
    MC Select Metadata          ${METADATA}
    MC Commit Metadata

    #Then
    Verify Commit Job Execution
    Open Object                 User Stories
    Open record from object main page                       ${US_ID}
    ${FEATURE_BRANCH_NAME}=     Get Feature Branch Name

    #Then: Git assertion
    ${FILES_PATH}=              Get Latest Committed Files Path                         ${MCDX_GIT_REPO}     ${FEATURE_BRANCH_NAME}
    ${FILE_PATH_1}=             Set Variable                ${FILES_PATH}[1]?ref=${FEATURE_BRANCH_NAME}
    ${FILE_PATH_2}=             Set Variable                ${FILES_PATH}[0]?ref=${FEATURE_BRANCH_NAME}
    ${CONTENT_SHA_1}=           Get Branch File Content     ${FILE_PATH_1}                ${MCDX_GIT_REPO}
    ${CONTENT_SHA_2}=           Get Branch File Content     ${FILE_PATH_2}                ${MCDX_GIT_REPO}
    ${EXPECTED_PERMISSION}=     Set Variable                <fieldPermissions> <editable>true</editable> <field>${CONTACT_OBJECT}.${FIELD}__c</field> <readable>true</readable> </fieldPermissions>
    ${EXPECTED_FIELD}=          Set Variable                <fullName>${FIELD}__c</fullName>
    Should Contain              ${CONTENT_SHA_1}[0]          ${EXPECTED_PERMISSION}        strip_spaces=True    collapse_spaces=True
    Should Contain              ${CONTENT_SHA_2}[0]          ${EXPECTED_FIELD}             strip_spaces=True    collapse_spaces=True
    
