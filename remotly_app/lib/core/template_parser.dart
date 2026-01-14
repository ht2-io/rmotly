/// A utility class for parsing template strings with variable substitution.
///
/// Supports {{variable}} syntax for simple variables and dot notation
/// for nested object access (e.g., {{user.name}}, {{items.0}}, {{items.length}}).
///
/// Example:
/// ```dart
/// final parser = TemplateParser();
/// final result = parser.parse(
///   'Hello, {{name}}!',
///   {'name': 'World'},
/// );
/// // result: 'Hello, World!'
/// ```
class TemplateParser {
  /// Regular expression to match {{variable}} placeholders.
  /// Matches variable names that can contain letters, numbers, underscores, and dots.
  static final RegExp _placeholderRegex = RegExp(r'\{\{([a-zA-Z0-9_.]+)\}\}');

  /// Parses a template string by replacing placeholders with values from the variables map.
  ///
  /// [template] - The template string containing {{variable}} placeholders
  /// [variables] - A map of variable names to their values
  ///
  /// Returns the parsed string with all found variables replaced.
  /// Placeholders for missing variables are left unchanged.
  String parse(String template, Map<String, dynamic> variables) {
    if (template.isEmpty) {
      return template;
    }

    return template.replaceAllMapped(_placeholderRegex, (match) {
      final variablePath = match.group(1);
      if (variablePath == null) {
        return match.group(0)!;
      }

      final value = _resolveValue(variablePath, variables);
      
      // If value is null or not found, return the original placeholder
      if (value == null) {
        return match.group(0)!;
      }

      return value.toString();
    });
  }

  /// Resolves a variable value from the variables map using dot notation.
  ///
  /// Supports:
  /// - Simple variables: "name"
  /// - Nested objects: "user.name", "address.city.name"
  /// - Array access: "items.0", "users.1.name"
  /// - Array length: "items.length"
  dynamic _resolveValue(String path, Map<String, dynamic> variables) {
    final parts = path.split('.');
    dynamic current = variables;

    for (final part in parts) {
      if (current == null) {
        return null;
      }

      if (current is Map) {
        current = current[part];
      } else if (current is List) {
        // Handle array access by index
        final index = int.tryParse(part);
        if (index != null) {
          if (index >= 0 && index < current.length) {
            current = current[index];
          } else {
            return null; // Out of bounds
          }
        } else if (part == 'length') {
          // Handle .length property for lists
          return current.length;
        } else {
          return null; // Invalid list access
        }
      } else {
        // Try to access property using reflection-like approach
        // For basic types, we can't access properties, so return null
        return null;
      }
    }

    return current;
  }
}
