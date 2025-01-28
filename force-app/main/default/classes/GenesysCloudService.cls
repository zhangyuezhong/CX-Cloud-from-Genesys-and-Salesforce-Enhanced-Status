public with sharing class GenesysCloudService {
  private static final String CALLOUT_NAME = 'callout:Genesys_Cloud_API';

  public static Map<String, Object> get(
    String path,
    Map<String, String> headers
  ) {
    // Set up HTTP request to Genesys Cloud API endpoint for presence definitions
    HttpRequest req = new HttpRequest();
    req.setEndpoint(CALLOUT_NAME + path);
    req.setMethod('GET');
    req.setHeader('Content-Type', 'application/json');
    // Check if headers map is not null and iterate to add custom headers
    if (headers != null) {
      for (String headerName : headers.keySet()) {
        req.setHeader(headerName, headers.get(headerName));
      }
    }
    Http http = new Http();
    HttpResponse res = http.send(req);
    // Handle the response
    raise_for_status(req, res);
    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(
      res.getBody()
    );
    return responseMap;
  }
  public static Map<String, Object> post(
    String path,
    String body,
    Map<String, String> headers
  ) {
    // Set up HTTP request to Genesys Cloud API endpoint for presence definitions
    HttpRequest req = new HttpRequest();
    req.setEndpoint(CALLOUT_NAME + path);
    req.setMethod('POST');
    req.setHeader('Content-Type', 'application/json');
    // Check if headers map is not null and iterate to add custom headers
    if (headers != null) {
      for (String headerName : headers.keySet()) {
        req.setHeader(headerName, headers.get(headerName));
      }
    }
    // Set the request body if provided
    if (body != null) {
      req.setBody(body);
    }
    Http http = new Http();
    HttpResponse res = http.send(req);
    raise_for_status(req, res);
    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(
      res.getBody()
    );
    return responseMap;
  }

  public static Map<String, Object> patch(
    String path,
    String body,
    Map<String, String> headers
  ) {
    // Set up HTTP request to Genesys Cloud API endpoint for presence definitions
    HttpRequest req = new HttpRequest();
    req.setEndpoint(CALLOUT_NAME + path);
    req.setMethod('PATCH');
    req.setHeader('Content-Type', 'application/json');
    // Check if headers map is not null and iterate to add custom headers
    if (headers != null) {
      for (String headerName : headers.keySet()) {
        req.setHeader(headerName, headers.get(headerName));
      }
    }
    // Set the request body if provided
    if (body != null) {
      req.setBody(body);
    }
    Http http = new Http();
    HttpResponse res = http.send(req);
    raise_for_status(req, res);
    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(
      res.getBody()
    );
    return responseMap;
  }

  public static Map<String, Object> put(
    String path,
    String body,
    Map<String, String> headers
  ) {
    // Set up HTTP request to Genesys Cloud API endpoint for presence definitions
    HttpRequest req = new HttpRequest();
    req.setEndpoint(CALLOUT_NAME + path);
    req.setMethod('PUT');
    req.setHeader('Content-Type', 'application/json');
    // Check if headers map is not null and iterate to add custom headers
    if (headers != null) {
      for (String headerName : headers.keySet()) {
        req.setHeader(headerName, headers.get(headerName));
      }
    }
    // Set the request body if provided
    if (body != null) {
      req.setBody(body);
    }
    Http http = new Http();
    HttpResponse res = http.send(req);
    raise_for_status(req, res);
    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(
      res.getBody()
    );
    return responseMap;
  }

  public static void del(String path, Map<String, String> headers) {
    // Set up HTTP request to Genesys Cloud API endpoint for presence definitions
    HttpRequest req = new HttpRequest();
    req.setEndpoint(CALLOUT_NAME + path);
    req.setMethod('DELETE');
    req.setHeader('Content-Type', 'application/json');
    // Check if headers map is not null and iterate to add custom headers
    if (headers != null) {
      for (String headerName : headers.keySet()) {
        req.setHeader(headerName, headers.get(headerName));
      }
    }
    Http http = new Http();
    HttpResponse res = http.send(req);
    raise_for_status(req, res);
  }

  public static void raise_for_status(HttpRequest req, HttpResponse res) {
    // Check if the status code is in the 2xx range (successful responses)
    Boolean ok = res.getStatusCode() >= 200 && res.getStatusCode() < 300;
    if (!ok) {
      String url = req.getEndpoint();
      // Format the error message with URL, status code, and response body
      String errorMsg = String.format(
        'HTTP Request failed at {0}.\n' +
          'Status Code: {1}\n' +
          'Response Body: {2}\n' +
          'Timestamp: {3}',
        new List<Object>{
          url,
          res.getStatusCode(),
          res.getBody(),
          DateTime.now().format() // Current timestamp in ISO 8601 format
        }
      );

      // Throw a custom HTTPException with the formatted error message
      throw new HTTPException(errorMsg);
    }
  }

  // Custom Exception Class to handle HTTP errors
  public class HTTPException extends Exception {
  }
}