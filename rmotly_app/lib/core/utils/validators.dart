/// Optimized validators for form fields.
///
/// These validators are designed to be const and reusable,
/// preventing unnecessary allocations on each validation.
class Validators {
  Validators._();

  /// Email validation regex
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validates password strength
  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  /// Validates required fields
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  /// Validates minimum length
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    if (value.length < min) {
      return '${fieldName ?? 'This field'} must be at least $min characters';
    }
    return null;
  }

  /// Validates maximum length
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value != null && value.length > max) {
      return '${fieldName ?? 'This field'} must be at most $max characters';
    }
    return null;
  }

  /// Validates URL format
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }
    try {
      final uri = Uri.parse(value);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return 'Please enter a valid URL';
      }
    } catch (e) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  /// Validates numeric input
  static String? numeric(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  /// Validates integer input
  static String? integer(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    if (int.tryParse(value) == null) {
      return 'Please enter a valid integer';
    }
    return null;
  }

  /// Validates phone number format
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    // Remove common separators
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.length < 10 || !RegExp(r'^\d+$').hasMatch(cleaned)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Combines multiple validators
  ///
  /// Returns the first error message encountered, or null if all pass.
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }

  /// Creates a custom validator from a condition
  static String? Function(String?) custom(
    bool Function(String?) condition,
    String errorMessage,
  ) {
    return (value) {
      if (!condition(value)) {
        return errorMessage;
      }
      return null;
    };
  }
}

/// Debounced validator wrapper to reduce validation frequency.
///
/// Useful for expensive validations like API calls to check username availability.
class DebouncedValidator {
  DebouncedValidator({
    required this.validator,
    this.duration = const Duration(milliseconds: 500),
  });

  final String? Function(String?) validator;
  final Duration duration;

  String? _lastValue;
  String? _lastError;
  DateTime? _lastValidation;

  String? validate(String? value) {
    final now = DateTime.now();

    // If value hasn't changed, return cached result
    if (value == _lastValue && _lastError != null) {
      return _lastError;
    }

    // If we validated recently, return cached result
    if (_lastValidation != null &&
        now.difference(_lastValidation!) < duration &&
        value == _lastValue) {
      return _lastError;
    }

    // Run validation
    _lastValue = value;
    _lastError = validator(value);
    _lastValidation = now;

    return _lastError;
  }

  void reset() {
    _lastValue = null;
    _lastError = null;
    _lastValidation = null;
  }
}
