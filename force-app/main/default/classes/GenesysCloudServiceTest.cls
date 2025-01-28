@isTest
public class GenesysCloudServiceTest {
  private static String host = 'callout:Genesys_Cloud_API';
  @isTest
  static void testGetMethod() {
    // Set mock response

    String path = '/api/v2/presence/definitions?deactivated=FALSE';
    String endpoint = host + path;
    GenesysCloudMockHttpResponseGenerator generator = new GenesysCloudMockHttpResponseGenerator();
    generator.mock()
      .get()
      .endpoint(endpoint)
      .body(JSON.serialize(new Map<String, String>()));

    Test.setMock(HttpCalloutMock.class, generator);
    Test.startTest();
    Map<String, String> headers = new Map<String, String>{
      'Authorization' => 'Bearer token'
    };
    Map<String, Object> response = GenesysCloudService.get(path, headers);
    Test.stopTest();
    // Verify that the response contains expected data
    System.assertNotEquals(null, response);
  }

  @isTest
  static void testPostMethod() {
    String path = '/api/v2/presence/definitions?deactivated=FALSE';
    String endpoint = host + path;
    String body = '{"key": "value"}';
    GenesysCloudMockHttpResponseGenerator generator = new GenesysCloudMockHttpResponseGenerator();
    generator.mock().post().endpoint(endpoint).body(body);

    // Set mock response
    Test.setMock(HttpCalloutMock.class, generator);
    // Call the actual GenesysCloudService post method
    Test.startTest();
    Map<String, String> headers = new Map<String, String>{
      'Authorization' => 'Bearer token'
    };
    Map<String, Object> response = GenesysCloudService.post(
      path,
      body,
      headers
    );
    Test.stopTest();
    // Verify that the response contains expected data
    System.assertNotEquals(null, response);
  }

  @isTest
  static void testPatchMethod() {
    String path = '/api/v2/presence/definitions?deactivated=FALSE';
    String endpoint = host + path;
    String body = '{"key": "value"}';
    GenesysCloudMockHttpResponseGenerator generator = new GenesysCloudMockHttpResponseGenerator();
    generator.mock().patch().endpoint(endpoint).body(body);

    // Set mock response
    Test.setMock(HttpCalloutMock.class, generator);
    Map<String, String> headers = new Map<String, String>{
      'Authorization' => 'Bearer token'
    };
    Test.startTest();
    Map<String, Object> response = GenesysCloudService.patch(
      path,
      body,
      headers
    );
    Test.stopTest();
    // Verify that the response contains expected data
    System.assertNotEquals(null, response);
  }

  @isTest
  static void testPutMethod() {
    String path = '/api/v2/presence/definitions?deactivated=FALSE';
    String endpoint = host + path;
    String body = '{"key": "value"}';
    GenesysCloudMockHttpResponseGenerator generator = new GenesysCloudMockHttpResponseGenerator();
    generator.mock().put().endpoint(endpoint).body(body);

    // Set mock response
    Test.setMock(HttpCalloutMock.class, generator);
    Map<String, String> headers = new Map<String, String>{
      'Authorization' => 'Bearer token'
    };
    Test.startTest();
    Map<String, Object> response = GenesysCloudService.put(path, body, headers);
    Test.stopTest();
    // Verify that the response contains expected data
    System.assertNotEquals(null, response);
  }

  @isTest
  static void testDelMethod() {
    String path = '/api/v2/presence/definitions?deactivated=FALSE';
    String endpoint = host + path;
    String body = '{"key": "value"}';
    GenesysCloudMockHttpResponseGenerator generator = new GenesysCloudMockHttpResponseGenerator();
    generator.mock().del().endpoint(endpoint);
    // Set mock response
    Test.setMock(HttpCalloutMock.class, generator);
    // Call the actual GenesysCloudService post method
    Test.startTest();
    Map<String, String> headers = new Map<String, String>{
      'Authorization' => 'Bearer token'
    };
    GenesysCloudService.del(path, headers);
    Test.stopTest();
  }
  @isTest
  static void testDelMethodWith401() {
    String path = '/api/v2/presence/definitions?deactivated=FALSE';
    String endpoint = host + path;
    String body = '{"key": "value"}';
    GenesysCloudMockHttpResponseGenerator generator = new GenesysCloudMockHttpResponseGenerator();
    generator.mock().del().endpoint(endpoint).statusCode(401);
    Boolean exceptionThrown = false;

    Test.setMock(HttpCalloutMock.class, generator);
    // Call the actual GenesysCloudService post method
    Test.startTest();
    Map<String, String> headers = new Map<String, String>{
      'Authorization' => 'Bearer token'
    };
    try {
      // Call the actual GenesysCloudService del method
      GenesysCloudService.del(path, headers);
    } catch (GenesysCloudService.HTTPException e) {
      // If the expected exception is thrown, mark it as thrown
      exceptionThrown = true;
    }
    System.assert(exceptionThrown, 'Expected HTTPException to be thrown');
    Test.stopTest();
  }
}