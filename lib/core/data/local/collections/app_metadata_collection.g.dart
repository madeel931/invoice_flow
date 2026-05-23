// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_metadata_collection.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAppMetadataCollectionCollection on Isar {
  IsarCollection<AppMetadataCollection> get appMetadataCollections =>
      this.collection();
}

const AppMetadataCollectionSchema = CollectionSchema(
  name: r'AppMetadataCollection',
  id: 5811889439041581069,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'isFirstLaunch': PropertySchema(
      id: 1,
      name: r'isFirstLaunch',
      type: IsarType.bool,
    ),
    r'schemaVersion': PropertySchema(
      id: 2,
      name: r'schemaVersion',
      type: IsarType.long,
    )
  },
  estimateSize: _appMetadataCollectionEstimateSize,
  serialize: _appMetadataCollectionSerialize,
  deserialize: _appMetadataCollectionDeserialize,
  deserializeProp: _appMetadataCollectionDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _appMetadataCollectionGetId,
  getLinks: _appMetadataCollectionGetLinks,
  attach: _appMetadataCollectionAttach,
  version: '3.1.0+1',
);

int _appMetadataCollectionEstimateSize(
  AppMetadataCollection object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _appMetadataCollectionSerialize(
  AppMetadataCollection object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeBool(offsets[1], object.isFirstLaunch);
  writer.writeLong(offsets[2], object.schemaVersion);
}

AppMetadataCollection _appMetadataCollectionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AppMetadataCollection(
    createdAt: reader.readDateTimeOrNull(offsets[0]),
    isFirstLaunch: reader.readBoolOrNull(offsets[1]) ?? true,
    schemaVersion: reader.readLongOrNull(offsets[2]) ?? 1,
  );
  object.id = id;
  return object;
}

P _appMetadataCollectionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 2:
      return (reader.readLongOrNull(offset) ?? 1) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _appMetadataCollectionGetId(AppMetadataCollection object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _appMetadataCollectionGetLinks(
    AppMetadataCollection object) {
  return [];
}

void _appMetadataCollectionAttach(
    IsarCollection<dynamic> col, Id id, AppMetadataCollection object) {
  object.id = id;
}

extension AppMetadataCollectionQueryWhereSort
    on QueryBuilder<AppMetadataCollection, AppMetadataCollection, QWhere> {
  QueryBuilder<AppMetadataCollection, AppMetadataCollection, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AppMetadataCollectionQueryWhere on QueryBuilder<AppMetadataCollection,
    AppMetadataCollection, QWhereClause> {
  QueryBuilder<AppMetadataCollection, AppMetadataCollection, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AppMetadataCollection, AppMetadataCollection, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<AppMetadataCollection, AppMetadataCollection, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AppMetadataCollection, AppMetadataCollection, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AppMetadataCollection, AppMetadataCollection, QAfterWhereClause>
      idBetween(
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
}

extension AppMetadataCollectionQueryFilter on QueryBuilder<
    AppMetadataCollection, AppMetadataCollection, QFilterCondition> {
  QueryBuilder<AppMetadataCollection, AppMetadataCollection,
      QAfterFilterCondition> createdAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<AppMetadataCollection, AppMetadataCollection,
      QAfterFilterCondition> createdAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'createdAt',
      ));
    });
  }

  QueryBuilder<AppMetadataCollection, AppMetadataCollection,
      QAfterFilterCondition> createdAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AppMetadataCollection, AppMetadataCollection,
      QAfterFilterCondition> createdAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AppMetadataCollection, AppMetadataCollection,
      QAfterFilterCondition> createdAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AppMetadataCollection, AppMetadataCollection,
      QAfterFilterCondition> createdAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AppMetadataCollection, AppMetadataCollection,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AppMetadataCollection, AppMetadataCollection,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<AppMetadataCollection, AppMetadataCollection,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AppMetadataCollection, AppMetadataCollection,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<AppMetadataCollection, AppMetadataCollection,
      QAfterFilterCondition> isFirstLaunchEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isFirstLaunch',
        value: value,
      ));
    });
  }

  QueryBuilder<AppMetadataCollection, AppMetadataCollection,
      QAfterFilterCondition> schemaVersionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'schemaVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<AppMetadataCollection, AppMetadataCollection,
      QAfterFilterCondition> schemaVersionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'schemaVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<AppMetadataCollection, AppMetadataCollection,
      QAfterFilterCondition> schemaVersionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'schemaVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<AppMetadataCollection, AppMetadataCollection,
      QAfterFilterCondition> schemaVersionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'schemaVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AppMetadataCollectionQueryObject on QueryBuilder<
    AppMetadataCollection, AppMetadataCollection, QFilterCondition> {}

