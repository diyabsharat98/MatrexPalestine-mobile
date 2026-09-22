/// Wraps a Laravel `paginate()` JSON response shape
/// (`{data: [...], meta: {current_page, last_page, total}}`).
class PaginatedResponse<T> {
  const PaginatedResponse({required this.items, required this.currentPage, required this.lastPage, required this.total});

  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int total;

  bool get hasMore => currentPage < lastPage;

  factory PaginatedResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    final meta = json['meta'] as Map<String, dynamic>?;
    return PaginatedResponse(
      items: (json['data'] as List).map((e) => fromJson(e as Map<String, dynamic>)).toList(),
      currentPage: meta?['current_page'] as int? ?? 1,
      lastPage: meta?['last_page'] as int? ?? 1,
      total: meta?['total'] as int? ?? (json['data'] as List).length,
    );
  }
}
