import 'collection.dart';

abstract class ParameterizedCollection<Item> implements Collection<Item> {
  Future<List<Item>> getItems(int offset, int limit,
      {Map<String, dynamic>? params, Map<String, String?>? query});

  Future<int> getSize(
      {Map<String, dynamic>? params, Map<String, String?>? query});
}
