from requests.api import head
from robot.api.deco import keyword
import string
import json
import subprocess
import os

class PackagesCli():

#Method to check the sfdx cli version details
#Author : Dhanesh; 14 Feb, 2022
    @keyword
    def check_sfdx_version(self):
        subprocess.run('sfdx --version', shell=True)

#Method to authorize any org using sfdxauthurl
#Author : Dhanesh; 14 Feb, 2022    
    @keyword
    def auth_orgs(self, path):
        proc = subprocess.run('sfdx auth:sfdxurl:store -f '+path, stdout=subprocess.PIPE, shell=True)
        output = proc.stdout.decode('UTF-8')
        return output

#Method to create a new sfdx project
#Author : Dhanesh; 14 Feb, 2022 
    @keyword
    def create_sfdx_project(self, project_name):
        proc = subprocess.run('sfdx force:project:create --projectname '+project_name, stdout=subprocess.PIPE, shell=True)
        output = proc.stdout.decode('UTF-8')
        return output

#Method to create a new salesforce package in the devhub org
#Author : Dhanesh; 14 Feb, 2022 
    @keyword
    def create_package(self, package_name, org_username):
        proc = subprocess.run('sfdx force:package:create -n '+package_name+' -d automation -t Unlocked -e -r force-app -v '+org_username, stdout=subprocess.PIPE, shell=True)
        output = proc.stdout.decode('UTF-8')
        return output

#Method to navigate to the sfdx project created
#Author : Dhanesh; 17 Feb, 2022    
    @keyword
    def navigate_to_sfdx_project(self):
        proc = subprocess.run('cd ./PackageAutomation', stdout=subprocess.PIPE, shell=True)
        output = proc.stdout.decode('UTF-8')
        return output       

#Method to create a json file inside the project Directory
#Author : Dhanesh; 17 Feb, 2022    
    @keyword
    def create_auth_json(self, url, file_name, key):
        auth = {key: url}
        json_object = json.dumps(auth, indent=1)
        with open(file_name, "w") as outfile:
            outfile.write(json_object)

#Method to retrieve any single metadata from any org
#Author : Dhanesh; 17 Feb, 2022         
    @keyword
    def retrieve_single_metadata(self, metadata_type, metadata_api_name, org_username):
        proc = subprocess.run('sfdx force:source:retrieve -m '+metadata_type+':'+metadata_api_name+' -u '+org_username, stdout=subprocess.PIPE, shell=True)
        output = proc.stdout.decode('UTF-8')
        return output 

#Method to authenticate to any copado org 
#Author : Dhanesh; 18 Feb, 2022    
    @keyword     
    def authenticate_to_copado(self, org_username):
        proc = subprocess.run('sfdx copado:auth:set -u '+org_username, stdout=subprocess.PIPE, shell=True)
        output = proc.stdout.decode('UTF-8')
        return output 

#Method to import package 
#Author : Dhanesh; 18 Feb, 2022    
    @keyword  
    def import_package(self, package_id, pipeline_id, json_file_name): 
        proc = subprocess.run('sfdx copado:package:import -p '+package_id+' -l '+pipeline_id+' -f '+json_file_name, stdout=subprocess.PIPE, shell=True)   
        output = proc.stdout.decode('UTF-8')
        return output 

#Method to delete package from devhub org 
#Author : Dhanesh; 22 Feb, 2022
    @keyword  
    def delete_package(self, package_id, org_username):    
        proc = subprocess.run('sfdx force:package:delete -v '+org_username+' -p '+package_id, stdout=subprocess.PIPE, shell=True, input=b"y")
        output = proc.stdout.decode('UTF-8')
        return output   

#Method to create package version in devhub org
#Author : Dhanesh; 22 Feb, 2022
    @keyword  
    def create_package_version_sf(self, package_id, org_username, version_name, version_number):
        proc = subprocess.run('sfdx force:package:version:create -v '+org_username+' -p '+package_id+' -a '+version_name+' -n '+version_number+' -x --skipvalidation --wait 10', stdout=subprocess.PIPE, shell=True) 
        output = proc.stdout.decode('UTF-8')
        return output

#Method to delete package version from devhub org 
#Author : Dhanesh; 22 Feb, 2022
    @keyword  
    def delete_package_version(self, package_id, org_username):    
        proc = subprocess.run('sfdx force:package:version:delete -v '+org_username+' -p '+package_id, stdout=subprocess.PIPE, shell=True, input=b"y")
        output = proc.stdout.decode('UTF-8')
        return output

#Method to list package versions from devhub org 
#Author : Dhanesh; 1 Mar, 2022
    @keyword  
    def list_package_version(self, package_id, org_username):    
        proc = subprocess.run('sfdx force:package:version:list -v '+org_username+' -p '+package_id, stdout=subprocess.PIPE, shell=True)
        output = proc.stdout.decode('UTF-8')
        return output

#Method to delete all package versions in devhub org
#Author : Dhanesh; 17 Mar, 2022
    @keyword
    def delete_all_package_versions(self, org_username):
        all_versions = subprocess.run('sfdx force:package:version:list -v '+org_username+' --json', stdout=subprocess.PIPE, shell=True)
        json_output = all_versions.stdout.decode('UTF-8')
        version_info = json.loads(json_output)
        count = len(version_info['result'])
        flag = False
        for i in range(0, count):
            sub_package_ver_id = version_info['result'][i]['SubscriberPackageVersionId']
            proc = subprocess.run('sfdx force:package:version:delete -v '+org_username+' -p '+sub_package_ver_id, stdout=subprocess.PIPE, shell=True, input=b"y")
            output = proc.stdout.decode('UTF-8')
            if output.__contains__('Successfully deleted the package version'):
                flag = True
            else:
                break
        return flag

