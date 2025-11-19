// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_mapping_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProductMappingCollection on Isar {
  IsarCollection<ProductMapping> get productMappings => this.collection();
}

const ProductMappingSchema = CollectionSchema(
  name: r'ProductMapping',
  id: -3221759629008017815,
  properties: {
    r'defaultCategory': PropertySchema(
      id: 0,
      name: r'defaultCategory',
      type: IsarType.string,
    ),
    r'knownName': PropertySchema(
      id: 1,
      name: r'knownName',
      type: IsarType.string,
    ),
    r'rawId': PropertySchema(
      id: 2,
      name: r'rawId',
      type: IsarType.string,
    )
  },
  estimateSize: _productMappingEstimateSize,
  serialize: _productMappingSerialize,
  deserialize: _productMappingDeserialize,
  deserializeProp: _productMappingDeserializeProp,
  idName: r'id',
  indexes: {
    r'rawId': IndexSchema(
      id: 2643909693823425287,
      name: r'rawId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'rawId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _productMappingGetId,
  getLinks: _productMappingGetLinks,
  attach: _productMappingAttach,
  version: '3.1.0+1',
);

int _productMappingEstimateSize(
  ProductMapping object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.defaultCategory.length * 3;
  bytesCount += 3 + object.knownName.length * 3;
  bytesCount += 3 + object.rawId.length * 3;
  return bytesCount;
}

void _productMappingSerialize(
  ProductMapping object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.defaultCategory);
  writer.writeString(offsets[1], object.knownName);
  writer.writeString(offsets[2], object.rawId);
}

ProductMapping _productMappingDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ProductMapping(
    defaultCategory: reader.readString(offsets[0]),
    knownName: reader.readString(offsets[1]),
    rawId: reader.readString(offsets[2]),
  );
  object.id = id;
  return object;
}

P _productMappingDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _productMappingGetId(ProductMapping object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _productMappingGetLinks(ProductMapping object) {
  return [];
}

void _productMappingAttach(
    IsarCollection<dynamic> col, Id id, ProductMapping object) {
  object.id = id;
}

extension ProductMappingByIndex on IsarCollection<ProductMapping> {
  Future<ProductMapping?> getByRawId(String rawId) {
    return getByIndex(r'rawId', [rawId]);
  }

  ProductMapping? getByRawIdSync(String rawId) {
    return getByIndexSync(r'rawId', [rawId]);
  }

  Future<bool> deleteByRawId(String rawId) {
    return deleteByIndex(r'rawId', [rawId]);
  }

  bool deleteByRawIdSync(String rawId) {
    return deleteByIndexSync(r'rawId', [rawId]);
  }

  Future<List<ProductMapping?>> getAllByRawId(List<String> rawIdValues) {
    final values = rawIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'rawId', values);
  }

  List<ProductMapping?> getAllByRawIdSync(List<String> rawIdValues) {
    final values = rawIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'rawId', values);
  }

  Future<int> deleteAllByRawId(List<String> rawIdValues) {
    final values = rawIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'rawId', values);
  }

  int deleteAllByRawIdSync(List<String> rawIdValues) {
    final values = rawIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'rawId', values);
  }

  Future<Id> putByRawId(ProductMapping object) {
    return putByIndex(r'rawId', object);
  }

  Id putByRawIdSync(ProductMapping object, {bool saveLinks = true}) {
    return putByIndexSync(r'rawId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByRawId(List<ProductMapping> objects) {
    return putAllByIndex(r'rawId', objects);
  }

  List<Id> putAllByRawIdSync(List<ProductMapping> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'rawId', objects, saveLinks: saveLinks);
  }
}

