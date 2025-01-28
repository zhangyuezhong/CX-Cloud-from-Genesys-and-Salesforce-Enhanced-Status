@isTest
public class GenesysCloudPresenceSyncExtensionTest {

    // Method to create mock data for Salesforce_To_Genesys_Presence_Mapping
    private static void createMappingData(String salesforceStatusId, String genesysPresenceId) {
        Salesforce_To_Genesys_Presence_Mapping__c mapping = new Salesforce_To_Genesys_Presence_Mapping__c(
            Service_Cloud_Presence__r = new Service_Cloud_Presence__c(
                Status_Id__c = salesforceStatusId
            ),
            Genesys_Cloud_Presence__r = new Genesys_Cloud_Presence__c(
                Presence_Id__c = genesysPresenceId
            )
        );
        insert mapping;
    }

    // Method to create mock data for Genesys_To_Salesforce_Presence_Mapping
    private static void createGenesysToSalesforceMapping(String genesysPresenceId, String salesforceStatusId) {
        Genesys_To_Salesforce_Presence_Mapping__c mapping = new Genesys_To_Salesforce_Presence_Mapping__c(
            Genesys_Cloud_Presence__r = new Genesys_Cloud_Presence__c(
                Presence_Id__c = genesysPresenceId
            ),
            Service_Cloud_Presence__r = new Service_Cloud_Presence__c(
                Status_Id__c = salesforceStatusId
            )
        );
        insert mapping;
    }

    // Test method for onSalesforceStatusChange
    @isTest
    static void testOnSalesforceStatusChange() {
        // Test data (replace with actual values from your org)
        String salesforceTargetStatusId = '00B4x00000Wc8sd'; // Example Salesforce Status ID
        String genesysTargetId = 'g1p1'; // Example Genesys Presence ID

        // Set up data to be returned from query
        createMappingData(salesforceTargetStatusId, genesysTargetId);

        // Test input JSON (simulate incoming status change)
        String testData = '{' +
            '"salesforceStatus": {' +
                '"targetStatus": {"statusId": "' + salesforceTargetStatusId + '"}' +
            '},' +
            '"genesysCloudStatus": {' +
                '"targetStatus": {"id": "' + genesysTargetId + '"}' +
            '}}';

        Test.startTest();
        GenesysCloudPresenceSyncExtension extension = new GenesysCloudPresenceSyncExtension();
        String response = extension.onSalesforceStatusChange(testData);
        Test.stopTest();

        // Assert that response contains the Genesys presence ID as expected
        System.assert(response.contains(genesysTargetId), 'The response should contain the Genesys presence ID');
    }

    // Test method for onGenesysCloudStatusChange
    @isTest
    static void testOnGenesysCloudStatusChange() {
        // Test data (replace with actual values from your org)
        String genesysTargetId = 'g1p1'; // Example Genesys Presence ID
        String salesforceTargetStatusId = '00B4x00000Wc8sd'; // Example Salesforce Status ID

        // Set up data to be returned from query
        createGenesysToSalesforceMapping(genesysTargetId, salesforceTargetStatusId);

        // Test input JSON (simulate incoming status change)
        String testData = '{' +
            '"salesforceStatus": {' +
                '"targetStatus": {"statusId": "' + salesforceTargetStatusId + '"}' +
            '},' +
            '"genesysCloudStatus": {' +
                '"targetStatus": {"id": "' + genesysTargetId + '"}' +
            '}}';

        Test.startTest();
        GenesysCloudPresenceSyncExtension extension = new GenesysCloudPresenceSyncExtension();
        String response = extension.onGenesysCloudStatusChange(testData);
        Test.stopTest();

        // Assert that response contains the Salesforce status ID as expected
        System.assert(response.contains(salesforceTargetStatusId), 'The response should contain the Salesforce status ID');
    }

    // Test method for handling exception scenario in onSalesforceStatusChange
    @isTest
    static void testOnSalesforceStatusChange_ExceptionHandling() {
        // Simulate a case where no mapping is found for the Salesforce Status
        String salesforceTargetStatusId = '00B4x00000Wc8sd'; // Example Salesforce Status ID
        String testData = '{' +
            '"salesforceStatus": {' +
                '"targetStatus": {"statusId": "' + salesforceTargetStatusId + '"}' +
            '},' +
            '"genesysCloudStatus": {' +
                '"targetStatus": {"id": "g1p1"}' +
            '}}';

        Test.startTest();
        GenesysCloudPresenceSyncExtension extension = new GenesysCloudPresenceSyncExtension();
        String response = extension.onSalesforceStatusChange(testData);
        Test.stopTest();

        // Ensure the response contains default response values or some indication of failure
        System.assert(response != null, 'The response should not be null');
    }

    // Test method for handling exception scenario in onGenesysCloudStatusChange
    @isTest
    static void testOnGenesysCloudStatusChange_ExceptionHandling() {
        // Simulate a case where no mapping is found for the Genesys Presence ID
        String genesysTargetId = 'g1p1'; // Example Genesys Presence ID
        String testData = '{' +
            '"salesforceStatus": {' +
                '"targetStatus": {"statusId": "00B4x00000Wc8sd"}' +
            '},' +
            '"genesysCloudStatus": {' +
                '"targetStatus": {"id": "' + genesysTargetId + '"}' +
            '}}';

        Test.startTest();
        GenesysCloudPresenceSyncExtension extension = new GenesysCloudPresenceSyncExtension();
        String response = extension.onGenesysCloudStatusChange(testData);
        Test.stopTest();

        // Ensure the response contains default response values or some indication of failure
        System.assert(response != null, 'The response should not be null');
    }
}