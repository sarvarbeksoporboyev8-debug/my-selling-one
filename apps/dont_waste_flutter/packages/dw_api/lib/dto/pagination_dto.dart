import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination_dto.freezed.dart';
part 'pagination_dto.g.dart';

@freezed
class PaginationDto with _$PaginationDto {
  const factory PaginationDto({
    required int page,
    @JsonKey(name: 'per_page') required int perPage,
    @JsonKey(name: 'total_count') required int totalCount,
    @JsonKey(name: 'total_pages') required int totalPages,
  }) = _PaginationDto;

  factory PaginationDto.fromJson(Map<String, dynamic> json) =>
      _$PaginationDtoFromJson(json);
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
