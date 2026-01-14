import 'package:equatable/equatable.dart';

class PagedResult<T> extends Equatable {
  final T items;
  final bool hasMore;
  final String? nextCursor;

  const PagedResult({
    required this.items,
    required this.hasMore,
    required this.nextCursor,
  });

  @override
  List<Object?> get props => [items, hasMore, nextCursor];
}
