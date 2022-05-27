*** Settings ***
Documentation                   Test cases related to multicloud back promotion
Resource                        ../Resources/keywords.robot
Test Setup                      Start Suite
Test Teardown                   End Suite

*** Variables ***
${CONTACT_OBJECT}               Contact
${SOBJECT_API_NAME}             copado__User_Story__c
${SOBJECT_FIELD_API_NAME}       Name

*** Test Cases ***
Verify commit operation for Profiles and Fields
    [Tags]                      MultiCloud
    [Documentation]             Author: Dhanesh
    #Use case:
    #Create a custom field and a  profile with access to the field - UI
    #Create a User Story and commit the custom field and profile - UI
    #Verify the commit job is successful - UI
    #Verify the feature branch consist of field permission in the commited profile.xml - API
    #Verify the feature branch consist of custom field metadata xml file - API
    #Delete the created user story - API

    #Given
    Open Object                 User Stories
    ${US_ID}=                   Create User Story           User Story                  ${MCDX_PROJECT}           ${MCDX_DEV1_ORG}
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
    ${FILES_PATH}=              Get Latest Committed Files Path                         ${MCDX_GIT_REPO}          ${FEATURE_BRANCH_NAME}
    ${FILE_PATH_1}=             Set Variable                ${FILES_PATH}[1]?ref=${FEATURE_BRANCH_NAME}
    ${FILE_PATH_2}=             Set Variable                ${FILES_PATH}[0]?ref=${FEATURE_BRANCH_NAME}
    ${CONTENT_SHA_1}=           Get Branch File Content     ${FILE_PATH_1}              ${MCDX_GIT_REPO}
    ${CONTENT_SHA_2}=           Get Branch File Content     ${FILE_PATH_2}              ${MCDX_GIT_REPO}
    ${EXPECTED_PERMISSION}=     Set Variable                <fieldPermissions> <editable>true</editable> <field>${CONTACT_OBJECT}.${FIELD}__c</field> <readable>true</readable> </fieldPermissions>
    ${EXPECTED_FIELD}=          Set Variable                <fullName>${FIELD}__c</fullName>
    Should Contain              ${CONTENT_SHA_1}[0]         ${EXPECTED_PERMISSION}      strip_spaces=True         collapse_spaces=True
    Should Contain              ${CONTENT_SHA_2}[0]         ${EXPECTED_FIELD}           strip_spaces=True         collapse_spaces=True

    #Org Clean up
    Delete Source Org Object All Records                    ${SOBJECT_API_NAME}         ${SOBJECT_FIELD_API_NAME}    ${US_ID}