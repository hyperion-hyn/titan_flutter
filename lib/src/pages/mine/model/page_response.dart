class PageResponse<T> {
  int page;
  int totalPages;
  List<T> data;
  int total;
  dynamic entity;

  PageResponse(this.page, this.totalPages, this.data,{this.total, this.entity});
}
