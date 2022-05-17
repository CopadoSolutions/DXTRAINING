from robot.api.deco import keyword
import string
import os
import io
import requests
import json
import subprocess

class DeleteSFObject():

#Method to get the list of SF objects using salesforce API
#Json contains only the Id of all the objects
#Author : Dhanesh; 14 Dec, 2021.  
    @keyword
    def get_object_list(self, access_token, object_APIName, key, end_point):
        uri = '/services/data/v53.0/query/'
        req_headers = {'Content-Type':'application/json','Authorization':'Bearer '+access_token}
        query = 'SELECT Id,'+key+' from '+object_APIName+' LIMIT 200'
        endpoint_url = end_point+uri 
        payload = {
            "q": query
        }
        response = requests.get(endpoint_url, params=payload, headers=req_headers)
        return response.json()    

#Method to delete a single SF object using salesforce API
#Author : Dhanesh; 15 Dec, 2021.
    @keyword
    def delete_single_record(self, access_token, record_id, object_APIName, end_point):
        uri = '/services/data/v53.0/sobjects/'+object_APIName+'/'+record_id
        req_headers = {'Content-Type':'application/json','Authorization':'Bearer '+access_token}
        endpoint_url = end_point+uri
        response = requests.delete(endpoint_url, headers=req_headers)

#Method to delete the automation created records in an object
#Author : Dhanesh; 15 Dec, 2021.
    @keyword
    def delete_automation_records(self, response_body, key, access_token, object_APIName, end_point, prefix_text):
        req_headers = {'Content-Type':'application/json','Authorization':'Bearer '+access_token}
        size = int(response_body['totalSize'])
        for i in range(0,size):
            key_value = str(response_body['records'][i][key])
            if key_value.startswith(prefix_text):
                record_id = str(response_body['records'][i]['Id'])  
                print(record_id)
                uri = '/services/data/v53.0/sobjects/'+object_APIName+'/'+record_id
                endpoint_url = end_point+uri   
                response = requests.delete(endpoint_url, headers=req_headers)
                
#Method to delete all the created records in an object
#Author : Dhanesh; 16 Dec, 2021.
    @keyword        
    def delete_all_records(self, response_body, key, access_token, object_APIName, end_point):
        req_headers = {'Content-Type':'application/json','Authorization':'Bearer '+access_token}
        size = int(response_body['totalSize'])
        for i in range(0,size):
            record_id = str(response_body['records'][i]['Id'])
            uri = '/services/data/v53.0/sobjects/'+object_APIName+'/'+record_id
            endpoint_url = end_point+uri   
            response = requests.delete(endpoint_url, headers=req_headers)

#Method to get access token from SF org using oauth2 authentication
#Author : Ram Naidu; 14 Dec, 2021.
    @keyword
    def salesforce_connect(self,username,client_id,client_secret,secrettoken,sfoauthurl):
        paramstosend = {
            "grant_type": "password",
            "client_id": client_id,
            "client_secret": client_secret, 
            "username": username,
            "password": secrettoken
        }
        response = requests.post(sfoauthurl, params=paramstosend)
        return response.json()

#Method to fectch access token from authentication response json
#Author : Dhanesh; 14 Dec, 2021.
    @keyword
    def get_access_token(self, json_response):
        access_token = json_response['access_token']
        return access_token
         