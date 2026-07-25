/// Domain-side page of results (mapped from [ApiPagedResponse] in data).
class PagedResult<T> {
  final List<T> items;
  final int currentPage;
  final int totalPages;
  final int totalCount;

  const PagedResult({
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
  });

  bool get hasNext => currentPage < totalPages;

  PagedResult<R> map<R>(R Function(T item) convert) => PagedResult<R>(
        items: items.map(convert).toList(),
        currentPage: currentPage,
        totalPages: totalPages,
        totalCount: totalCount,
      );
}
