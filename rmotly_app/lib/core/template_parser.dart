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

      final result = _resolveValue(variablePath, variables);

      // Check if variable was found (using a special marker for "not found")
      if (result is _NotFound) {
        return match.group(0)!; // Keep placeholder unchanged
      }

      return result.toString();
    });
  }

  /// Resolves a variable value from the variables map using dot notation.
  ///
  /// Supports:
  /// - Simple variables: "name"
  /// - Nested objects: "user.name", "address.city.name"
  /// - Array access: "items.0", "users.1.name"
  /// - Array length: "items.length"
  ///
  /// Returns the value if found, or [_NotFound] if not found.
  dynamic _resolveValue(String path, Map<String, dynamic> variables) {
    final parts = path.split('.');
    dynamic current = variables;

    for (var i = 0; i < parts.length; i++) {
      final part = parts[i];

      if (current == null) {
        return const _NotFound();
      }

      if (current is Map) {
        // Check if key exists in map
        if (!current.containsKey(part)) {
          return const _NotFound();
        }
        current = current[part];
      } else if (current is List) {
        // Handle array access by index
        final index = int.tryParse(part);
        if (index != null) {
          if (index >= 0 && index < current.length) {
            current = current[index];
          } else {
            return const _NotFound(); // Out of bounds
          }
        } else if (part == 'length') {
          // Handle .length property for lists
          return current.length;
        } else {
          return const _NotFound(); // Invalid list access
        }
      } else {
        // Can't navigate further into non-map, non-list types
        return const _NotFound();
      }
    }

    return current;
  }
}

/// Marker class to distinguish between "value not found" and "value is null".
class _NotFound {
  const _NotFound();
}
