@isTest
public class GenesysCloudPresenceSyncServiceTest {
  @isTest
  static void testSyncGenesysCloudPresences() {
    // Mock the HTTP response
    Map<String, Object> mockResponse = new Map<String, Object>();
    mockResponse.put(
      'entities',
      new List<Object>{
        new Map<String, Object>{
          'id' => 'b43828e5-c8bc-414e-b1f1-efe219312d5f',
          'type' => 'User',
          'languageLabels' => new Map<String, Object>{ 'en_US' => 'Vacation' },
          'systemPresence' => 'Away',
          'divisionId' => '47d6a84a-5631-4e1f-8599-b46bf0be30fa',
          'deactivated' => false
        },
        new Map<String, Object>{
          'id' => '1f866780-6f84-4c82-bd8f-09a790b1f212',
          'type' => 'System',
          'languageLabels' => new Map<String, Object>{ 'en_US' => 'Busy' },
          'systemPresence' => 'Busy',
          'divisionId' => '47d6a84a-5631-4e1f-8599-b46bf0be30fa',
          'deactivated' => false
        }
      }
    );
    String host = 'callout:Genesys_Cloud_API';
    String path = '/api/v2/presence/definitions?deactivated=FALSE';
    String endpoint = host + path;

    GenesysCloudMockHttpResponseGenerator generator = new GenesysCloudMockHttpResponseGenerator();
    generator.mock()
      .get()
      .endpoint(endpoint)
      .body(JSON.serialize(mockResponse));
    Test.setMock(HttpCalloutMock.class, generator);

    // Call the sync method
    Test.startTest();
    List<Genesys_Cloud_Presence__c> result = GenesysCloudPresenceSyncService.syncGenesysCloudPresences();
    System.assertEquals(
      2,
      result.size(),
      'Expected results from syncGenesysCloudPresences'
    );
    Test.stopTest();
  }

  @isTest
  static void testSyncGenesysCloudPresencesWithInvalidData() {
    // Mock the HTTP response
    Map<String, Object> mockResponse = new Map<String, Object>();
    mockResponse.put(
      'entities',
      new List<Object>{
        //invalid type.
        new Map<String, Object>{
          'id' => 'b43828e5-c8bc-414e-b1f1-efe219312d5f',
          'type' => 'Genesys',
          'languageLabels' => new Map<String, Object>{ 'en_US' => 'Vacation' },
          'systemPresence' => 'Away',
          'divisionId' => '47d6a84a-5631-4e1f-8599-b46bf0be30fa',
          'deactivated' => false
        },
        new Map<String, Object>{
          'id' => '1f866780-6f84-4c82-bd8f-09a790b1f212',
          'type' => 'System',
          'languageLabels' => new Map<String, Object>{ 'en_US' => 'Busy' },
          'systemPresence' => 'Busy',
          'divisionId' => '47d6a84a-5631-4e1f-8599-b46bf0be30fa',
          'deactivated' => false
        }
      }
    );
    String host = 'callout:Genesys_Cloud_API';
    String path = '/api/v2/presence/definitions?deactivated=FALSE';
    String endpoint = host + path;

    GenesysCloudMockHttpResponseGenerator generator = new GenesysCloudMockHttpResponseGenerator();
    generator.mock()
      .get()
      .endpoint(endpoint)
      .body(JSON.serialize(mockResponse));
    Test.setMock(HttpCalloutMock.class, generator);

    // Call the sync method
    Test.startTest();
    Boolean exceptionThrown = false;
    try {
      List<Genesys_Cloud_Presence__c> result = GenesysCloudPresenceSyncService.syncGenesysCloudPresences();
    } catch (AuraHandledException ex) {
      exceptionThrown = true;
    }
    System.assert(
      exceptionThrown,
      'Expected AuraHandledException to be thrown'
    );
    Test.stopTest();
  }

