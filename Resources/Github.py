from requests.api import head
from robot.api.deco import keyword
import string
import requests
import json
import base64

class Github():
    
    #Method to verify files from the latest commit
    #Author : Dhanesh; 21th Dec, 2021
    @keyword
    def verify_commit_files(self, access_token, repo_name, branch_name, expected_list):
        end_point = 'https://api.github.com/repos/CopadoSolutions/'+repo_name+'/commits/'+branch_name
        commit_files_headers = {'Accept':'*/*','Content-Type':'application/json','Authorization':'token '+access_token}
        commit_response = requests.get(end_point,headers=commit_files_headers)
        commit_response_json = commit_response.json()
        files_list = []
        isCommit = True
        file_count = len(commit_response_json['files'])   
        for i in range(0, file_count):
            get_content = commit_response_json['files'][i]['patch']
            files_list.append(get_content)
        expected_list_size = len(expected_list)
        for i in range(0, expected_list_size):
            if not(expected_list[i].__contains__(files_list[i])):
                isCommit = False
            else:
                isCommit = True
        return isCommit   
    
    #Method to get the commited file names including path as a list from the latest commit
    #Author : Dhanesh; 22th Dec, 2021
    @keyword
    def get_commit_files_path(self, access_token, repo_name, branch_name):  
        end_point = 'https://api.github.com/repos/CopadoSolutions/'+repo_name+'/commits/'+branch_name
        commit_files_headers = {'Accept':'*/*','Content-Type':'application/json','Authorization':'token '+access_token}
        commit_response = requests.get(end_point,headers=commit_files_headers)
        commit_response_json = commit_response.json()
        files_path = []
        file_count = len(commit_response_json['files'])   
        for i in range(0, file_count):
            get_path = commit_response_json['files'][i]['filename']
            files_path.append(get_path) 
        return files_path   

    #Method to get the file content along with SHA from a branch folder
    #Author : Dhanesh; 6th Jan, 2022
    @keyword
    def get_branch_file_content_sha(self, access_token, repo_name, file_path):
        end_point = 'https://api.github.com/repos/CopadoSolutions/'+repo_name+'/contents/'+file_path
        files_headers = {'Accept':'*/*','Content-Type':'application/json','Authorization':'token '+access_token}
        file_response = requests.get(end_point, headers=files_headers)
        json_response = file_response.json()
        total_content = json_response['content']
        decoded_content = base64.b64decode(total_content).decode('utf8')
        branch_sha = json_response['sha']
        list_res = [decoded_content, branch_sha]
        return list_res
    
    #Method to encode and update the file content from a branch folder
    #Author : Dhanesh; 6th Jan, 2022
    @keyword
    def update_file_content(self, access_token, repo_name, file_path, decoded_content, branch_sha, replace_content, new_content):
        end_point = 'https://api.github.com/repos/CopadoSolutions/'+repo_name+'/contents/'+file_path
        files_headers = {'Accept':'*/*','Content-Type':'application/json','Authorization':'token '+access_token}
        file_to_commit = str(decoded_content).replace(replace_content,"") + str(new_content)
        encode_content = str(base64.b64encode(file_to_commit.encode('utf8')))
        encode_content = encode_content[2:]
        encode_content = encode_content[:len(encode_content) - 1]
        body = '{"message": "update file", "content": "'+encode_content+'", "sha": "'+branch_sha+'"}'
        update_res = requests.put(end_point, headers=files_headers, data=body)
        status_code = update_res.status_code
        return status_code

    #Method to encode and update the sfdx-project.json file content in any branch
    #Author : Dhanesh; 25th Feb, 2022
    @keyword
    def update_sfdx_project_json(self, access_token, repo_name, file_path, branch_sha, updated_json, branch):
        end_point = 'https://api.github.com/repos/CopadoSolutions/'+repo_name+'/contents/'+file_path+'?ref='+branch
        files_headers = {'Accept':'*/*','Content-Type':'application/json','Authorization':'token '+access_token}
        encode_content = str(base64.b64encode(updated_json.encode('utf8')))
        encode_content = encode_content[2:]
        encode_content = encode_content[:len(encode_content) - 1]
        body = '{"message": "update file", "content": "'+encode_content+'", "sha": "'+branch_sha+'", "branch": "'+branch+'"}'
        update_res = requests.put(end_point, headers=files_headers, data=body)
        status_code = update_res.status_code
        return status_code