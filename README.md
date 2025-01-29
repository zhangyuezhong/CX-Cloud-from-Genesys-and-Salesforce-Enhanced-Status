## CX-Cloud-from-Genesys-and-Salesforce-Enhanced-Status

CX Cloud from Genesys and Salesforce with built-in basic sync Genesys presence with Omi-channel presence status, it also allows customer to develop a custom apex class to provide comprehensive status mapping between Genesys Cloud and Salesforce Omni-Channel.

This project follows the blueprint provided by Genesys. [Update the presence of a Genesys Cloud user based on Salesforce presence change and vice versa in CX Cloud from Genesys and Salesforce integration](https://developer.genesys.cloud/blueprints/enhanced-status-syncing-with-salesforce-service-cloud-voice/)

## What is included?

  

1. an Apex class **GenesysCloudPresenceSyncExtension** for enhanced presence sync

  

2. a lightning app for simple configuration of the presence sync mapping.

  

## Deployment

  

In VSCode, right-click on the manifest (package.xml) and select **SFDX: Deploy Source in Manifest to Org** to deploy the source to your Salesforce organization.

  



## Setup NamedCredential

 1. Create OAuth Client in Genesys cloud to allow query /api/v2/presence/definitions? Deactivated=FALSE HTTP/1.1

 2. Configure External Credentials in Salesforce. Go to Setup, enter **NamedCredential**,

 3. Click on- External Credentials, click on Genesys Cloud OAuth Credential
 4. Find  **Principals** section, click on New 
 5. Parameter Name : OAuthCredential
 6. Client ID: XXXXXXXXXXXXXXXXXXXXX
 7. Client Secret: XXXXXXXXXXXXXXXXXX
 8. Click **Save**.
 
 

## Configure Permission Set

 1. Select an existing permission set or create new permission set. 
 2. Select  **External Credential Principal Access**
 3. Click Edit,  move **Genesys_Cloud_OAuth_Credential - OAuth** from **Available External Credential Principals** to **Enabled External Credential Principals**
 4. Assign The permission set to Admin (whoever will perform the presence sycn).

## Mapping out the presence status.

5. Click on App launcher, search for GC For Presence Mapping

6. Click on the 'Sync' button on GC For Presence Mapping page.

7. Click on App launcher, search for **Genesys To Salesforce Presence Mappings** tab to map out the presence

8. Click on App launcher, search for **Salesforce To Genesys Presence Mappings** tab to map out the presence

## Salesforce Objects

The applications will create four objects in Salesforce.

- [ ] **Genesys_Cloud_Presence__c** (store the response from Genesys Cloud

API)

- [ ] **Service_Cloud_Presence__c** (store the presence status from

SELECT DeveloperName,Id,MasterLabel FROM ServicePresenceStatus)

- [ ] **Genesys_To_Salesforce_Presence_Mapping__c** (two lookup fields,

Genesys_Cloud_Presence__c, Service_Cloud_Presence__c)

- [ ] **Salesforce_To_Genesys_Presence_Mapping__c**(two lookup fields,

Genesys_Cloud_Presence__c, Service_Cloud_Presence__c)