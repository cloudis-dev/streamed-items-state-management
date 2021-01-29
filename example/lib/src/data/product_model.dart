import 'package:flutter/foundation.dart';

@immutable
class ProductModel {
  final String uniqueId;
  final double price;

  ProductModel(this.uniqueId, this.price);
}