  @isTest
  static void testSyncGenesysCloudPresencesWithUpdateAndDelete() {
    // Set up initial test data
    Genesys_Cloud_Presence__c presence1 = new Genesys_Cloud_Presence__c(
      Name = 'Away -> Away',
      Presence_Id__c = 'b43828e5-c8bc-414e-b1f1-efe219312d5f',
      Type__c = 'User',
      Label__c = 'Vacation',
      System_Presence__c = 'Away',
      DivisionId__c = '47d6a84a-5631-4e1f-8599-b46bf0be30fa'
    );
    Genesys_Cloud_Presence__c presence2 = new Genesys_Cloud_Presence__c(
      Name = 'Busy -> Busy',
      Presence_Id__c = '1f866780-6f84-4c82-bd8f-09a790b1f212',
      Type__c = 'System',
      Label__c = 'Busy',
      System_Presence__c = 'Busy',
      DivisionId__c = '47d6a84a-5631-4e1f-8599-b46bf0be30fa'
    );
    insert new List<Genesys_Cloud_Presence__c>{ presence1, presence2 };

    //test we add a new object this time, and delete an existing one.
    Map<String, Object> mockResponse = new Map<String, Object>();
    mockResponse.put(
      'entities',
      new List<Object>{
        new Map<String, Object>{
          // The existing presence is kept
          'id' => 'b43828e5-c8bc-414e-b1f1-efe219312d5f',
          'type' => 'User',
          'languageLabels' => new Map<String, Object>{ 'en_US' => 'Vacation' },
          'systemPresence' => 'Away',
          'divisionId' => '47d6a84a-5631-4e1f-8599-b46bf0be30fa',
          'deactivated' => false
        },
        // A new record is added
        new Map<String, Object>{
          'id' => 'c2183024-7c0e-4102-809e-d5e8698bfe35',
          'type' => 'System',
          'languageLabels' => new Map<String, Object>{ 'en_US' => 'Break' },
          'systemPresence' => 'Break',
          'divisionId' => '47d6a84a-5631-4e1f-8599-b46bf0be30fa',
          'deactivated' => false
        }
      }
    );
    String host = 'callout:Genesys_Cloud_API';
    String path = '/api/v2/presence/definitions?deactivated=FALSE';
    String endpoint = host + path;
    GenesysCloudMockHttpResponseGenerator generator = new GenesysCloudMockHttpResponseGenerator();
    generator.mock()
      .get()
      .endpoint(endpoint)
      .body(JSON.serialize(mockResponse));
    Test.setMock(HttpCalloutMock.class, generator);
    Test.startTest();
    List<Genesys_Cloud_Presence__c> result = GenesysCloudPresenceSyncService.syncGenesysCloudPresences();
    Test.stopTest();
    // Assert the result count
    System.assertEquals(
      2,
      result.size(),
      'Expected results from syncGenesysCloudPresences'
    );

    // Verify that the existing presence was updated
    Genesys_Cloud_Presence__c updatedPresence = [
      SELECT Id, Name
      FROM Genesys_Cloud_Presence__c
      WHERE Presence_Id__c = 'b43828e5-c8bc-414e-b1f1-efe219312d5f'
      LIMIT 1
    ];
    System.assertNotEquals(
      null,
      updatedPresence,
      'The existing Genesys Cloud Presence should be updated'
    );
    System.assertEquals(
      'Away -> Vacation',
      updatedPresence.Name,
      'The existing record should have been updated'
    );

    // Verify the new presence was inserted
    Genesys_Cloud_Presence__c newPresence = [
      SELECT Id, Name
      FROM Genesys_Cloud_Presence__c
      WHERE Presence_Id__c = 'c2183024-7c0e-4102-809e-d5e8698bfe35'
      LIMIT 1
    ];
    System.assertNotEquals(
      null,
      newPresence,
      'The new Genesys Cloud Presence should be inserted'
    );
    System.assertEquals(
      'Break -> Break',
      newPresence.Name,
      'The new record should have been inserted'
    );

    // Verify if the old presence (Presence_Id__c = '1f866780-6f84-4c82-bd8f-09a790b1f212') has been deleted
    List<Genesys_Cloud_Presence__c> deletedPresence = [
      SELECT Id
      FROM Genesys_Cloud_Presence__c
      WHERE Presence_Id__c = '1f866780-6f84-4c82-bd8f-09a790b1f212'
      LIMIT 1
    ];
    System.assertEquals(
      0,
      deletedPresence.size(),
      'The old presence should have been deleted'
    );
  }

