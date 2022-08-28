import 'collection_state_model.dart';

class SequentialCollectionModel<Item> extends CollectionStateModel<Item> {
  SequentialCollectionModel(int size, List<Item> items) : super(size, items);

  bool get isComplete => items.length >= size;

  SequentialCollectionModel<Item> addChunk(List<Item> chunk) =>
      SequentialCollectionModel(
          size, items.followedBy(chunk).toList(growable: false));
}
