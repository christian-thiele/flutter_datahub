/// Interface for collections.
///
/// See [CollectionController] for details.
abstract class Collection<Item> {
  Future<int> getSize();
  Future<List<Item>> getItems(int offset, int limit);
}
