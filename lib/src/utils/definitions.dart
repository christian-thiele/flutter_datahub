import 'package:flutter/material.dart';

typedef TableRowBuilder<Item> = DataRow Function(
    BuildContext context, Item item);

typedef ValueBuilder<Value> = Widget Function(
    BuildContext context, Value value);

typedef ErrorBuilder = Widget Function(BuildContext context, dynamic error);
