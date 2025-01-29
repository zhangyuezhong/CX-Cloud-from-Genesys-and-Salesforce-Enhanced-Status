@isTest
public class ServiceCloudPresenceSyncServiceTest {
  // Mock implementation of IServicePresenceStatusService

  private class MockDataAccessService extends ServiceCloudPresenceSyncService.DataAccessServiceBase {
    private List<ServicePresenceStatus> mockData;
    private Boolean allowed = true;
    public MockDataAccessService(List<ServicePresenceStatus> mockData) {
      this.mockData = mockData;
    }
    public MockDataAccessService(
      List<ServicePresenceStatus> mockData,
      Boolean allowed
    ) {
      this.mockData = mockData;
      this.allowed = allowed;
    }
    public override List<ServicePresenceStatus> getServicePresenceStatuses() {
      if (!allowed) {
        throw new HandledException('Mock NoAccessException');
      }
      return this.mockData;
    }
    public override List<Service_Cloud_Presence__c> getServiceCloudPresences() {
      if (!allowed) {
        throw new HandledException('Mock NoAccessException');
      }
      return super.getServiceCloudPresences();
    }
    public override List<Salesforce_To_Genesys_Presence_Mapping__c> getSalesforceToGenesysPresenceMappings() {
      if (!allowed) {
        throw new HandledException('Mock NoAccessException');
      }
      return super.getSalesforceToGenesysPresenceMappings();
    }
  }

  @isTest
  public static void testSyncServiceCloudPresences() {
    List<ServicePresenceStatus> mockData = new List<ServicePresenceStatus>{
      new ServicePresenceStatus(
        Id = '0N5dL0000001tC9SAI', // Mocked Id
        MasterLabel = 'Available',
        DeveloperName = 'Available'
      ),
      new ServicePresenceStatus(
        Id = '0N5dL0000004qpdSAA', // Mocked Id
        MasterLabel = 'Busy',
        DeveloperName = 'Busy'
      )
    };

    // Inject the mock service
    ServiceCloudPresenceSyncService.setDataAccessService(
      new MockDataAccessService(mockData)
    );
    // Call the method to test
    Test.startTest();
    List<Service_Cloud_Presence__c> result = ServiceCloudPresenceSyncService.syncServiceCloudPresences();
    Test.stopTest();
    // Verify the results is 3, because, we add a Offline to it by default.
    System.assertEquals(
      3,
      result.size(),
      'Expected 3 Service_Cloud_Presence__c record.'
    );

    boolean exists = checkExist(
      result,
      new List<String>{ 'Available', 'Busy', 'Offline' }
    );
    System.assertEquals(
      true,
      exists,
      'Expected Available, Busy, Offline Service_Cloud_Presence__c record.'
    );
  }

  @isTest
  public static void testSyncServiceCloudPresencesExpectException() {
    List<ServicePresenceStatus> mockData = new List<ServicePresenceStatus>{
      new ServicePresenceStatus(
        Id = '0N5dL0000001tC9SAI', // Mocked Id
        MasterLabel = 'Available',
        DeveloperName = 'Available'
      ),
      new ServicePresenceStatus(
        Id = '0N5dL0000004qpdSAA', // Mocked Id
        MasterLabel = 'Busy',
        DeveloperName = 'Busy'
      )
    };
    // Inject the mock service
    ServiceCloudPresenceSyncService.setDataAccessService(
      new MockDataAccessService(mockData, false)
    );
    // Call the method to test
    Boolean exceptionThrown = false;
    Test.startTest();
    try {
      List<Service_Cloud_Presence__c> result = ServiceCloudPresenceSyncService.syncServiceCloudPresences();
    } catch (Exception ex) {
      exceptionThrown = true;
    }
    Test.stopTest();
    System.assertEquals(true, exceptionThrown, 'expected exception throw');
  }

