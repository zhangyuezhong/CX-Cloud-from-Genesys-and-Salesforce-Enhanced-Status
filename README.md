
## CX-Cloud-from-Genesys-and-Salesforce-Enhanced-Status
CX Cloud from Genesys and Salesforce with built-in basic sync Genesys presence with Omi-channel presence status, it also allows customer to develop a custom apex class to provide comprehensive status mapping between Genesys Cloud and Salesforce Omni-Channel.

This project follows the blueprint provided by Genesys. [Update the presence of a Genesys Cloud user based on Salesforce presence change and vice versa in CX Cloud from Genesys and Salesforce integration](https://developer.genesys.cloud/blueprints/enhanced-status-syncing-with-salesforce-service-cloud-voice/)
## What is included?

1. an Apex class **GenesysCloudPresenceSyncExtension** for enhanced presence sync

2. a lightning app for simple configuration of the presence sync mapping.

## Deployment

In VSCode, right-click on the manifest (package.xml) and select **SFDX: Deploy Source in Manifest to Org** to deploy the source to your Salesforce organization.

## How to use it?
 1. Create OAuth Client in Genesys cloud to allow query /api/v2/presence/definitions? Deactivated=FALSE HTTP/1.1
 2. Create NamedCredential in Salesforce.  Go to Setup, enter **NamedCredential**,  
 3. click on-   External Credentials,   create New
Label:  Genesys Cloud OAuth Credential 		
Authentication Protocol: OAuth 2.0 		
Authentication Flow Type: Client Credentials with Client Secret Flow 		
Identity Provider URL: https://login.mypurecloud.com.au/oauth/token 		
Pass client credentials in request body : true (checked) 		
Create new # Principals (sequence 1, Parameter name: OAuth, client id and client secret).

 4. Create Named Credentials -> New 
Label: Genesys Cloud API 	 
Name: **Genesys_Cloud_API** 	 
URL: https://api.mypurecloud.com.au 	 
Enabled for Callouts: true (checked)
External Credential:  select the **Genesys Cloud OAuth Credential**
Generate Authorization Header: checked

 5. Click on App launcher, search for GC For Presence Mapping
 6. Click on the 'Sync' button on GC For Presence Mapping page. 
 7. Click on App launcher, search for **Genesys To Salesforce Presence Mappings** tab to map out the presence 
 8. Click on App launcher, search for **Salesforce To Genesys Presence Mappings** tab to map out the presence
  
 
 ## Salesforce Objects
The applications create four objects in Salesforce.

 - [ ] **Genesys_Cloud_Presence__c**    (store the response from Genesys Cloud
   API) 
 - [ ] **Service_Cloud_Presence__c**    (store the presence status from 
   SELECT DeveloperName,Id,MasterLabel FROM ServicePresenceStatus)
 - [ ] **Genesys_To_Salesforce_Presence_Mapping__c** (two lookup fields,
   Genesys_Cloud_Presence__c, Service_Cloud_Presence__c)
- [ ] **Salesforce_To_Genesys_Presence_Mapping__c**(two lookup fields,
   Genesys_Cloud_Presence__c, Service_Cloud_Presence__c)
   