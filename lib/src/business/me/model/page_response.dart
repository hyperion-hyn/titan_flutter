class PageResponse<T> {
  int page;
  int totalPages;
  List<T> data;

  PageResponse(this.page, this.totalPages, this.data);
}
