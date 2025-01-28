// ATTENTION: You will need to find the Genesys presence ids that exist in your org.

// ATTENTION: You will need to find the Salesforce status ids that exist in your org.
// Run this query in your Salesforce org to get the status ids specific to your org. You can use 15 or 18 digit ids.
// SELECT DeveloperName,Id,IsDeleted,MasterLabel FROM ServicePresenceStatus

global with sharing class GenesysCloudPresenceSyncExtension implements genesyscloud.GenesysSCVExtension.Status {
  public String onSalesforceStatusChange(String data) {
    System.debug('onSalesforceStatusChange');
    System.debug(data); // Logs only the message
    IncomingStatusChange statusUpdate = (IncomingStatusChange) JSON.deserialize(
      data,
      IncomingStatusChange.class
    );
    // -----------------------------------------------------------------------------------------------------------------------------------
    // Examples of how to get current Salesforce Status Variables:
    // String salesforceCurrentStatusApiName = statusUpdate.salesforceStatus.currentStatus.statusApiName;
    // String salesforceCurrentStatusId = statusUpdate.salesforceStatus.currentStatus.statusId;
    // String salesforceCurrentStatusName = statusUpdate.salesforceStatus.currentStatus.statusName;

    // Examples of how to get target Salesforce Status Variables:
    // String salesforceTargetStatusApiName = statusUpdate.salesforceStatus.targetStatus.statusApiName;
    String salesforceTargetStatusId = statusUpdate.salesforceStatus.targetStatus.statusId;
    String salesforceTargetStatusName = statusUpdate.salesforceStatus.targetStatus.statusName;
    // -----------------------------------------------------------------------------------------------------------------------------------
    // Examples of how to get current Genesys Status Variables:
    // String genesysCurrentId = statusUpdate.genesysCloudStatus.currentStatus.id;
    // String genesysCurrentSystemPresence = statusUpdate.genesysCloudStatus.currentStatus.systemPresence;

    // Examples of how to get target Genesys Status Variables:
    String genesysTargetId = statusUpdate.genesysCloudStatus.targetStatus.id;
    // String genesysTargetSystemPresence = statusUpdate.genesysCloudStatus.targetStatus.systemPresence;
    // -----------------------------------------------------------------------------------------------------------------------------------

    // These are the variables that will be changed to update the agent's status.
    // These are default values to be sent back if no changes are made to the target statuses.
    // NOTE: If these values are NOT handled below, NO CHANGES will be made to the target statuses.
    String salesforceResponseTargetStatusId = salesforceTargetStatusId;
    String genesysResponseTargetStatusId = genesysTargetId;

    // Start Handling .
    // Agent clicked Offline in Omni-Channel, the salesforceTargetStatusId is null,  (by defualt service voice coud doens't have Offline status, we have created on during 'Sync' and assign the status_id to '0')
    String salesforceTargetStatusId_v = salesforceTargetStatusId == null
      ? '0'
      : salesforceTargetStatusId;

    if (string.isNotEmpty(salesforceTargetStatusId_v)) {
      try {
        //salesforceTargetStatusId is 15chars ID.
        // Query to retrieve the data from Salesforce_To_Genesys_Presence_Mapping__c
        Salesforce_To_Genesys_Presence_Mapping__c mapping = [
          SELECT Genesys_Cloud_Presence__r.Presence_Id__c
          FROM Salesforce_To_Genesys_Presence_Mapping__c
          WHERE
            Service_Cloud_Presence__r.Status_Id__c = :salesforceTargetStatusId_v
          LIMIT 1
        ];
        if (mapping != null) {
          if (mapping.Genesys_Cloud_Presence__r != null) {
            if (
              String.isNotEmpty(
                mapping.Genesys_Cloud_Presence__r.Presence_Id__c
              )
            ) {
              genesysResponseTargetStatusId = mapping.Genesys_Cloud_Presence__r.Presence_Id__c;
            }
          }
        }
      } catch (Exception e) {
        System.debug('Exception caught: ' + e.getMessage()); // Logs only the message
        System.debug('Exception caught: ' + e); // Logs the full exception object
      }
    }
    // -----------------------------------------------------------------------------------------------------------------
    // Form response object... shouldn't need to be touched.
    return JSON.serialize(
      new Response(
        genesysResponseTargetStatusId,
        salesforceResponseTargetStatusId
      )
    );
  }

  public String onGenesysCloudStatusChange(String data) {
    System.debug('onGenesysCloudStatusChange');
    System.debug(data); // Logs only the message
    IncomingStatusChange statusUpdate = (IncomingStatusChange) JSON.deserialize(
      data,
      IncomingStatusChange.class
    );
    // -----------------------------------------------------------------------------------------------------------------------------------
    // Examples of how to get current Salesforce Status Variables:
    // String salesforceCurrentStatusApiName = statusUpdate.salesforceStatus.currentStatus.statusApiName;
    // String salesforceCurrentStatusId = statusUpdate.salesforceStatus.currentStatus.statusId;
    // String salesforceCurrentStatusName = statusUpdate.salesforceStatus.currentStatus.statusName;

    // Examples of how to get target Salesforce Status Variables:
    // String salesforceTargetStatusApiName = statusUpdate.salesforceStatus.targetStatus.statusApiName;
    String salesforceTargetStatusId = statusUpdate.salesforceStatus.targetStatus.statusId;
    // String salesforceTargetStatusName = statusUpdate.salesforceStatus.targetStatus.statusName;
    // -----------------------------------------------------------------------------------------------------------------------------------
    // Examples of how to get current Genesys Status Variables:
    // String genesysCurrentId = statusUpdate.genesysCloudStatus.currentStatus.id;
    // String genesysCurrentSystemPresence = statusUpdate.genesysCloudStatus.currentStatus.systemPresence;

    // Examples of how to get target Genesys Status Variables:
    String genesysTargetId = statusUpdate.genesysCloudStatus.targetStatus.id;
    String genesysTargetSystemPresence = statusUpdate.genesysCloudStatus.targetStatus.systemPresence;
    // -----------------------------------------------------------------------------------------------------------------------------------

    // These are the variables that will be changed to update the agent's status.
    // These are default values to be sent back if no changes are made to the target statuses.
    // NOTE: If these values are NOT handled below, NO CHANGES will be made to the target statuses.
    String salesforceResponseTargetStatusId = salesforceTargetStatusId;
    String genesysResponseTargetStatusId = genesysTargetId;

    //start handling logic.
    //agent clicked logout from Genesys.
    // if ('Offline'.equalsIgnoreCase(genesysTargetSystemPresence)) {
    //   salesforceResponseTargetStatusId = '0'; // Sets agent to Offline in Omni-Channel
    //   return JSON.serialize(
    //     new Response(
    //       genesysResponseTargetStatusId,
    //       salesforceResponseTargetStatusId
    //     )
    //   );
    // }
    //agent selected other presence in genesys.
    try {
      // Query to retrieve the data from Genesys_To_Salesforce_Presence_Mapping__c
      Genesys_To_Salesforce_Presence_Mapping__c mapping = [
        SELECT Service_Cloud_Presence__r.Status_Id__c
        FROM Genesys_To_Salesforce_Presence_Mapping__c
        WHERE Genesys_Cloud_Presence__r.Presence_Id__c = :genesysTargetId
        LIMIT 1
      ];

      if (mapping != null) {
        if (mapping.Service_Cloud_Presence__r != null) {
          if (
            String.isNotEmpty(mapping.Service_Cloud_Presence__r.Status_Id__c)
          ) {
            salesforceResponseTargetStatusId = mapping.Service_Cloud_Presence__r.Status_Id__c;
          }
        }
      }
    } catch (Exception e) {
      System.debug('Exception caught: ' + e.getMessage()); // Logs only the message
      System.debug('Exception caught: ' + e); // Logs the full exception object
    }
    // -----------------------------------------------------------------------------------------------------------------
    // Form response object... shouldn't need to be touched.
    return JSON.serialize(
      new Response(
        genesysResponseTargetStatusId,
        salesforceResponseTargetStatusId
      )
    );
  }

  // No need to change below --------------------------------------------------------------------------------------------------------
  //#region Response Obj
  public class Response {
    public ResponseGenesysCloudStatusObj genesysCloudStatus;
    public ResponseSalesforceStatusObj salesforceStatus;
    public Response(
      String genesysResponseTargetStatusId,
      String salesforceResponseTargetStatusId
    ) {
      this.genesysCloudStatus = new ResponseGenesysCloudStatusObj(
        genesysResponseTargetStatusId
      );
      this.salesforceStatus = new ResponseSalesforceStatusObj(
        salesforceResponseTargetStatusId
      );
    }
  }
  public class ResponseGenesysCloudStatus {
    public String id;
    public ResponseGenesysCloudStatus(String id) {
      this.id = id;
    }
  }
  public class ResponseGenesysCloudStatusObj {
    public ResponseGenesysCloudStatus targetStatus;
    public ResponseGenesysCloudStatusObj(String genesysResponseTargetStatusId) {
      this.targetStatus = new ResponseGenesysCloudStatus(
        genesysResponseTargetStatusId
      );
    }
  }
  public class ResponseSalesforceStatus {
    public String statusId;
    public ResponseSalesforceStatus(String statusId) {
      this.statusId = statusId;
    }
  }
  public class ResponseSalesforceStatusObj {
    public ResponseSalesforceStatus targetStatus;
    public ResponseSalesforceStatusObj(
      String salesforceResponseTargetStatusId
    ) {
      this.targetStatus = new ResponseSalesforceStatus(
        salesforceResponseTargetStatusId
      );
    }
  }
  //#endregion Response Obj

  //#region IncomingStatusChange Obj
  public class IncomingStatusChange {
    public IncomingSalesforceStatus salesforceStatus;
    public IncomingGenesysCloudStatus genesysCloudStatus;
  }
  public class IncomingSalesforceStatusObj {
    public String statusApiName;
    public String statusId;
    public String statusName;
  }
  public class IncomingSalesforceStatus {
    public IncomingSalesforceStatusObj targetStatus;
    public IncomingSalesforceStatusObj currentStatus;
  }
  public class IncomingGenesysCloudStatusObj {
    public String id;
    public String systemPresence;
  }
  public class IncomingGenesysCloudStatus {
    public IncomingGenesysCloudStatusObj targetStatus;
    public IncomingGenesysCloudStatusObj currentStatus;
  }
  //#endregion IncomingStatusChange Obj
  // -----------------------------------------------------------------------------------------------------------------
}