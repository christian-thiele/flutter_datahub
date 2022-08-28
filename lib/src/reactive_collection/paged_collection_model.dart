import 'collection_state_model.dart';

class PagedCollectionModel<Item> extends CollectionStateModel<Item> {
  final int page;
  final int pageSize;
  int get offset => page * pageSize;

  PagedCollectionModel(int size, this.page, this.pageSize, List<Item> items)
      : super(size, items);
}
