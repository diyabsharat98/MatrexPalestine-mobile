import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/network/paginated_response.dart';

void main() {
  test('parses a Laravel paginate() JSON shape', () {
    final json = {
      'data': [
        {'id': 1, 'name': 'A'},
        {'id': 2, 'name': 'B'},
      ],
      'meta': {'current_page': 1, 'last_page': 3, 'total': 30},
    };

    final result = PaginatedResponse.fromJson(json, (m) => m['name'] as String);

    expect(result.items, ['A', 'B']);
    expect(result.currentPage, 1);
    expect(result.lastPage, 3);
    expect(result.total, 30);
    expect(result.hasMore, isTrue);
  });

  test('hasMore is false on the last page', () {
    final json = {
      'data': <Map<String, dynamic>>[],
      'meta': {'current_page': 3, 'last_page': 3, 'total': 30},
    };

    final result = PaginatedResponse.fromJson(json, (m) => m);

    expect(result.hasMore, isFalse);
  });

  test('falls back to sane defaults when meta is missing', () {
    final json = {
      'data': [
        {'id': 1},
      ],
    };

    final result = PaginatedResponse.fromJson(json, (m) => m);

    expect(result.currentPage, 1);
    expect(result.lastPage, 1);
    expect(result.total, 1);
    expect(result.hasMore, isFalse);
  });
}
