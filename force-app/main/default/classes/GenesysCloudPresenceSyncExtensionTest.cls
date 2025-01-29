@isTest
public class GenesysCloudPresenceSyncExtensionTest {
  // Method to create mock data for Salesforce_To_Genesys_Presence_Mapping
  private static void createMappingData(
    String salesforceStatusId,
    String genesysPresenceId
  ) {
    Service_Cloud_Presence__c scp = new Service_Cloud_Presence__c();
    scp.Status_Id__c = salesforceStatusId;
    insert scp;
    Genesys_Cloud_Presence__c gcp = new Genesys_Cloud_Presence__c();
    gcp.Presence_Id__c = genesysPresenceId;
    insert gcp;

    Salesforce_To_Genesys_Presence_Mapping__c mapping = new Salesforce_To_Genesys_Presence_Mapping__c();
    mapping.Genesys_Cloud_Presence__c = gcp.Id;
    mapping.Service_Cloud_Presence__c = scp.Id;
    insert mapping;
  }

  // Method to create mock data for Genesys_To_Salesforce_Presence_Mapping
  private static void createGenesysToSalesforceMapping(
    String genesysPresenceId,
    String salesforceStatusId
  ) {
    Service_Cloud_Presence__c scp = new Service_Cloud_Presence__c();
    scp.Status_Id__c = salesforceStatusId;
    insert scp;
    Genesys_Cloud_Presence__c gcp = new Genesys_Cloud_Presence__c();
    gcp.Presence_Id__c = genesysPresenceId;
    insert gcp;

    Genesys_To_Salesforce_Presence_Mapping__c mapping = new Genesys_To_Salesforce_Presence_Mapping__c();
    mapping.Genesys_Cloud_Presence__c = gcp.Id;
    mapping.Service_Cloud_Presence__c = scp.Id;
    insert mapping;
  }

  // Test method for onSalesforceStatusChange
  @isTest
  static void testOnSalesforceStatusChange() {
    // Test data (replace with actual values from your org)
    String salesforceTargetStatusId = '00B4x00000Wc8sd'; // Example Salesforce Status ID
    String genesysTargetId = '1f866780-6f84-4c82-bd8f-09a790b1f212'; // Example Genesys Presence ID

    // Set up data to be returned from query
    createMappingData(salesforceTargetStatusId, genesysTargetId);

    // Test input JSON (simulate incoming status change)
    Map<String, Object> testData = new Map<String, Object>{
      'salesforceStatus' => new Map<String, Object>{
        'targetStatus' => new Map<String, Object>{
          'statusId' => salesforceTargetStatusId
        }
      },
      'genesysCloudStatus' => new Map<String, Object>{
        'targetStatus' => new Map<String, Object>{ 'id' => genesysTargetId }
      }
    };

    Test.startTest();
    GenesysCloudPresenceSyncExtension extension = new GenesysCloudPresenceSyncExtension();
    String response = extension.onSalesforceStatusChange(
      JSON.serialize(testData)
    );
    Test.stopTest();

    // Assert that response contains the Genesys presence ID as expected
    System.assert(
      response.contains(genesysTargetId),
      'The response should contain the Genesys presence ID'
    );
  }

  // Test method for onGenesysCloudStatusChange
  @isTest
  static void testOnGenesysCloudStatusChange() {
    // Test data (replace with actual values from your org)
    String genesysTargetId = '1f866780-6f84-4c82-bd8f-09a790b1f212'; // Example Genesys Presence ID
    String salesforceTargetStatusId = '00B4x00000Wc8sd'; // Example Salesforce Status ID

    // Set up data to be returned from query
    createGenesysToSalesforceMapping(genesysTargetId, salesforceTargetStatusId);

    // Test input JSON (simulate incoming status change)
    Map<String, Object> testData = new Map<String, Object>{
      'salesforceStatus' => new Map<String, Object>{
        'targetStatus' => new Map<String, Object>{
          'statusId' => salesforceTargetStatusId
        }
      },
      'genesysCloudStatus' => new Map<String, Object>{
        'targetStatus' => new Map<String, Object>{ 'id' => genesysTargetId }
      }
    };

    Test.startTest();
    GenesysCloudPresenceSyncExtension extension = new GenesysCloudPresenceSyncExtension();
    String response = extension.onGenesysCloudStatusChange(JSON.serialize(testData));
    Test.stopTest();

    // Assert that response contains the Salesforce status ID as expected
    System.assert(
      response.contains(salesforceTargetStatusId),
      'The response should contain the Salesforce status ID'
    );
  }

