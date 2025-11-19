// lib/models/product_mapping_model.dart

import 'package:isar/isar.dart';

part 'product_mapping_model.g.dart';

@collection
class ProductMapping {
  Id id = Isar.autoIncrement;

  // rawId musi być unikalne - to nasz klucz rozpoznawania
  @Index(unique: true, replace: true) 
  late String rawId; // np. "MLEKO 3.2 UHT"

  late String knownName; // np. "Mleko"
  late String defaultCategory; // np. "Jedzenie"
  
  ProductMapping({
    required this.rawId,
    required this.knownName,
    required this.defaultCategory,
  });
}