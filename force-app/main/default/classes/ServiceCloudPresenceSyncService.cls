public with sharing class ServiceCloudPresenceSyncService {
  // Service layer for querying ServicePresenceStatus
  public interface IServicePresenceStatusService {
    List<ServicePresenceStatus> getServicePresenceStatuses();
  }

  // Default implementation of the service
  public class ServicePresenceStatusService implements IServicePresenceStatusService {
    public List<ServicePresenceStatus> getServicePresenceStatuses() {
      return [
        SELECT Id, MasterLabel, DeveloperName
        FROM ServicePresenceStatus
        WHERE IsDeleted = FALSE
      ];
    }
  }

  // Use dependency injection to allow mocking in tests
  private static IServicePresenceStatusService servicePresenceStatusService = new ServicePresenceStatusService();

  @TestVisible
  private static void setServicePresenceStatusService(
    IServicePresenceStatusService service
  ) {
    servicePresenceStatusService = service;
  }

  @AuraEnabled
  public static List<Service_Cloud_Presence__c> syncServiceCloudPresences() {
    try {
      List<Service_Cloud_Presence__c> toDeleteList = new List<Service_Cloud_Presence__c>();
      List<Service_Cloud_Presence__c> toUpdateList = new List<Service_Cloud_Presence__c>();
      List<Service_Cloud_Presence__c> toInsertList = new List<Service_Cloud_Presence__c>();

      Map<String, ServicePresenceStatus> servicePresenceStatusMap = convertToMap(
        servicePresenceStatusService.getServicePresenceStatuses()
      );

      List<Service_Cloud_Presence__c> serviceCloudPresences = getServiceCloudPresences();

      // check record need to delete.
      for (
        Service_Cloud_Presence__c serviceCloudPresence : serviceCloudPresences
      ) {
        if (
          !servicePresenceStatusMap.containsKey(
            serviceCloudPresence.Status_Id__c
          )
        ) {
          if (serviceCloudPresence.DeveloperName__c == 'Offline') {
            // keep this Offline record.
          } else {
            //no longer available remotely, delete it locally
            toDeleteList.add(serviceCloudPresence);
          }
        } else {
          //available remotely, update the local
          ServicePresenceStatus servicePresenceStatus = servicePresenceStatusMap.get(
            serviceCloudPresence.Status_Id__c
          );
          serviceCloudPresence = mapServicePresenceStatusToServiceCloudPresence(
            servicePresenceStatus,
            serviceCloudPresence
          );
          toUpdateList.add(serviceCloudPresence);
        }
        //as we preocess this remove it from this map.
        servicePresenceStatusMap.remove(serviceCloudPresence.Status_Id__c);
      }

      // Step 6: new Record to add
      // Any record left in the remotePresenceDefinitionsMap is new record
      for (
        ServicePresenceStatus servicePresenceStatus : servicePresenceStatusMap.values()
      ) {
        Service_Cloud_Presence__c serviceCloudPresence = mapServicePresenceStatusToServiceCloudPresence(
          servicePresenceStatus,
          new Service_Cloud_Presence__c()
        );
        toInsertList.add(serviceCloudPresence);
      }

      if (!toDeleteList.isEmpty()) {
        delete toDeleteList;
      }
      if (!toUpdateList.isEmpty()) {
        update toUpdateList;
      }
      if (!toInsertList.isEmpty()) {
        insert toInsertList;
      }

      //add offline status if doesn't exist.
      List<Service_Cloud_Presence__c> offline = [
        SELECT Id, Name, Status_Id__c, DeveloperName__c
        FROM Service_Cloud_Presence__c
        WHERE DeveloperName__c = 'Offline'
        LIMIT 1
      ];
      if (offline == null || offline.isEmpty()) {
        Service_Cloud_Presence__c scp = new Service_Cloud_Presence__c();
        scp.Name = 'Offline';
        scp.Status_Id__c = '0';
        scp.DeveloperName__c = 'Offline';
        insert scp;
      }
      ///
      return getServiceCloudPresences();
    } catch (Exception e) {
      throw GenesysCloudExceptionUtils.createAuraHandledException(
        'syncServiceCloudPresences',
        e
      );
    }
  }

  // Expose the method to LWC with @AuraEnabled annotation
  @AuraEnabled
  public static Integer deleteAllServiceCloudPresences() {
    try {
      // Query all Service_Cloud_Presence__c records
      List<Service_Cloud_Presence__c> presenceStatuses = getServiceCloudPresences();
      Integer count = presenceStatuses.size();
      // Check if there are any records to delete
      if (!presenceStatuses.isEmpty()) {
        // Delete the records in bulk
        delete presenceStatuses;
      }
      return count;
    } catch (Exception e) {
      throw GenesysCloudExceptionUtils.createAuraHandledException(
        'deleteAllServiceCloudPresences',
        e
      );
    }
  }

  @AuraEnabled
  public static List<Salesforce_To_Genesys_Presence_Mapping__c> reloadSalesforceToGenesysPresenceMapping() {
    try {
      List<Service_Cloud_Presence__c> serviceCloudPresences = getServiceCloudPresences();
      Map<String, Service_Cloud_Presence__c> serviceCloudPresencesMap = new Map<String, Service_Cloud_Presence__c>();
      for (Service_Cloud_Presence__c scp : serviceCloudPresences) {
        serviceCloudPresencesMap.put(scp.Id, scp);
      }

      List<Salesforce_To_Genesys_Presence_Mapping__c> mappings = getSalesforceToGenesysPresenceMappings();

      List<Salesforce_To_Genesys_Presence_Mapping__c> toDeleteList = new List<Salesforce_To_Genesys_Presence_Mapping__c>();
      List<Salesforce_To_Genesys_Presence_Mapping__c> toInsertList = new List<Salesforce_To_Genesys_Presence_Mapping__c>();

      for (Salesforce_To_Genesys_Presence_Mapping__c mapping : mappings) {
        if (mapping.Service_Cloud_Presence__r == null) {
          toDeleteList.add(mapping);
        } else {
          if (
            serviceCloudPresencesMap.containsKey(
              mapping.Service_Cloud_Presence__r.Id
            )
          ) {
            //existing records
            serviceCloudPresencesMap.remove(
              mapping.Service_Cloud_Presence__r.Id
            );
          }
        }
      }
      // Any record left in the serviceCloudPresencesMap is new record
      for (Service_Cloud_Presence__c scp : serviceCloudPresencesMap.values()) {
        Salesforce_To_Genesys_Presence_Mapping__c mapping = new Salesforce_To_Genesys_Presence_Mapping__c();
        mapping.Service_Cloud_Presence__c = scp.Id;
        toInsertList.add(mapping);
      }
      if (!toDeleteList.isEmpty()) {
        delete toDeleteList;
      }

      if (!toInsertList.isEmpty()) {
        insert toInsertList;
      }
      return getSalesforceToGenesysPresenceMappings();
    } catch (Exception e) {
      throw GenesysCloudExceptionUtils.createAuraHandledException(
        'reloadSalesforceToGenesysCloudPresenceMapping',
        e
      );
    }
  }

  @AuraEnabled
  public static Integer deleteAllSalesforceToGenesysPresenceMapping() {
    try {
      List<Salesforce_To_Genesys_Presence_Mapping__c> mappings = getSalesforceToGenesysPresenceMappings();
      Integer count = mappings.size();
      // Check if there are any records to delete
      if (!mappings.isEmpty()) {
        // Delete the records in bulk
        delete mappings;
      }
      return count;
    } catch (Exception e) {
      throw GenesysCloudExceptionUtils.createAuraHandledException(
        'deleteAllSalesforceToGenesysCloudPresenceMapping',
        e
      );
    }
  }

  private static List<Service_Cloud_Presence__c> getServiceCloudPresences() {
    return [
      SELECT Id, Name, Status_Id__c, DeveloperName__c
      FROM Service_Cloud_Presence__c
    ];
  }

  private static List<Salesforce_To_Genesys_Presence_Mapping__c> getSalesforceToGenesysPresenceMappings() {
    return [
      SELECT Id, Service_Cloud_Presence__r.Id, Genesys_Cloud_Presence__r.Id
      FROM Salesforce_To_Genesys_Presence_Mapping__c
    ];
  }

  private static Map<String, ServicePresenceStatus> convertToMap(
    List<ServicePresenceStatus> presenceStatuses
  ) {
    Map<String, ServicePresenceStatus> servicePresenceStatusMap = new Map<String, ServicePresenceStatus>();
    for (ServicePresenceStatus servicePresenceStatus : presenceStatuses) {
      servicePresenceStatusMap.put(
        servicePresenceStatus.Id.to15(),
        servicePresenceStatus
      );
    }
    return servicePresenceStatusMap;
  }

  private static Service_Cloud_Presence__c mapServicePresenceStatusToServiceCloudPresence(
    ServicePresenceStatus servicePresenceStatus,
    Service_Cloud_Presence__c salesforcePresenceStatus
  ) {
    salesforcePresenceStatus.Name = servicePresenceStatus.MasterLabel;
    salesforcePresenceStatus.Status_Id__c = servicePresenceStatus.Id.to15();
    salesforcePresenceStatus.DeveloperName__c = servicePresenceStatus.DeveloperName;
    return salesforcePresenceStatus;
  }
}