  @isTest
  static void testDeleteAllGenesysCloudPresences() {
    // Set up initial test data
    Genesys_Cloud_Presence__c presence1 = new Genesys_Cloud_Presence__c(
      Name = 'Away -> Away',
      Presence_Id__c = 'b43828e5-c8bc-414e-b1f1-efe219312d5f',
      Type__c = 'User',
      Label__c = 'Vacation',
      System_Presence__c = 'Away',
      DivisionId__c = '47d6a84a-5631-4e1f-8599-b46bf0be30fa'
    );
    Genesys_Cloud_Presence__c presence2 = new Genesys_Cloud_Presence__c(
      Name = 'Busy -> Busy',
      Presence_Id__c = '1f866780-6f84-4c82-bd8f-09a790b1f212',
      Type__c = 'System',
      Label__c = 'Busy',
      System_Presence__c = 'Busy',
      DivisionId__c = '47d6a84a-5631-4e1f-8599-b46bf0be30fa'
    );
    insert new List<Genesys_Cloud_Presence__c>{ presence1, presence2 };

    // Call the delete method
    Test.startTest();
    String result = GenesysCloudPresenceSyncService.deleteAllGenesysCloudPresences();
    Test.stopTest();

    // Verify that the records were deleted
    System.assert(
      result.contains('Successfully deleted'),
      'Expected success message for delete'
    );
    List<Genesys_Cloud_Presence__c> presences = [
      SELECT Id
      FROM Genesys_Cloud_Presence__c
    ];
    System.assertEquals(0, presences.size(), 'Expected no records to remain');
  }

  @isTest
  static void testDeleteAllGenesysCloudPresencesWithNoPresenceExist() {
    Test.startTest();
    String result = GenesysCloudPresenceSyncService.deleteAllGenesysCloudPresences();
    Test.stopTest();
    System.assert(
      result.contains('No Presence found'),
      'Expected success message for delete ' + result
    );
  }

  @isTest
  static void testReloadGenesysToSalesforcePresenceMapping() {
    // Set up initial test data
    Genesys_Cloud_Presence__c presence1 = new Genesys_Cloud_Presence__c(
      Name = 'Away -> Away',
      Presence_Id__c = 'b43828e5-c8bc-414e-b1f1-efe219312d5f',
      Type__c = 'User',
      Label__c = 'Vacation',
      System_Presence__c = 'Away',
      DivisionId__c = '47d6a84a-5631-4e1f-8599-b46bf0be30fa'
    );
    Genesys_Cloud_Presence__c presence2 = new Genesys_Cloud_Presence__c(
      Name = 'Busy -> Busy',
      Presence_Id__c = '1f866780-6f84-4c82-bd8f-09a790b1f212',
      Type__c = 'System',
      Label__c = 'Busy',
      System_Presence__c = 'Busy',
      DivisionId__c = '47d6a84a-5631-4e1f-8599-b46bf0be30fa'
    );
    insert new List<Genesys_Cloud_Presence__c>{ presence1, presence2 };

    // Call the reload method
    Test.startTest();
    List<Genesys_To_Salesforce_Presence_Mapping__c> result = GenesysCloudPresenceSyncService.reloadGenesysToSalesforcePresenceMapping();
    Test.stopTest();

    // Verify that the mapping is reloaded correctly
    System.assertEquals(
      2,
      result.size(),
      'Expected result from reloadGenesysToSalesforcePresenceMapping'
    );
  }

  @isTest
  static void testReloadGenesysToSalesforcePresenceMappingWithUpdateAndDelete() {
    // Set up initial test data
    Genesys_Cloud_Presence__c presence1 = new Genesys_Cloud_Presence__c(
      Name = 'Away -> Away',
      Presence_Id__c = 'b43828e5-c8bc-414e-b1f1-efe219312d5f',
      Type__c = 'User',
      Label__c = 'Vacation',
      System_Presence__c = 'Away',
      DivisionId__c = '47d6a84a-5631-4e1f-8599-b46bf0be30fa'
    );
    Genesys_Cloud_Presence__c presence2 = new Genesys_Cloud_Presence__c(
      Name = 'Busy -> Busy',
      Presence_Id__c = '1f866780-6f84-4c82-bd8f-09a790b1f212',
      Type__c = 'System',
      Label__c = 'Busy',
      System_Presence__c = 'Busy',
      DivisionId__c = '47d6a84a-5631-4e1f-8599-b46bf0be30fa'
    );
    Genesys_Cloud_Presence__c presence3 = new Genesys_Cloud_Presence__c(
      Name = 'Break -> Break',
      Presence_Id__c = 'a0ad538a-17fa-40fe-a55f-8228bb637a0f',
      Type__c = 'System',
      Label__c = 'Break',
      System_Presence__c = 'Break',
      DivisionId__c = '47d6a84a-5631-4e1f-8599-b46bf0be30fa'
    );

    insert new List<Genesys_Cloud_Presence__c>{
      presence1,
      presence2,
      presence3
    };

    Genesys_To_Salesforce_Presence_Mapping__c mapping1 = new Genesys_To_Salesforce_Presence_Mapping__c();
    mapping1.Genesys_Cloud_Presence__c = presence1.Id;
    Genesys_To_Salesforce_Presence_Mapping__c mapping2 = new Genesys_To_Salesforce_Presence_Mapping__c();
    mapping2.Genesys_Cloud_Presence__c = presence2.Id;

    insert new List<Genesys_To_Salesforce_Presence_Mapping__c>{
      mapping1,
      mapping2
    };

    delete presence2;

    // Call the reload method
    Test.startTest();
    List<Genesys_To_Salesforce_Presence_Mapping__c> result = GenesysCloudPresenceSyncService.reloadGenesysToSalesforcePresenceMapping();
    Test.stopTest();

    // Verify that the mapping is reloaded correctly
    System.assertEquals(
      2,
      result.size(),
      'Expected result from reloadGenesysToSalesforcePresenceMapping'
    );
  }