  // Test method for handling exception scenario in onSalesforceStatusChange
  @isTest
  static void testOnSalesforceStatusChange_ExceptionHandling() {
    // Simulate a case where no mapping is found for the Salesforce Status
    String salesforceTargetStatusId = '00B4x00000Wc8sd'; // Example Salesforce Status ID
    String genesysTargetId = 'g1p1'; // Example Genesys Presence ID
      // Test input JSON (simulate incoming status change)
      Map<String, Object> testData = new Map<String, Object>{
        'salesforceStatus' => new Map<String, Object>{
          'targetStatus' => new Map<String, Object>{
            'statusId' => salesforceTargetStatusId
          }
        },
        'genesysCloudStatus' => new Map<String, Object>{
          'targetStatus' => new Map<String, Object>{ 'id' =>  genesysTargetId}
        }
      };

    Test.startTest();
    GenesysCloudPresenceSyncExtension extension = new GenesysCloudPresenceSyncExtension();
    String response = extension.onSalesforceStatusChange(JSON.serialize(testData));
    Test.stopTest();

    // Ensure the response contains default response values or some indication of failure
    System.assert(response != null, 'The response should not be null');
  }

  // Test method for handling exception scenario in onGenesysCloudStatusChange
  @isTest
  static void testOnGenesysCloudStatusChange_ExceptionHandling() {
    // Simulate a case where no mapping is found for the Genesys Presence ID
    String salesforceTargetStatusId = '00B4x00000Wc8sd'; // Example Salesforce Status ID
    String genesysTargetId = 'g1p1'; // Example Genesys Presence ID
    Map<String, Object> testData = new Map<String, Object>{
      'salesforceStatus' => new Map<String, Object>{
        'targetStatus' => new Map<String, Object>{
          'statusId' => salesforceTargetStatusId
        }
      },
      'genesysCloudStatus' => new Map<String, Object>{
        'targetStatus' => new Map<String, Object>{ 'id' =>  genesysTargetId}
      }
    };

    Test.startTest();
    GenesysCloudPresenceSyncExtension extension = new GenesysCloudPresenceSyncExtension();
    String response = extension.onGenesysCloudStatusChange(JSON.serialize(testData));
    Test.stopTest();

    // Ensure the response contains default response values or some indication of failure
    System.assert(response != null, 'The response should not be null');
  }

  @isTest
  static void testOnSalesforceStatusChange_Offline() {
    // Simulate a case where no mapping is found for the Salesforce Status
    String salesforceTargetStatusId = '00B4x00000Wc8sd'; // Example Salesforce Status ID
    Map<String, Object> testData = new Map<String, Object>{
      'salesforceStatus' => new Map<String, Object>{
        'targetStatus' => new Map<String, Object>{ 'statusId' => null }
      },
      'genesysCloudStatus' => new Map<String, Object>{
        'targetStatus' => new Map<String, Object>{ 'id' => 'g1p1' }
      }
    };
    Test.startTest();
    GenesysCloudPresenceSyncExtension extension = new GenesysCloudPresenceSyncExtension();
    String response = extension.onSalesforceStatusChange(
      JSON.serialize(testData)
    );
    Test.stopTest();

    // Ensure the response contains default response values or some indication of failure
    System.assert(response != null, 'The response should not be null');
  }
}