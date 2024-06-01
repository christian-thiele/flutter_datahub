import 'collection_state_model.dart';

class SequentialCollectionModel<Item> extends CollectionStateModel<Item> {
  SequentialCollectionModel(super.size, super.items);

  late bool isComplete = items.length >= size;

  SequentialCollectionModel<Item> addChunk(List<Item> chunk) =>
      SequentialCollectionModel(
          size, items.followedBy(chunk).toList(growable: false));
}