#Method to delete all packages in devhub org
#Author : Dhanesh; 17 Mar, 2022
    @keyword
    def delete_all_packages(self, org_username):
        all_packages = subprocess.run('sfdx force:package:list -v '+org_username+' --json', stdout=subprocess.PIPE, shell=True)
        json_output = all_packages.stdout.decode('UTF-8')
        package_info = json.loads(json_output)
        count = len(package_info['result'])
        flag = False
        for i in range(0, count):
            package_id = package_info['result'][i]['Id']
            proc = subprocess.run('sfdx force:package:delete -v '+org_username+' -p '+package_id, stdout=subprocess.PIPE, shell=True, input=b"y")
            output = proc.stdout.decode('UTF-8')
            if output.__contains__('Successfully deleted the package'):
                flag = True
            else:
                break
        return flag  

#Method to verify a package installed in the target org
#Author : Dhanesh; 23 Mar, 2022
    @keyword
    def verify_package_installed(self, org_username, package_name, package_version):
        installed_packages = subprocess.run('sfdx force:package:installed:list -u '+org_username+' --json', stdout=subprocess.PIPE, shell=True)
        packages = installed_packages.stdout.decode('UTF-8')
        packages_json = json.loads(packages)
        count = len(packages_json['result'])
        flag = True
        if count != 0:
            for i in range(0, count):
                pack_name = packages_json['result'][i]['SubscriberPackageName']
                if pack_name == package_name:
                    pack_ver = packages_json['result'][i]['SubscriberPackageVersionNumber']
                    if pack_ver == package_version:
                        break
                    else:
                        flag = False
                elif i == count - 1:
                    flag = False    
        else:
            flag = False
        return flag

#Method to uninstall a package from the target org
#Author : Dhanesh; 24 Mar, 2022
    @keyword
    def uninstall_package(self, org_username, prefix_text):
        installed_packages = subprocess.run('sfdx force:package:installed:list -u '+org_username+' --json', stdout=subprocess.PIPE, shell=True)
        packages = installed_packages.stdout.decode('UTF-8')
        packages_json = json.loads(packages)
        count = len(packages_json['result'])
        result_list = []
        result = 'No installed packages found'
        if count != 0:
            for i in range(0, count):
                pack_name = packages_json['result'][i]['SubscriberPackageName']
                if pack_name.startswith(prefix_text):
                    sub_package_ver_id = packages_json['result'][i]['SubscriberPackageVersionId']
                    proc = subprocess.run('sfdx force:package:uninstall -u '+org_username+' -p '+sub_package_ver_id+' -w 10', stdout=subprocess.PIPE, shell=True)
                    output = proc.stdout.decode('UTF-8')
                    result_list.append(output)
            return result_list
        else:
            return result

#Method to create a new salesforce scratch org
#Author : Sachin; 24 March, 2022 
    @keyword
    def create_scratch_org(self, scratch_org_name,config_path_name,dev_hub_name):
        proc = subprocess.run('sfdx force:org:create -s -a '+scratch_org_name+' -f '+config_path_name+' -v '+dev_hub_name+' --nonamespace -w 10', stdout=subprocess.PIPE, shell=True)
        output = proc.stdout.decode('UTF-8')
        return output

#Method to open newly created scratch org
#Author : Sachin; 24 March, 2022 
    @keyword
    def open_scratch_org(self):
        proc = subprocess.run('sfdx force:org:open', stdout=subprocess.PIPE, shell=True)
        output = proc.stdout.decode('UTF-8')
        return output

#Method to generate password for scratch org
#Author : Sachin; 24 March, 2022     
    @keyword
    def reset_org_password(self,scratch_org_name, devhub_org_name):
        proc = subprocess.run('sfdx force:user:password:generate -u '+scratch_org_name+' -v '+devhub_org_name, stdout=subprocess.PIPE, shell=True)
        output = proc.stdout.decode('UTF-8')
        return output

#Method to push/deploy the metadata from the git repo
#Author : Sachin; 24 March, 2022 
    @keyword
    def push_metadata_from_git(self, scratch_org_name):
        proc = subprocess.run('sfdx force:source:push -u '+scratch_org_name, stdout=subprocess.PIPE, shell=True)
        output = proc.stdout.decode('UTF-8')
        return output

#Method to get user details of the scratch org
#Author : Sachin; 24 March, 2022 
    @keyword
    def get_org_user_details(self, scratch_org_name, devhub_org_name):
        proc = subprocess.run('sfdx force:user:display -u '+scratch_org_name+' -v '+devhub_org_name, stdout=subprocess.PIPE, shell=True)
        output = proc.stdout.decode('UTF-8')
        return output

#Method to set default devhub
#Author : Sachin; 24 March, 2022 
    @keyword
    def set_default_devhub(self, devhub_org):    
        proc = subprocess.run('sfdx config:set defaultdevhubusername= '+devhub_org, stdout=subprocess.PIPE, shell=True)
        output = proc.stdout.decode('UTF-8')
        return output  
        