  @isTest
  static void testDeleteAllGenesysToSalesforcePresenceMapping() {
    // Set up initial test data
    Genesys_Cloud_Presence__c presence1 = new Genesys_Cloud_Presence__c(
      Name = 'Away -> Away',
      Presence_Id__c = 'b43828e5-c8bc-414e-b1f1-efe219312d5f',
      Type__c = 'User',
      Label__c = 'Vacation',
      System_Presence__c = 'Away',
      DivisionId__c = '47d6a84a-5631-4e1f-8599-b46bf0be30fa'
    );
    Genesys_Cloud_Presence__c presence2 = new Genesys_Cloud_Presence__c(
      Name = 'Busy -> Busy',
      Presence_Id__c = '1f866780-6f84-4c82-bd8f-09a790b1f212',
      Type__c = 'System',
      Label__c = 'Busy',
      System_Presence__c = 'Busy',
      DivisionId__c = '47d6a84a-5631-4e1f-8599-b46bf0be30fa'
    );
    Genesys_Cloud_Presence__c presence3 = new Genesys_Cloud_Presence__c(
      Name = 'Break -> Break',
      Presence_Id__c = 'a0ad538a-17fa-40fe-a55f-8228bb637a0f',
      Type__c = 'System',
      Label__c = 'Break',
      System_Presence__c = 'Break',
      DivisionId__c = '47d6a84a-5631-4e1f-8599-b46bf0be30fa'
    );

    insert new List<Genesys_Cloud_Presence__c>{
      presence1,
      presence2,
      presence3
    };

    Genesys_To_Salesforce_Presence_Mapping__c mapping1 = new Genesys_To_Salesforce_Presence_Mapping__c();
    mapping1.Genesys_Cloud_Presence__c = presence1.Id;
    Genesys_To_Salesforce_Presence_Mapping__c mapping2 = new Genesys_To_Salesforce_Presence_Mapping__c();
    mapping2.Genesys_Cloud_Presence__c = presence2.Id;

    insert new List<Genesys_To_Salesforce_Presence_Mapping__c>{
      mapping1,
      mapping2
    };

    // Call the reload method
    Test.startTest();
    String result = GenesysCloudPresenceSyncService.deleteAllGenesysToSalesforcePresenceMapping();
    Test.stopTest();
    // Verify that the records were deleted
    System.assert(
      result.contains('Successfully deleted'),
      'Expected success message for delete'
    );
    List<Genesys_To_Salesforce_Presence_Mapping__c> mappings = [
      SELECT Id
      FROM Genesys_To_Salesforce_Presence_Mapping__c
    ];
    System.assertEquals(0, mappings.size(), 'Expected no records to remain');
  }

  @isTest
  static void testDeleteAllGenesysToSalesforcePresenceMappingWithNoMapping() {
    // Call the reload method
    Test.startTest();
    String result = GenesysCloudPresenceSyncService.deleteAllGenesysToSalesforcePresenceMapping();
    Test.stopTest();
    // Verify that the records were deleted
    System.assert(
      result.contains('No Presence mappings found'),
      'Expected success message for delete'
    );
    List<Genesys_To_Salesforce_Presence_Mapping__c> mappings = [
      SELECT Id
      FROM Genesys_To_Salesforce_Presence_Mapping__c
    ];
    System.assertEquals(0, mappings.size(), 'Expected no records to remain');
  }
}