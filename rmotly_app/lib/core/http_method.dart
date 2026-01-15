/// HTTP methods supported for action execution
///
/// Used when configuring actions to determine which HTTP method
/// should be used when making requests to external APIs.
enum HttpMethod {
  /// HTTP GET method - typically for retrieving data
  get,

  /// HTTP POST method - typically for creating resources
  post,

  /// HTTP PUT method - typically for updating/replacing resources
  put,

  /// HTTP PATCH method - typically for partial updates
  patch,

  /// HTTP DELETE method - typically for removing resources
  delete;

  /// Returns the uppercase string representation of the HTTP method
  ///
  /// Example: HttpMethod.get.value => 'GET'
  String get value {
    switch (this) {
      case HttpMethod.get:
        return 'GET';
      case HttpMethod.post:
        return 'POST';
      case HttpMethod.put:
        return 'PUT';
      case HttpMethod.patch:
        return 'PATCH';
      case HttpMethod.delete:
        return 'DELETE';
    }
  }

  /// Returns a human-readable label for the HTTP method
  String get label {
    switch (this) {
      case HttpMethod.get:
        return 'GET';
      case HttpMethod.post:
        return 'POST';
      case HttpMethod.put:
        return 'PUT';
      case HttpMethod.patch:
        return 'PATCH';
      case HttpMethod.delete:
        return 'DELETE';
    }
  }

  /// Creates an HttpMethod from a string value
  ///
  /// The comparison is case-insensitive.
  /// Returns null if the string doesn't match any HTTP method.
  static HttpMethod? fromString(String value) {
    final normalized = value.toUpperCase();
    switch (normalized) {
      case 'GET':
        return HttpMethod.get;
      case 'POST':
        return HttpMethod.post;
      case 'PUT':
        return HttpMethod.put;
      case 'PATCH':
        return HttpMethod.patch;
      case 'DELETE':
        return HttpMethod.delete;
      default:
        return null;
    }
  }
}