  @isTest
  public static void testSyncServiceCloudPresencesWithNewPresence() {
    List<ServicePresenceStatus> mockData = new List<ServicePresenceStatus>{
      new ServicePresenceStatus(
        Id = '0N5dL0000001tC9SAI', // Mocked Id
        MasterLabel = 'Available',
        DeveloperName = 'Available'
      ),
      new ServicePresenceStatus(
        Id = '0N5dL0000004qpdSAA', // Mocked Id
        MasterLabel = 'Busy',
        DeveloperName = 'Busy'
      )
    };
    // Inject the mock service
    ServiceCloudPresenceSyncService.setDataAccessService(
      new MockDataAccessService(mockData)
    );
    // Call the method to test
    Test.startTest();
    List<Service_Cloud_Presence__c> result = ServiceCloudPresenceSyncService.syncServiceCloudPresences();

    // Verify the results
    boolean exists = checkExist(
      result,
      new List<String>{ 'Available', 'Busy', 'Offline' }
    );
    System.assertEquals(
      true,
      exists,
      'Expected Available, Busy, Offline Service_Cloud_Presence__c record.'
    );

    //now, we add new status Break and delete one status Busy.
    mockData = new List<ServicePresenceStatus>{
      new ServicePresenceStatus(
        Id = '0N5dL0000001tC9SAI', //  no change
        MasterLabel = 'Available',
        DeveloperName = 'Available'
      ),
      new ServicePresenceStatus(
        Id = '0N5dL0000008wpdSAA', // new status
        MasterLabel = 'Break',
        DeveloperName = 'Break'
      )
    };
    // Inject the mock service
    ServiceCloudPresenceSyncService.setDataAccessService(
      new MockDataAccessService(mockData)
    );
    // Call the method to test
    result = ServiceCloudPresenceSyncService.syncServiceCloudPresences();
    Test.stopTest();
    // Verify the results
    exists = checkExist(
      result,
      new List<String>{ 'Available', 'Break', 'Offline' }
    );
    System.assertEquals(
      true,
      exists,
      'Expected Available, Busy, Offline Service_Cloud_Presence__c record.'
    );
  }

  @isTest
  public static void testSyncServiceCloudPresencesWithoutMock() {
    // Call the method to test
    Test.startTest();
    List<Service_Cloud_Presence__c> result = ServiceCloudPresenceSyncService.syncServiceCloudPresences();
    Test.stopTest();
    // Verify the results is 3, because, we add a Offline to it by default.
    System.assertEquals(0, 0, 'Expected 0 Service_Cloud_Presence__c record.');
  }

  @isTest
  static void testDeleteAllServiceCloudPresences() {
    // Call the method to test
    Service_Cloud_Presence__c scp = new Service_Cloud_Presence__c();
    scp.Status_Id__c = '0N5dL0000008wpd'; // new status
    scp.DeveloperName__c = 'Break';
    insert scp;
    Test.startTest();
    Integer result = ServiceCloudPresenceSyncService.deleteAllServiceCloudPresences();
    Test.stopTest();
    // Verify the results
    System.assertEquals(1, result);
  }

  @isTest
  static void testDeleteAllServiceCloudPresencesWithNoRecord() {
    // Call the method to test
    Test.startTest();
    Integer result = ServiceCloudPresenceSyncService.deleteAllServiceCloudPresences();
    Test.stopTest();
    // Verify the results
    System.assertEquals(0, result);
  }

  @isTest
  static void testDeleteAllServiceCloudPresencesWithException() {
    // Call the method to test
    ServiceCloudPresenceSyncService.setDataAccessService(
      new MockDataAccessService(null, false)
    );
    Boolean exceptionThrown = false;
    Test.startTest();
    try {
      Integer result = ServiceCloudPresenceSyncService.deleteAllServiceCloudPresences();
    } catch (Exception ex) {
      exceptionThrown = true;
    }
    Test.stopTest();
    // Verify the results
    System.assertEquals(true, exceptionThrown, 'expected exception');
  }
  @isTest
  static void testReloadSalesforceToGenesysPresenceMapping() {
    // Call the method to test

    Service_Cloud_Presence__c scp1 = new Service_Cloud_Presence__c();
    scp1.Status_Id__c = '0N5dL0000001tC9';
    scp1.DeveloperName__c = 'Avaialble';

    Service_Cloud_Presence__c scp2 = new Service_Cloud_Presence__c();
    scp2.Status_Id__c = '0N5dL0000004qpd';
    scp2.DeveloperName__c = 'Break';

    Service_Cloud_Presence__c scp3 = new Service_Cloud_Presence__c();
    scp3.Status_Id__c = '0';
    scp3.DeveloperName__c = 'Offline';

    insert new List<Service_Cloud_Presence__c>{ scp1, scp2, scp3 };

    Test.startTest();
    List<Salesforce_To_Genesys_Presence_Mapping__c> result = ServiceCloudPresenceSyncService.reloadSalesforceToGenesysPresenceMapping();

    // Verify the results
    System.assertNotEquals(
      0,
      result.size(),
      'Expected at least one Salesforce_To_Genesys_Presence_Mapping__c record.'
    );
    //test update with new status and delete one status.
    delete scp3;
    Service_Cloud_Presence__c scp4 = new Service_Cloud_Presence__c();
    scp4.Status_Id__c = '0N5dL0000006xcr';
    scp4.DeveloperName__c = 'Busy';
    insert scp4;
    result = ServiceCloudPresenceSyncService.reloadSalesforceToGenesysPresenceMapping();
    System.assertNotEquals(
      0,
      result.size(),
      'Expected at least one Salesforce_To_Genesys_Presence_Mapping__c record.'
    );
    Test.stopTest();
  }

