import '../../domain/models/openapi_models.dart';

/// State for the OpenAPI import feature
class OpenApiState {
  final bool isLoading;
  final String? error;
  final OpenApiSpec? spec;
  final String specUrl;
  final OpenApiOperation? selectedOperation;
  final Map<String, String> parameterValues;
  final String? generatedActionName;

  const OpenApiState({
    this.isLoading = false,
    this.error,
    this.spec,
    this.specUrl = '',
    this.selectedOperation,
    this.parameterValues = const {},
    this.generatedActionName,
  });

  OpenApiState copyWith({
    bool? isLoading,
    String? error,
    OpenApiSpec? spec,
    String? specUrl,
    OpenApiOperation? selectedOperation,
    Map<String, String>? parameterValues,
    String? generatedActionName,
    bool clearError = false,
    bool clearSpec = false,
    bool clearSelectedOperation = false,
  }) {
    return OpenApiState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      spec: clearSpec ? null : (spec ?? this.spec),
      specUrl: specUrl ?? this.specUrl,
      selectedOperation: clearSelectedOperation
          ? null
          : (selectedOperation ?? this.selectedOperation),
      parameterValues: parameterValues ?? this.parameterValues,
      generatedActionName: generatedActionName ?? this.generatedActionName,
    );
  }

  /// Check if a spec has been loaded
  bool get hasSpec => spec != null;

  /// Check if an operation has been selected
  bool get hasSelectedOperation => selectedOperation != null;

  /// Get operations count
  int get operationsCount => spec?.operations.length ?? 0;
}