extension ProductMappingQueryWhereSort
    on QueryBuilder<ProductMapping, ProductMapping, QWhere> {
  QueryBuilder<ProductMapping, ProductMapping, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProductMappingQueryWhere
    on QueryBuilder<ProductMapping, ProductMapping, QWhereClause> {
  QueryBuilder<ProductMapping, ProductMapping, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterWhereClause> rawIdEqualTo(
      String rawId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'rawId',
        value: [rawId],
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterWhereClause>
      rawIdNotEqualTo(String rawId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'rawId',
              lower: [],
              upper: [rawId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'rawId',
              lower: [rawId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'rawId',
              lower: [rawId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'rawId',
              lower: [],
              upper: [rawId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension ProductMappingQueryFilter
    on QueryBuilder<ProductMapping, ProductMapping, QFilterCondition> {
  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      defaultCategoryEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaultCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      defaultCategoryGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'defaultCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      defaultCategoryLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'defaultCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      defaultCategoryBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'defaultCategory',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      defaultCategoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'defaultCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      defaultCategoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'defaultCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      defaultCategoryContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'defaultCategory',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      defaultCategoryMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'defaultCategory',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      defaultCategoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaultCategory',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      defaultCategoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'defaultCategory',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      knownNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'knownName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      knownNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'knownName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      knownNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'knownName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      knownNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'knownName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      knownNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'knownName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      knownNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'knownName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      knownNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'knownName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      knownNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'knownName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      knownNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'knownName',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      knownNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'knownName',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      rawIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      rawIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rawId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      rawIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rawId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      rawIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rawId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      rawIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rawId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      rawIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rawId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      rawIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rawId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      rawIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rawId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      rawIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawId',
        value: '',
      ));
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterFilterCondition>
      rawIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rawId',
        value: '',
      ));
    });
  }
}

extension ProductMappingQueryObject
    on QueryBuilder<ProductMapping, ProductMapping, QFilterCondition> {}

extension ProductMappingQueryLinks
    on QueryBuilder<ProductMapping, ProductMapping, QFilterCondition> {}

extension ProductMappingQuerySortBy
    on QueryBuilder<ProductMapping, ProductMapping, QSortBy> {
  QueryBuilder<ProductMapping, ProductMapping, QAfterSortBy>
      sortByDefaultCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultCategory', Sort.asc);
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterSortBy>
      sortByDefaultCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultCategory', Sort.desc);
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterSortBy> sortByKnownName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'knownName', Sort.asc);
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterSortBy>
      sortByKnownNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'knownName', Sort.desc);
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterSortBy> sortByRawId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawId', Sort.asc);
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterSortBy> sortByRawIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawId', Sort.desc);
    });
  }
}

extension ProductMappingQuerySortThenBy
    on QueryBuilder<ProductMapping, ProductMapping, QSortThenBy> {
  QueryBuilder<ProductMapping, ProductMapping, QAfterSortBy>
      thenByDefaultCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultCategory', Sort.asc);
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterSortBy>
      thenByDefaultCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultCategory', Sort.desc);
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterSortBy> thenByKnownName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'knownName', Sort.asc);
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterSortBy>
      thenByKnownNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'knownName', Sort.desc);
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterSortBy> thenByRawId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawId', Sort.asc);
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QAfterSortBy> thenByRawIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawId', Sort.desc);
    });
  }
}

extension ProductMappingQueryWhereDistinct
    on QueryBuilder<ProductMapping, ProductMapping, QDistinct> {
  QueryBuilder<ProductMapping, ProductMapping, QDistinct>
      distinctByDefaultCategory({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'defaultCategory',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QDistinct> distinctByKnownName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'knownName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ProductMapping, ProductMapping, QDistinct> distinctByRawId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rawId', caseSensitive: caseSensitive);
    });
  }
}

extension ProductMappingQueryProperty
    on QueryBuilder<ProductMapping, ProductMapping, QQueryProperty> {
  QueryBuilder<ProductMapping, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ProductMapping, String, QQueryOperations>
      defaultCategoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaultCategory');
    });
  }

  QueryBuilder<ProductMapping, String, QQueryOperations> knownNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'knownName');
    });
  }

  QueryBuilder<ProductMapping, String, QQueryOperations> rawIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rawId');
    });
  }
}