  @isTest
  static void testReloadSalesforceToGenesysPresenceMappingWithException() {
    // Call the method to test
    ServiceCloudPresenceSyncService.setDataAccessService(
      new MockDataAccessService(null, false)
    );
    Test.startTest();
    Boolean exceptionThrown = false;
    try {
      List<Salesforce_To_Genesys_Presence_Mapping__c> result = ServiceCloudPresenceSyncService.reloadSalesforceToGenesysPresenceMapping();
    } catch (Exception ex) {
      exceptionThrown = true;
    }
    Test.stopTest();
    System.assertEquals(true, exceptionThrown);
  }
  @isTest
  static void testDeleteAllSalesforceToGenesysPresenceMapping() {
    Service_Cloud_Presence__c scp1 = new Service_Cloud_Presence__c();
    scp1.Status_Id__c = '0N5dL0000001tC9';
    scp1.DeveloperName__c = 'Avaialble';

    Service_Cloud_Presence__c scp2 = new Service_Cloud_Presence__c();
    scp2.Status_Id__c = '0N5dL0000004qpd';
    scp2.DeveloperName__c = 'Break';

    Service_Cloud_Presence__c scp3 = new Service_Cloud_Presence__c();
    scp3.Status_Id__c = '0';
    scp3.DeveloperName__c = 'Offline';

    insert new List<Service_Cloud_Presence__c>{ scp1, scp2, scp3 };

    Salesforce_To_Genesys_Presence_Mapping__c mapping1 = new Salesforce_To_Genesys_Presence_Mapping__c();
    mapping1.Service_Cloud_Presence__c = scp1.Id;
    insert mapping1;
    Salesforce_To_Genesys_Presence_Mapping__c mapping2 = new Salesforce_To_Genesys_Presence_Mapping__c();
    mapping2.Service_Cloud_Presence__c = scp2.Id;
    insert mapping2;

    // Call the method to test
    Test.startTest();
    Integer result = ServiceCloudPresenceSyncService.deleteAllSalesforceToGenesysPresenceMapping();
    Test.stopTest();
    System.assertEquals(2, result);
  }

  @isTest
  static void testDeleteAllSalesforceToGenesysPresenceMappingWithNoRecord() {
    // Call the method to test
    Test.startTest();
    Integer result = ServiceCloudPresenceSyncService.deleteAllSalesforceToGenesysPresenceMapping();
    Test.stopTest();
    System.assertEquals(0, result);
  }

  @isTest
  static void testDeleteAllSalesforceToGenesysPresenceMappingWithException() {
    // Call the method to test
    ServiceCloudPresenceSyncService.setDataAccessService(
      new MockDataAccessService(null, false)
    );
    Boolean exceptionThrown = false;
    Test.startTest();
    try {
      Integer result = ServiceCloudPresenceSyncService.deleteAllSalesforceToGenesysPresenceMapping();
    } catch (Exception ex) {
      exceptionThrown = true;
    }
    Test.stopTest();
    System.assertEquals(true, exceptionThrown);
  }
  static Boolean checkExist(
    List<Service_Cloud_Presence__c> serviceCloudPresences,
    List<String> developerNames
  ) {
    // Create a set to store DeveloperName__c values for faster lookup
    Set<String> developerNamesSet = new Set<String>();
    // Add all DeveloperName__c values to the set
    for (Service_Cloud_Presence__c sc : serviceCloudPresences) {
      developerNamesSet.add(sc.DeveloperName__c);
    }
    // Check if all developer names are present in the set
    for (String name : developerNames) {
      if (!developerNamesSet.contains(name)) {
        return false; // If any name is not found, return false
      }
    }
    return true; // All names are found
  }
}
