public with sharing class GenesysCloudPresenceSyncService {
  @AuraEnabled
  public static List<Genesys_Cloud_Presence__c> syncGenesysCloudPresences() {
    try {
      List<Genesys_Cloud_Presence__c> toDeleteList = new List<Genesys_Cloud_Presence__c>();
      List<Genesys_Cloud_Presence__c> toUpdateList = new List<Genesys_Cloud_Presence__c>();
      List<Genesys_Cloud_Presence__c> toInsertList = new List<Genesys_Cloud_Presence__c>();

      Map<String, PresenceDefinition> remotePresenceDefinitionsMap = getRemotePresenceDefinitions();

      // Step 3: Query the existing Genesys_Cloud_Presence__c records
      List<Genesys_Cloud_Presence__c> localPresences = getLocalPresences();

      // check record need to delete.
      for (Genesys_Cloud_Presence__c localPresence : localPresences) {
        if (
          !remotePresenceDefinitionsMap.containsKey(
            localPresence.Presence_Id__c
          )
        ) {
          toDeleteList.add(localPresence); //no longer available remotely, delete it locally
        } else {
          //available remotely, update the local
          PresenceDefinition presenceDefinition = remotePresenceDefinitionsMap.get(
            localPresence.Presence_Id__c
          );

          localPresence = mapPresenceDefinitionToPresence(
            presenceDefinition,
            localPresence
          );
          toUpdateList.add(localPresence);
        }
        //as we preocess this remove it from this map.
        remotePresenceDefinitionsMap.remove(localPresence.Presence_Id__c);
      }

      // Step 6: new Record to add
      // Any record left in the remotePresenceDefinitionsMap is new record
      for (
        PresenceDefinition presenceDefinition : remotePresenceDefinitionsMap.values()
      ) {
        Genesys_Cloud_Presence__c newPresence = mapPresenceDefinitionToPresence(
          presenceDefinition,
          new Genesys_Cloud_Presence__c()
        );
        toInsertList.add(newPresence);
      }

      // Step 6: Update existing records and insert new ones
      if (!toDeleteList.isEmpty()) {
        delete toDeleteList;
      }
      if (!toUpdateList.isEmpty()) {
        update toUpdateList;
      }
      if (!toInsertList.isEmpty()) {
        insert toInsertList;
      }
      return getLocalPresences();
    } catch (Exception e) {
      throw createAuraHandledException('syncGenesysCloudPresences', e);
    }
  }

  // Expose the method to LWC with @AuraEnabled annotation
  @AuraEnabled
  public static String deleteAllGenesysCloudPresences() {
    try {
      // Query all Genesys_Cloud_Presence__c records
      List<Genesys_Cloud_Presence__c> presences = [
        SELECT Id
        FROM Genesys_Cloud_Presence__c
      ];

      // Check if there are any records to delete
      if (!presences.isEmpty()) {
        // Delete the records in bulk
        delete presences;
        return 'Successfully deleted ' + presences.size() + ' Presence.';
      } else {
        return 'No Presence found to delete.';
      }
    } catch (Exception e) {
      throw createAuraHandledException('deleteAllGenesysCloudPresences', e);
    }
  }

  @AuraEnabled
  public static List<Genesys_To_Salesforce_Presence_Mapping__c> reloadGenesysToSalesforcePresenceMapping() {
    try {
      List<Genesys_Cloud_Presence__c> genesysCloudPresences = getLocalPresences();

      Map<String, Genesys_Cloud_Presence__c> genesysCloudPresencesMap = new Map<String, Genesys_Cloud_Presence__c>();
      for (Genesys_Cloud_Presence__c gcp : genesysCloudPresences) {
        genesysCloudPresencesMap.put(gcp.Id, gcp);
      }

      List<Genesys_To_Salesforce_Presence_Mapping__c> mappings = getGenesysToSalesforcePresenceMappings();

      List<Genesys_To_Salesforce_Presence_Mapping__c> toDeleteList = new List<Genesys_To_Salesforce_Presence_Mapping__c>();
      List<Genesys_To_Salesforce_Presence_Mapping__c> toInsertList = new List<Genesys_To_Salesforce_Presence_Mapping__c>();

      for (Genesys_To_Salesforce_Presence_Mapping__c mapping : mappings) {
        if (mapping.Genesys_Cloud_Presence__r == null) {
          toDeleteList.add(mapping);
        } else {
          if (
            genesysCloudPresencesMap.containsKey(
              mapping.Genesys_Cloud_Presence__r.Id
            )
          ) {
            //existing records
            genesysCloudPresencesMap.remove(
              mapping.Genesys_Cloud_Presence__r.Id
            );
          }
        }
      }
      // Any record left in the serviceCloudPresencesMap is new record
      for (Genesys_Cloud_Presence__c gcp : genesysCloudPresencesMap.values()) {
        Genesys_To_Salesforce_Presence_Mapping__c mapping = new Genesys_To_Salesforce_Presence_Mapping__c();
        mapping.Genesys_Cloud_Presence__c = gcp.Id;
        toInsertList.add(mapping);
      }
      if (!toDeleteList.isEmpty()) {
        delete toDeleteList;
      }

      if (!toInsertList.isEmpty()) {
        insert toInsertList;
      }
      return getGenesysToSalesforcePresenceMappings();
    } catch (Exception e) {
      throw createAuraHandledException(
        'reloadGenesysToSalesforcePresenceMapping',
        e
      );
    }
  }

  @AuraEnabled
  public static String deleteAllGenesysToSalesforcePresenceMapping() {
    try {
      List<Genesys_To_Salesforce_Presence_Mapping__c> mappings = getGenesysToSalesforcePresenceMappings();
      // Check if there are any records to delete
      if (!mappings.isEmpty()) {
        // Delete the records in bulk
        delete mappings;
        return 'Successfully deleted ' +
          mappings.size() +
          ' Presence mappings.';
      } else {
        return 'No Presence mappings found to delete.';
      }
    } catch (Exception e) {
      throw createAuraHandledException(
        'deleteAllGenesysToSalesforcePresenceMapping',
        e
      );
    }
  }

  private static List<Genesys_Cloud_Presence__c> getLocalPresences() {
    return [
      SELECT
        Id,
        Name,
        Presence_Id__c,
        Type__c,
        Label__c,
        System_Presence__c,
        DivisionId__c
      FROM Genesys_Cloud_Presence__c
    ];
  }

  private static List<Genesys_To_Salesforce_Presence_Mapping__c> getGenesysToSalesforcePresenceMappings() {
    return [
      SELECT Id, Genesys_Cloud_Presence__r.Id, Service_Cloud_Presence__r.Id
      FROM Genesys_To_Salesforce_Presence_Mapping__c
    ];
  }

  private static Map<String, PresenceDefinition> getRemotePresenceDefinitions() {
    Map<String, Object> responseMap = GenesysCloudService.get(
      '/api/v2/presence/definitions?deactivated=FALSE',
      new Map<String, String>()
    );
    // Extract the entities array from the response
    List<Object> entities = (List<Object>) responseMap.get('entities');

    Map<String, PresenceDefinition> presenceDefinitionMap = new Map<String, PresenceDefinition>();

    // Process each entity and extract relevant data
    for (Object item : entities) {
      Map<String, Object> entity = (Map<String, Object>) item;
      PresenceDefinition presenceDefinition = new PresenceDefinition();
      presenceDefinition.id = (String) entity.get('id');
      presenceDefinition.type = (String) entity.get('type');
      presenceDefinition.languageLabels = (Map<String, Object>) entity.get(
        'languageLabels'
      );
      presenceDefinition.systemPresence = (String) entity.get('systemPresence');
      presenceDefinition.divisionId = (String) entity.get('divisionId');
      presenceDefinition.deactivated = (Boolean) entity.get('deactivated');
      presenceDefinition.selfUri = (String) entity.get('selfUri');

      // Add the processed entity to the list
      presenceDefinitionMap.put(presenceDefinition.id, presenceDefinition);
    }
    return presenceDefinitionMap;
  }

  private static Genesys_Cloud_Presence__c mapPresenceDefinitionToPresence(
    PresenceDefinition presenceDefinition,
    Genesys_Cloud_Presence__c presence
  ) {
    presence.Presence_Id__c = presenceDefinition.id;
    presence.Type__c = presenceDefinition.type;
    presence.Label__c = (String) presenceDefinition.languageLabels.get('en_US');
    presence.System_Presence__c = presenceDefinition.systemPresence;
    presence.DivisionId__c = presenceDefinition.divisionId;
    presence.Deactivated__c = presenceDefinition.deactivated;
    presence.Name =
      presenceDefinition.systemPresence +
      ' -> ' +
      (String) presenceDefinition.languageLabels.get('en_US');
    return presence;
  }

  // Class to hold the presence definition data
  public class PresenceDefinition {
    public String id;
    public String type;
    public Map<String, Object> languageLabels;
    public String systemPresence;
    public String divisionId;
    public Boolean deactivated;
    public String selfUri;
  }

  private static AuraHandledException createAuraHandledException(
    String method,
    Exception e
  ) {
    String errorMessage = getFormattedErrorMessage(method, e);
    AuraHandledException ex = new AuraHandledException(errorMessage);
    ex.setMessage(errorMessage);
    return ex;
  }
  // Utility method to return a formatted error message as a string
  private static String getFormattedErrorMessage(
    String methodName,
    Exception e
  ) {
    // Format the detailed error message
    String errorMessage = String.format(
      'An error occurred in method {0}.\n' +
        'Error Message: {1}\n' +
        'Stack Trace: {2}\n' +
        'Timestamp: {3}\n',
      new List<Object>{
        methodName, // Method name
        e.getMessage(), // Exception message
        e.getStackTraceString(), // Full stack trace
        DateTime.now().format() // Current timestamp
      }
    );
    // Return the formatted error message as a string
    return errorMessage;
  }
}