class PaginationDto {
  final int page;
  final int perPage;
  final int totalCount;
  final int totalPages;

  const PaginationDto({
    required this.page,
    required this.perPage,
    required this.totalCount,
    required this.totalPages,
  });

  factory PaginationDto.fromJson(Map<String, dynamic> json) {
    return PaginationDto(
      page: json['page'] as int? ?? 1,
      perPage: json['per_page'] as int? ?? 20,
      totalCount: json['total_count'] as int? ?? 0,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
    'page': page,
    'per_page': perPage,
    'total_count': totalCount,
    'total_pages': totalPages,
  };
}

class PaginatedResponse<T> {
  final List<T> items;
  final PaginationDto? pagination;

  const PaginatedResponse({
    required this.items,
    this.pagination,
  });

  bool get hasMore {
    if (pagination == null) return false;
    return pagination!.page < pagination!.totalPages;
  }

  int get nextPage {
    if (pagination == null) return 1;
    return pagination!.page + 1;
  }
}
