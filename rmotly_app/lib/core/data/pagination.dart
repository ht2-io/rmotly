/// Pagination state for managing list data.
///
/// Tracks the current page, total items, and loading state
/// for paginated API endpoints.
class PaginationState<T> {
  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool isLoading;
  final bool hasMore;
  final String? error;

  const PaginationState({
    this.items = const [],
    this.currentPage = 0,
    this.totalPages = 0,
    this.totalItems = 0,
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  PaginationState<T> copyWith({
    List<T>? items,
    int? currentPage,
    int? totalPages,
    int? totalItems,
    bool? isLoading,
    bool? hasMore,
    String? error,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalItems: totalItems ?? this.totalItems,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
    );
  }

  /// Create a loading state
  PaginationState<T> toLoading() {
    return copyWith(isLoading: true, error: null);
  }

  /// Create an error state
  PaginationState<T> toError(String error) {
    return copyWith(isLoading: false, error: error);
  }

  /// Create a success state with new items
  PaginationState<T> toSuccess({
    required List<T> newItems,
    required int page,
    required int total,
    required int totalPages,
    bool append = false,
  }) {
    return PaginationState<T>(
      items: append ? [...items, ...newItems] : newItems,
      currentPage: page,
      totalItems: total,
      totalPages: totalPages,
      hasMore: page < totalPages - 1,
      isLoading: false,
      error: null,
    );
  }

  /// Reset to initial state
  PaginationState<T> reset() {
    return const PaginationState();
  }

  bool get isEmpty => items.isEmpty && !isLoading;
  bool get isNotEmpty => items.isNotEmpty;
}

/// Response wrapper for paginated API responses.
///
/// Standard format for API responses that include pagination metadata.
class PaginatedResponse<T> {
  final List<T> items;
  final int page;
  final int perPage;
  final int total;
  final int totalPages;

  const PaginatedResponse({
    required this.items,
    required this.page,
    required this.perPage,
    required this.total,
    required this.totalPages,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    return PaginatedResponse(
      items: (json['items'] as List)
          .map((item) => itemFromJson(item as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int,
      perPage: json['perPage'] as int,
      total: json['total'] as int,
      totalPages: json['totalPages'] as int,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) itemToJson) {
    return {
      'items': items.map(itemToJson).toList(),
      'page': page,
      'perPage': perPage,
      'total': total,
      'totalPages': totalPages,
    };
  }
}

/// Parameters for pagination requests
class PaginationParams {
  final int page;
  final int perPage;
  final String? sortBy;
  final String? sortOrder;
  final Map<String, dynamic>? filters;

  const PaginationParams({
    this.page = 0,
    this.perPage = 30,
    this.sortBy,
    this.sortOrder,
    this.filters,
  });

  PaginationParams copyWith({
    int? page,
    int? perPage,
    String? sortBy,
    String? sortOrder,
    Map<String, dynamic>? filters,
  }) {
    return PaginationParams(
      page: page ?? this.page,
      perPage: perPage ?? this.perPage,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      filters: filters ?? this.filters,
    );
  }

  PaginationParams nextPage() {
    return copyWith(page: page + 1);
  }

  PaginationParams previousPage() {
    return copyWith(page: page > 0 ? page - 1 : 0);
  }

  PaginationParams reset() {
    return copyWith(page: 0);
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'page': page,
      'perPage': perPage,
    };

    if (sortBy != null) params['sortBy'] = sortBy;
    if (sortOrder != null) params['sortOrder'] = sortOrder;
    if (filters != null) params.addAll(filters!);

    return params;
  }
}
