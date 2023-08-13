abstract class CollectionStateModel<Item> {
  final int size;
  final Iterable<Item> items;

  CollectionStateModel(this.size, this.items);
}
