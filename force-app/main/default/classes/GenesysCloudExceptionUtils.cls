public with sharing class GenesysCloudExceptionUtils {
  public static AuraHandledException createAuraHandledException(
    String method,
    Exception e
  ) {
    String errorMessage = getFormattedErrorMessage(method, e);
    AuraHandledException ex = new AuraHandledException(errorMessage);
    ex.setMessage(errorMessage);
    return ex;
  }
  // Utility method to return a formatted error message as a string
  public static String getFormattedErrorMessage(
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