extension AppMetadataCollectionQueryLinks on QueryBuilder<AppMetadataCollection,
    AppMetadataCollection, QFilterCondition> {}

extension AppMetadataCollectionQuerySortBy
    on QueryBuilder<AppMetadataCollection, AppMetadataCollection, QSortBy> {
  QueryBuilder<AppMetadataCollection, AppMetadataCollection, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AppMetadataCollection, AppMetadataCollection, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AppMetadataCollection, AppMetadataCollection, QAfterSortBy>
      sortByIsFirstLaunch() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFirstLaunch', Sort.asc);
    });
  }

  QueryBuilder<AppMetadataCollection, AppMetadataCollection, QAfterSortBy>
      sortByIsFirstLaunchDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFirstLaunch', Sort.desc);
    });
  }

  QueryBuilder<AppMetadataCollection, AppMetadataCollection, QAfterSortBy>
      sortBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<AppMetadataCollection, AppMetadataCollection, QAfterSortBy>
      sortBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }
}

extension AppMetadataCollectionQuerySortThenBy
    on QueryBuilder<AppMetadataCollection, AppMetadataCollection, QSortThenBy> {
  QueryBuilder<AppMetadataCollection, AppMetadataCollection, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<AppMetadataCollection, AppMetadataCollection, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<AppMetadataCollection, AppMetadataCollection, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AppMetadataCollection, AppMetadataCollection, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AppMetadataCollection, AppMetadataCollection, QAfterSortBy>
      thenByIsFirstLaunch() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFirstLaunch', Sort.asc);
    });
  }

  QueryBuilder<AppMetadataCollection, AppMetadataCollection, QAfterSortBy>
      thenByIsFirstLaunchDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isFirstLaunch', Sort.desc);
    });
  }

  QueryBuilder<AppMetadataCollection, AppMetadataCollection, QAfterSortBy>
      thenBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.asc);
    });
  }

  QueryBuilder<AppMetadataCollection, AppMetadataCollection, QAfterSortBy>
      thenBySchemaVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'schemaVersion', Sort.desc);
    });
  }
}

extension AppMetadataCollectionQueryWhereDistinct
    on QueryBuilder<AppMetadataCollection, AppMetadataCollection, QDistinct> {
  QueryBuilder<AppMetadataCollection, AppMetadataCollection, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<AppMetadataCollection, AppMetadataCollection, QDistinct>
      distinctByIsFirstLaunch() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isFirstLaunch');
    });
  }

  QueryBuilder<AppMetadataCollection, AppMetadataCollection, QDistinct>
      distinctBySchemaVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'schemaVersion');
    });
  }
}

extension AppMetadataCollectionQueryProperty on QueryBuilder<
    AppMetadataCollection, AppMetadataCollection, QQueryProperty> {
  QueryBuilder<AppMetadataCollection, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AppMetadataCollection, DateTime?, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<AppMetadataCollection, bool, QQueryOperations>
      isFirstLaunchProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isFirstLaunch');
    });
  }

  QueryBuilder<AppMetadataCollection, int, QQueryOperations>
      schemaVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'schemaVersion');
    });
  }
}
