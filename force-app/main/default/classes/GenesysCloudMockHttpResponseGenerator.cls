@isTest
global class GenesysCloudMockHttpResponseGenerator implements HttpCalloutMock {
  private List<MockHttpResponse> responseList = new List<MockHttpResponse>();

  public GenesysCloudMockHttpResponseGenerator() {
  }

  public MockHttpResponse mock() {
    MockHttpResponse response = new MockHttpResponse();
    this.responseList.add(response);
    return response;
  }
  public void clear() {
    this.responseList.clear();
  }

  // Implement this interface method
  global HTTPResponse respond(HTTPRequest req) {
    for (MockHttpResponse response : this.responseList) {
      if (req.getMethod().equalsIgnoreCase(response.getMethod()) == false) {
        continue;
      }

      String endpoint = req.getEndpoint();
      String expectedEndpoint = response.getEndpoint();
      if (response.getIgnoreQueryParams()) {
        endpoint = getBaseUrl(endpoint);
        expectedEndpoint = getBaseUrl(expectedEndpoint);
      }
      if (endpoint.equals(expectedEndpoint) == false) {
        continue;
      }
      if (matches(req, response.getRequestHeaders()) == false) {
        continue;
      }
      // Create a fake response
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', response.getContentType());
      res.setBody(response.getBody());
      res.setStatusCode(response.getStatusCode());
      for (String key : response.getResponseHeaders().keySet()) {
        res.setHeader(key, response.getResponseHeaders().get(key));
      }
      return res;
    }
    // Return a default response if no match is found (optional)
    HttpResponse defaultResponse = new HttpResponse();
    defaultResponse.setStatusCode(404); // Not Found
    defaultResponse.setBody(
      'No mock response found for the request ' +
        req.getMethod() +
        ' ' +
        req.getEndpoint()
    );
    return defaultResponse;
  }

  private Boolean matches(
    HttpRequest req,
    Map<String, String> expectedHeaders
  ) {
    // Check if the expected headers match the request headers
    if (expectedHeaders == null || expectedHeaders.isEmpty()) {
      return true; // Return true if no headers are expected
    }

    for (String key : expectedHeaders.keySet()) {
      String headerValue = req.getHeader(key);
      String expected = expectedHeaders.get(key);
      if (headerValue != expected) {
        return false;
      }
    }
    return true; // Return true if all headers match
  }

  private String getBaseUrl(String endpoint) {
    return endpoint.split('\\?')[0]; // Split at '?' and return the first part
  }

  public class MockHttpResponse {
    private String endpoint = ''; // Changed from reqEndpoint
    private String method = 'GET'; // Changed from reqMethod
    private Map<String, String> requestHeaders = new Map<String, String>(); // Changed from reqHeaders
    private Integer statusCode = 200;
    private String contentType = 'application/json';
    private String body = '';
    private Map<String, String> responseHeaders = new Map<String, String>(); // Changed from headers
    private Boolean ignoreQueryParams = true; // Changed from ignoreQuery

    // Static method to create an instance of MockHttpResponse

    // Chaining methods for setting values
    public MockHttpResponse endpoint(String endpoint) {
      this.endpoint = endpoint;
      return this;
    }

    public MockHttpResponse method(String method) {
      this.method = method;
      return this;
    }
    public MockHttpResponse get() {
      this.method = 'GET';
      return this;
    }
    public MockHttpResponse post() {
      this.method = 'POST';
      return this;
    }
    public MockHttpResponse patch() {
      this.method = 'PATCH';
      return this;
    }
    public MockHttpResponse put() {
      this.method = 'PUT';
      return this;
    }
    public MockHttpResponse del() {
      this.method = 'DELETE';
      return this;
    }
    public MockHttpResponse requestHeaders(Map<String, String> requestHeaders) {
      this.requestHeaders = requestHeaders;
      return this;
    }

    public MockHttpResponse statusCode(Integer statusCode) {
      this.statusCode = statusCode;
      return this;
    }

    public MockHttpResponse contentType(String contentType) {
      this.contentType = contentType;
      return this;
    }

    public MockHttpResponse body(String body) {
      this.body = body;
      return this;
    }

    public MockHttpResponse responseHeaders(
      Map<String, String> responseHeaders
    ) {
      this.responseHeaders = responseHeaders;
      return this;
    }

    public MockHttpResponse ignoreQueryParams(Boolean ignoreQueryParams) {
      this.ignoreQueryParams = ignoreQueryParams;
      return this;
    }

    // Getter methods for each field
    private String getEndpoint() {
      return this.endpoint;
    }

    private String getMethod() {
      return this.method;
    }

    private Map<String, String> getRequestHeaders() {
      return this.requestHeaders;
    }

    private Integer getStatusCode() {
      return this.statusCode;
    }

    private String getContentType() {
      return this.contentType;
    }

    private String getBody() {
      return this.body;
    }

    private Map<String, String> getResponseHeaders() {
      return this.responseHeaders;
    }

    private Boolean getIgnoreQueryParams() {
      return this.ignoreQueryParams;
    }
  }
}