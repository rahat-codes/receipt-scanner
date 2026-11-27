// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, Category> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, key, colorValue, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Category> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Category map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Category(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class Category extends DataClass implements Insertable<Category> {
  final int id;
  final String key;
  final int colorValue;
  final int sortOrder;
  const Category({
    required this.id,
    required this.key,
    required this.colorValue,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['key'] = Variable<String>(key);
    map['color_value'] = Variable<int>(colorValue);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      key: Value(key),
      colorValue: Value(colorValue),
      sortOrder: Value(sortOrder),
    );
  }

  factory Category.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Category(
      id: serializer.fromJson<int>(json['id']),
      key: serializer.fromJson<String>(json['key']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'key': serializer.toJson<String>(key),
      'colorValue': serializer.toJson<int>(colorValue),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Category copyWith({int? id, String? key, int? colorValue, int? sortOrder}) =>
      Category(
        id: id ?? this.id,
        key: key ?? this.key,
        colorValue: colorValue ?? this.colorValue,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  Category copyWithCompanion(CategoriesCompanion data) {
    return Category(
      id: data.id.present ? data.id.value : this.id,
      key: data.key.present ? data.key.value : this.key,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Category(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('colorValue: $colorValue, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, key, colorValue, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Category &&
          other.id == this.id &&
          other.key == this.key &&
          other.colorValue == this.colorValue &&
          other.sortOrder == this.sortOrder);
}

class CategoriesCompanion extends UpdateCompanion<Category> {
  final Value<int> id;
  final Value<String> key;
  final Value<int> colorValue;
  final Value<int> sortOrder;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.key = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String key,
    required int colorValue,
    this.sortOrder = const Value.absent(),
  }) : key = Value(key),
       colorValue = Value(colorValue);
  static Insertable<Category> custom({
    Expression<int>? id,
    Expression<String>? key,
    Expression<int>? colorValue,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (key != null) 'key': key,
      if (colorValue != null) 'color_value': colorValue,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? key,
    Value<int>? colorValue,
    Value<int>? sortOrder,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      key: key ?? this.key,
      colorValue: colorValue ?? this.colorValue,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('colorValue: $colorValue, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $ReceiptsTable extends Receipts with TableInfo<$ReceiptsTable, Receipt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReceiptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _merchantMeta = const VerificationMeta(
    'merchant',
  );
  @override
  late final GeneratedColumn<String> merchant = GeneratedColumn<String>(
    'merchant',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _purchasedAtMeta = const VerificationMeta(
    'purchasedAt',
  );
  @override
  late final GeneratedColumn<DateTime> purchasedAt = GeneratedColumn<DateTime>(
    'purchased_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMinorMeta = const VerificationMeta(
    'totalMinor',
  );
  @override
  late final GeneratedColumn<int> totalMinor = GeneratedColumn<int>(
    'total_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 3,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('KRW'),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rawOcrTextMeta = const VerificationMeta(
    'rawOcrText',
  );
  @override
  late final GeneratedColumn<String> rawOcrText = GeneratedColumn<String>(
    'raw_ocr_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _parserSourceMeta = const VerificationMeta(
    'parserSource',
  );
  @override
  late final GeneratedColumn<String> parserSource = GeneratedColumn<String>(
    'parser_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('rules'),
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    merchant,
    purchasedAt,
    totalMinor,
    currency,
    categoryId,
    imagePath,
    rawOcrText,
    parserSource,
    confidence,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'receipts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Receipt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('merchant')) {
      context.handle(
        _merchantMeta,
        merchant.isAcceptableOrUnknown(data['merchant']!, _merchantMeta),
      );
    }
    if (data.containsKey('purchased_at')) {
      context.handle(
        _purchasedAtMeta,
        purchasedAt.isAcceptableOrUnknown(
          data['purchased_at']!,
          _purchasedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchasedAtMeta);
    }
    if (data.containsKey('total_minor')) {
      context.handle(
        _totalMinorMeta,
        totalMinor.isAcceptableOrUnknown(data['total_minor']!, _totalMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMinorMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('raw_ocr_text')) {
      context.handle(
        _rawOcrTextMeta,
        rawOcrText.isAcceptableOrUnknown(
          data['raw_ocr_text']!,
          _rawOcrTextMeta,
        ),
      );
    }
    if (data.containsKey('parser_source')) {
      context.handle(
        _parserSourceMeta,
        parserSource.isAcceptableOrUnknown(
          data['parser_source']!,
          _parserSourceMeta,
        ),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Receipt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Receipt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      merchant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant'],
      )!,
      purchasedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purchased_at'],
      )!,
      totalMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_minor'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      rawOcrText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_ocr_text'],
      )!,
      parserSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parser_source'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ReceiptsTable createAlias(String alias) {
    return $ReceiptsTable(attachedDatabase, alias);
  }
}

class Receipt extends DataClass implements Insertable<Receipt> {
  final int id;
  final String merchant;
  final DateTime purchasedAt;
  final int totalMinor;
  final String currency;
  final int categoryId;
  final String? imagePath;
  final String rawOcrText;
  final String parserSource;
  final double confidence;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Receipt({
    required this.id,
    required this.merchant,
    required this.purchasedAt,
    required this.totalMinor,
    required this.currency,
    required this.categoryId,
    this.imagePath,
    required this.rawOcrText,
    required this.parserSource,
    required this.confidence,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['merchant'] = Variable<String>(merchant);
    map['purchased_at'] = Variable<DateTime>(purchasedAt);
    map['total_minor'] = Variable<int>(totalMinor);
    map['currency'] = Variable<String>(currency);
    map['category_id'] = Variable<int>(categoryId);
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['raw_ocr_text'] = Variable<String>(rawOcrText);
    map['parser_source'] = Variable<String>(parserSource);
    map['confidence'] = Variable<double>(confidence);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ReceiptsCompanion toCompanion(bool nullToAbsent) {
    return ReceiptsCompanion(
      id: Value(id),
      merchant: Value(merchant),
      purchasedAt: Value(purchasedAt),
      totalMinor: Value(totalMinor),
      currency: Value(currency),
      categoryId: Value(categoryId),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      rawOcrText: Value(rawOcrText),
      parserSource: Value(parserSource),
      confidence: Value(confidence),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Receipt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Receipt(
      id: serializer.fromJson<int>(json['id']),
      merchant: serializer.fromJson<String>(json['merchant']),
      purchasedAt: serializer.fromJson<DateTime>(json['purchasedAt']),
      totalMinor: serializer.fromJson<int>(json['totalMinor']),
      currency: serializer.fromJson<String>(json['currency']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      rawOcrText: serializer.fromJson<String>(json['rawOcrText']),
      parserSource: serializer.fromJson<String>(json['parserSource']),
      confidence: serializer.fromJson<double>(json['confidence']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'merchant': serializer.toJson<String>(merchant),
      'purchasedAt': serializer.toJson<DateTime>(purchasedAt),
      'totalMinor': serializer.toJson<int>(totalMinor),
      'currency': serializer.toJson<String>(currency),
      'categoryId': serializer.toJson<int>(categoryId),
      'imagePath': serializer.toJson<String?>(imagePath),
      'rawOcrText': serializer.toJson<String>(rawOcrText),
      'parserSource': serializer.toJson<String>(parserSource),
      'confidence': serializer.toJson<double>(confidence),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Receipt copyWith({
    int? id,
    String? merchant,
    DateTime? purchasedAt,
    int? totalMinor,
    String? currency,
    int? categoryId,
    Value<String?> imagePath = const Value.absent(),
    String? rawOcrText,
    String? parserSource,
    double? confidence,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Receipt(
    id: id ?? this.id,
    merchant: merchant ?? this.merchant,
    purchasedAt: purchasedAt ?? this.purchasedAt,
    totalMinor: totalMinor ?? this.totalMinor,
    currency: currency ?? this.currency,
    categoryId: categoryId ?? this.categoryId,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    rawOcrText: rawOcrText ?? this.rawOcrText,
    parserSource: parserSource ?? this.parserSource,
    confidence: confidence ?? this.confidence,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Receipt copyWithCompanion(ReceiptsCompanion data) {
    return Receipt(
      id: data.id.present ? data.id.value : this.id,
      merchant: data.merchant.present ? data.merchant.value : this.merchant,
      purchasedAt: data.purchasedAt.present
          ? data.purchasedAt.value
          : this.purchasedAt,
      totalMinor: data.totalMinor.present
          ? data.totalMinor.value
          : this.totalMinor,
      currency: data.currency.present ? data.currency.value : this.currency,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      rawOcrText: data.rawOcrText.present
          ? data.rawOcrText.value
          : this.rawOcrText,
      parserSource: data.parserSource.present
          ? data.parserSource.value
          : this.parserSource,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Receipt(')
          ..write('id: $id, ')
          ..write('merchant: $merchant, ')
          ..write('purchasedAt: $purchasedAt, ')
          ..write('totalMinor: $totalMinor, ')
          ..write('currency: $currency, ')
          ..write('categoryId: $categoryId, ')
          ..write('imagePath: $imagePath, ')
          ..write('rawOcrText: $rawOcrText, ')
          ..write('parserSource: $parserSource, ')
          ..write('confidence: $confidence, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    merchant,
    purchasedAt,
    totalMinor,
    currency,
    categoryId,
    imagePath,
    rawOcrText,
    parserSource,
    confidence,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Receipt &&
          other.id == this.id &&
          other.merchant == this.merchant &&
          other.purchasedAt == this.purchasedAt &&
          other.totalMinor == this.totalMinor &&
          other.currency == this.currency &&
          other.categoryId == this.categoryId &&
          other.imagePath == this.imagePath &&
          other.rawOcrText == this.rawOcrText &&
          other.parserSource == this.parserSource &&
          other.confidence == this.confidence &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ReceiptsCompanion extends UpdateCompanion<Receipt> {
  final Value<int> id;
  final Value<String> merchant;
  final Value<DateTime> purchasedAt;
  final Value<int> totalMinor;
  final Value<String> currency;
  final Value<int> categoryId;
  final Value<String?> imagePath;
  final Value<String> rawOcrText;
  final Value<String> parserSource;
  final Value<double> confidence;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ReceiptsCompanion({
    this.id = const Value.absent(),
    this.merchant = const Value.absent(),
    this.purchasedAt = const Value.absent(),
    this.totalMinor = const Value.absent(),
    this.currency = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.rawOcrText = const Value.absent(),
    this.parserSource = const Value.absent(),
    this.confidence = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ReceiptsCompanion.insert({
    this.id = const Value.absent(),
    this.merchant = const Value.absent(),
    required DateTime purchasedAt,
    required int totalMinor,
    this.currency = const Value.absent(),
    required int categoryId,
    this.imagePath = const Value.absent(),
    this.rawOcrText = const Value.absent(),
    this.parserSource = const Value.absent(),
    this.confidence = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : purchasedAt = Value(purchasedAt),
       totalMinor = Value(totalMinor),
       categoryId = Value(categoryId);
  static Insertable<Receipt> custom({
    Expression<int>? id,
    Expression<String>? merchant,
    Expression<DateTime>? purchasedAt,
    Expression<int>? totalMinor,
    Expression<String>? currency,
    Expression<int>? categoryId,
    Expression<String>? imagePath,
    Expression<String>? rawOcrText,
    Expression<String>? parserSource,
    Expression<double>? confidence,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (merchant != null) 'merchant': merchant,
      if (purchasedAt != null) 'purchased_at': purchasedAt,
      if (totalMinor != null) 'total_minor': totalMinor,
      if (currency != null) 'currency': currency,
      if (categoryId != null) 'category_id': categoryId,
      if (imagePath != null) 'image_path': imagePath,
      if (rawOcrText != null) 'raw_ocr_text': rawOcrText,
      if (parserSource != null) 'parser_source': parserSource,
      if (confidence != null) 'confidence': confidence,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ReceiptsCompanion copyWith({
    Value<int>? id,
    Value<String>? merchant,
    Value<DateTime>? purchasedAt,
    Value<int>? totalMinor,
    Value<String>? currency,
    Value<int>? categoryId,
    Value<String?>? imagePath,
    Value<String>? rawOcrText,
    Value<String>? parserSource,
    Value<double>? confidence,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ReceiptsCompanion(
      id: id ?? this.id,
      merchant: merchant ?? this.merchant,
      purchasedAt: purchasedAt ?? this.purchasedAt,
      totalMinor: totalMinor ?? this.totalMinor,
      currency: currency ?? this.currency,
      categoryId: categoryId ?? this.categoryId,
      imagePath: imagePath ?? this.imagePath,
      rawOcrText: rawOcrText ?? this.rawOcrText,
      parserSource: parserSource ?? this.parserSource,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (merchant.present) {
      map['merchant'] = Variable<String>(merchant.value);
    }
    if (purchasedAt.present) {
      map['purchased_at'] = Variable<DateTime>(purchasedAt.value);
    }
    if (totalMinor.present) {
      map['total_minor'] = Variable<int>(totalMinor.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (rawOcrText.present) {
      map['raw_ocr_text'] = Variable<String>(rawOcrText.value);
    }
    if (parserSource.present) {
      map['parser_source'] = Variable<String>(parserSource.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptsCompanion(')
          ..write('id: $id, ')
          ..write('merchant: $merchant, ')
          ..write('purchasedAt: $purchasedAt, ')
          ..write('totalMinor: $totalMinor, ')
          ..write('currency: $currency, ')
          ..write('categoryId: $categoryId, ')
          ..write('imagePath: $imagePath, ')
          ..write('rawOcrText: $rawOcrText, ')
          ..write('parserSource: $parserSource, ')
          ..write('confidence: $confidence, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ReceiptItemsTable extends ReceiptItems
    with TableInfo<$ReceiptItemsTable, ReceiptItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReceiptItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _receiptIdMeta = const VerificationMeta(
    'receiptId',
  );
  @override
  late final GeneratedColumn<int> receiptId = GeneratedColumn<int>(
    'receipt_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _unitPriceMinorMeta = const VerificationMeta(
    'unitPriceMinor',
  );
  @override
  late final GeneratedColumn<int> unitPriceMinor = GeneratedColumn<int>(
    'unit_price_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lineTotalMinorMeta = const VerificationMeta(
    'lineTotalMinor',
  );
  @override
  late final GeneratedColumn<int> lineTotalMinor = GeneratedColumn<int>(
    'line_total_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    receiptId,
    name,
    quantity,
    unitPriceMinor,
    lineTotalMinor,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'receipt_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReceiptItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('receipt_id')) {
      context.handle(
        _receiptIdMeta,
        receiptId.isAcceptableOrUnknown(data['receipt_id']!, _receiptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_receiptIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('unit_price_minor')) {
      context.handle(
        _unitPriceMinorMeta,
        unitPriceMinor.isAcceptableOrUnknown(
          data['unit_price_minor']!,
          _unitPriceMinorMeta,
        ),
      );
    }
    if (data.containsKey('line_total_minor')) {
      context.handle(
        _lineTotalMinorMeta,
        lineTotalMinor.isAcceptableOrUnknown(
          data['line_total_minor']!,
          _lineTotalMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lineTotalMinorMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReceiptItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReceiptItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      receiptId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}receipt_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      unitPriceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_minor'],
      ),
      lineTotalMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}line_total_minor'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $ReceiptItemsTable createAlias(String alias) {
    return $ReceiptItemsTable(attachedDatabase, alias);
  }
}

class ReceiptItem extends DataClass implements Insertable<ReceiptItem> {
  final int id;
  final int receiptId;
  final String name;
  final int quantity;
  final int? unitPriceMinor;
  final int lineTotalMinor;
  final int position;
  const ReceiptItem({
    required this.id,
    required this.receiptId,
    required this.name,
    required this.quantity,
    this.unitPriceMinor,
    required this.lineTotalMinor,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['receipt_id'] = Variable<int>(receiptId);
    map['name'] = Variable<String>(name);
    map['quantity'] = Variable<int>(quantity);
    if (!nullToAbsent || unitPriceMinor != null) {
      map['unit_price_minor'] = Variable<int>(unitPriceMinor);
    }
    map['line_total_minor'] = Variable<int>(lineTotalMinor);
    map['position'] = Variable<int>(position);
    return map;
  }

  ReceiptItemsCompanion toCompanion(bool nullToAbsent) {
    return ReceiptItemsCompanion(
      id: Value(id),
      receiptId: Value(receiptId),
      name: Value(name),
      quantity: Value(quantity),
      unitPriceMinor: unitPriceMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(unitPriceMinor),
      lineTotalMinor: Value(lineTotalMinor),
      position: Value(position),
    );
  }

  factory ReceiptItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReceiptItem(
      id: serializer.fromJson<int>(json['id']),
      receiptId: serializer.fromJson<int>(json['receiptId']),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPriceMinor: serializer.fromJson<int?>(json['unitPriceMinor']),
      lineTotalMinor: serializer.fromJson<int>(json['lineTotalMinor']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'receiptId': serializer.toJson<int>(receiptId),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<int>(quantity),
      'unitPriceMinor': serializer.toJson<int?>(unitPriceMinor),
      'lineTotalMinor': serializer.toJson<int>(lineTotalMinor),
      'position': serializer.toJson<int>(position),
    };
  }

  ReceiptItem copyWith({
    int? id,
    int? receiptId,
    String? name,
    int? quantity,
    Value<int?> unitPriceMinor = const Value.absent(),
    int? lineTotalMinor,
    int? position,
  }) => ReceiptItem(
    id: id ?? this.id,
    receiptId: receiptId ?? this.receiptId,
    name: name ?? this.name,
    quantity: quantity ?? this.quantity,
    unitPriceMinor: unitPriceMinor.present
        ? unitPriceMinor.value
        : this.unitPriceMinor,
    lineTotalMinor: lineTotalMinor ?? this.lineTotalMinor,
    position: position ?? this.position,
  );
  ReceiptItem copyWithCompanion(ReceiptItemsCompanion data) {
    return ReceiptItem(
      id: data.id.present ? data.id.value : this.id,
      receiptId: data.receiptId.present ? data.receiptId.value : this.receiptId,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPriceMinor: data.unitPriceMinor.present
          ? data.unitPriceMinor.value
          : this.unitPriceMinor,
      lineTotalMinor: data.lineTotalMinor.present
          ? data.lineTotalMinor.value
          : this.lineTotalMinor,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptItem(')
          ..write('id: $id, ')
          ..write('receiptId: $receiptId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unitPriceMinor: $unitPriceMinor, ')
          ..write('lineTotalMinor: $lineTotalMinor, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    receiptId,
    name,
    quantity,
    unitPriceMinor,
    lineTotalMinor,
    position,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReceiptItem &&
          other.id == this.id &&
          other.receiptId == this.receiptId &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.unitPriceMinor == this.unitPriceMinor &&
          other.lineTotalMinor == this.lineTotalMinor &&
          other.position == this.position);
}

class ReceiptItemsCompanion extends UpdateCompanion<ReceiptItem> {
  final Value<int> id;
  final Value<int> receiptId;
  final Value<String> name;
  final Value<int> quantity;
  final Value<int?> unitPriceMinor;
  final Value<int> lineTotalMinor;
  final Value<int> position;
  const ReceiptItemsCompanion({
    this.id = const Value.absent(),
    this.receiptId = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPriceMinor = const Value.absent(),
    this.lineTotalMinor = const Value.absent(),
    this.position = const Value.absent(),
  });
  ReceiptItemsCompanion.insert({
    this.id = const Value.absent(),
    required int receiptId,
    required String name,
    this.quantity = const Value.absent(),
    this.unitPriceMinor = const Value.absent(),
    required int lineTotalMinor,
    this.position = const Value.absent(),
  }) : receiptId = Value(receiptId),
       name = Value(name),
       lineTotalMinor = Value(lineTotalMinor);
  static Insertable<ReceiptItem> custom({
    Expression<int>? id,
    Expression<int>? receiptId,
    Expression<String>? name,
    Expression<int>? quantity,
    Expression<int>? unitPriceMinor,
    Expression<int>? lineTotalMinor,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (receiptId != null) 'receipt_id': receiptId,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (unitPriceMinor != null) 'unit_price_minor': unitPriceMinor,
      if (lineTotalMinor != null) 'line_total_minor': lineTotalMinor,
      if (position != null) 'position': position,
    });
  }

  ReceiptItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? receiptId,
    Value<String>? name,
    Value<int>? quantity,
    Value<int?>? unitPriceMinor,
    Value<int>? lineTotalMinor,
    Value<int>? position,
  }) {
    return ReceiptItemsCompanion(
      id: id ?? this.id,
      receiptId: receiptId ?? this.receiptId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitPriceMinor: unitPriceMinor ?? this.unitPriceMinor,
      lineTotalMinor: lineTotalMinor ?? this.lineTotalMinor,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (receiptId.present) {
      map['receipt_id'] = Variable<int>(receiptId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPriceMinor.present) {
      map['unit_price_minor'] = Variable<int>(unitPriceMinor.value);
    }
    if (lineTotalMinor.present) {
      map['line_total_minor'] = Variable<int>(lineTotalMinor.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptItemsCompanion(')
          ..write('id: $id, ')
          ..write('receiptId: $receiptId, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unitPriceMinor: $unitPriceMinor, ')
          ..write('lineTotalMinor: $lineTotalMinor, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

class $MerchantRulesTable extends MerchantRules
    with TableInfo<$MerchantRulesTable, MerchantRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MerchantRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _merchantKeyMeta = const VerificationMeta(
    'merchantKey',
  );
  @override
  late final GeneratedColumn<String> merchantKey = GeneratedColumn<String>(
    'merchant_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hitCountMeta = const VerificationMeta(
    'hitCount',
  );
  @override
  late final GeneratedColumn<int> hitCount = GeneratedColumn<int>(
    'hit_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    merchantKey,
    categoryId,
    hitCount,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'merchant_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<MerchantRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('merchant_key')) {
      context.handle(
        _merchantKeyMeta,
        merchantKey.isAcceptableOrUnknown(
          data['merchant_key']!,
          _merchantKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_merchantKeyMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('hit_count')) {
      context.handle(
        _hitCountMeta,
        hitCount.isAcceptableOrUnknown(data['hit_count']!, _hitCountMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MerchantRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MerchantRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      merchantKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant_key'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      hitCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hit_count'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MerchantRulesTable createAlias(String alias) {
    return $MerchantRulesTable(attachedDatabase, alias);
  }
}

class MerchantRule extends DataClass implements Insertable<MerchantRule> {
  final int id;
  final String merchantKey;
  final int categoryId;
  final int hitCount;
  final DateTime updatedAt;
  const MerchantRule({
    required this.id,
    required this.merchantKey,
    required this.categoryId,
    required this.hitCount,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['merchant_key'] = Variable<String>(merchantKey);
    map['category_id'] = Variable<int>(categoryId);
    map['hit_count'] = Variable<int>(hitCount);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MerchantRulesCompanion toCompanion(bool nullToAbsent) {
    return MerchantRulesCompanion(
      id: Value(id),
      merchantKey: Value(merchantKey),
      categoryId: Value(categoryId),
      hitCount: Value(hitCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory MerchantRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MerchantRule(
      id: serializer.fromJson<int>(json['id']),
      merchantKey: serializer.fromJson<String>(json['merchantKey']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      hitCount: serializer.fromJson<int>(json['hitCount']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'merchantKey': serializer.toJson<String>(merchantKey),
      'categoryId': serializer.toJson<int>(categoryId),
      'hitCount': serializer.toJson<int>(hitCount),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MerchantRule copyWith({
    int? id,
    String? merchantKey,
    int? categoryId,
    int? hitCount,
    DateTime? updatedAt,
  }) => MerchantRule(
    id: id ?? this.id,
    merchantKey: merchantKey ?? this.merchantKey,
    categoryId: categoryId ?? this.categoryId,
    hitCount: hitCount ?? this.hitCount,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MerchantRule copyWithCompanion(MerchantRulesCompanion data) {
    return MerchantRule(
      id: data.id.present ? data.id.value : this.id,
      merchantKey: data.merchantKey.present
          ? data.merchantKey.value
          : this.merchantKey,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      hitCount: data.hitCount.present ? data.hitCount.value : this.hitCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MerchantRule(')
          ..write('id: $id, ')
          ..write('merchantKey: $merchantKey, ')
          ..write('categoryId: $categoryId, ')
          ..write('hitCount: $hitCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, merchantKey, categoryId, hitCount, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MerchantRule &&
          other.id == this.id &&
          other.merchantKey == this.merchantKey &&
          other.categoryId == this.categoryId &&
          other.hitCount == this.hitCount &&
          other.updatedAt == this.updatedAt);
}

class MerchantRulesCompanion extends UpdateCompanion<MerchantRule> {
  final Value<int> id;
  final Value<String> merchantKey;
  final Value<int> categoryId;
  final Value<int> hitCount;
  final Value<DateTime> updatedAt;
  const MerchantRulesCompanion({
    this.id = const Value.absent(),
    this.merchantKey = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.hitCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MerchantRulesCompanion.insert({
    this.id = const Value.absent(),
    required String merchantKey,
    required int categoryId,
    this.hitCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : merchantKey = Value(merchantKey),
       categoryId = Value(categoryId);
  static Insertable<MerchantRule> custom({
    Expression<int>? id,
    Expression<String>? merchantKey,
    Expression<int>? categoryId,
    Expression<int>? hitCount,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (merchantKey != null) 'merchant_key': merchantKey,
      if (categoryId != null) 'category_id': categoryId,
      if (hitCount != null) 'hit_count': hitCount,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MerchantRulesCompanion copyWith({
    Value<int>? id,
    Value<String>? merchantKey,
    Value<int>? categoryId,
    Value<int>? hitCount,
    Value<DateTime>? updatedAt,
  }) {
    return MerchantRulesCompanion(
      id: id ?? this.id,
      merchantKey: merchantKey ?? this.merchantKey,
      categoryId: categoryId ?? this.categoryId,
      hitCount: hitCount ?? this.hitCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (merchantKey.present) {
      map['merchant_key'] = Variable<String>(merchantKey.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (hitCount.present) {
      map['hit_count'] = Variable<int>(hitCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MerchantRulesCompanion(')
          ..write('id: $id, ')
          ..write('merchantKey: $merchantKey, ')
          ..write('categoryId: $categoryId, ')
          ..write('hitCount: $hitCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AssistantTipsTable extends AssistantTips
    with TableInfo<$AssistantTipsTable, AssistantTip> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssistantTipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ruleKeyMeta = const VerificationMeta(
    'ruleKey',
  );
  @override
  late final GeneratedColumn<String> ruleKey = GeneratedColumn<String>(
    'rule_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
    'scheduled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    ruleKey,
    title,
    body,
    scheduledAt,
    readAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assistant_tips';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssistantTip> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('rule_key')) {
      context.handle(
        _ruleKeyMeta,
        ruleKey.isAcceptableOrUnknown(data['rule_key']!, _ruleKeyMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssistantTip map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssistantTip(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      ruleKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rule_key'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_at'],
      ),
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AssistantTipsTable createAlias(String alias) {
    return $AssistantTipsTable(attachedDatabase, alias);
  }
}

class AssistantTip extends DataClass implements Insertable<AssistantTip> {
  final int id;
  final String kind;
  final String? ruleKey;
  final String title;
  final String body;
  final DateTime? scheduledAt;
  final DateTime? readAt;
  final DateTime createdAt;
  const AssistantTip({
    required this.id,
    required this.kind,
    this.ruleKey,
    required this.title,
    required this.body,
    this.scheduledAt,
    this.readAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || ruleKey != null) {
      map['rule_key'] = Variable<String>(ruleKey);
    }
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || scheduledAt != null) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    }
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AssistantTipsCompanion toCompanion(bool nullToAbsent) {
    return AssistantTipsCompanion(
      id: Value(id),
      kind: Value(kind),
      ruleKey: ruleKey == null && nullToAbsent
          ? const Value.absent()
          : Value(ruleKey),
      title: Value(title),
      body: Value(body),
      scheduledAt: scheduledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledAt),
      readAt: readAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readAt),
      createdAt: Value(createdAt),
    );
  }

  factory AssistantTip.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssistantTip(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      ruleKey: serializer.fromJson<String?>(json['ruleKey']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      scheduledAt: serializer.fromJson<DateTime?>(json['scheduledAt']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'ruleKey': serializer.toJson<String?>(ruleKey),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'scheduledAt': serializer.toJson<DateTime?>(scheduledAt),
      'readAt': serializer.toJson<DateTime?>(readAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AssistantTip copyWith({
    int? id,
    String? kind,
    Value<String?> ruleKey = const Value.absent(),
    String? title,
    String? body,
    Value<DateTime?> scheduledAt = const Value.absent(),
    Value<DateTime?> readAt = const Value.absent(),
    DateTime? createdAt,
  }) => AssistantTip(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    ruleKey: ruleKey.present ? ruleKey.value : this.ruleKey,
    title: title ?? this.title,
    body: body ?? this.body,
    scheduledAt: scheduledAt.present ? scheduledAt.value : this.scheduledAt,
    readAt: readAt.present ? readAt.value : this.readAt,
    createdAt: createdAt ?? this.createdAt,
  );
  AssistantTip copyWithCompanion(AssistantTipsCompanion data) {
    return AssistantTip(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      ruleKey: data.ruleKey.present ? data.ruleKey.value : this.ruleKey,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssistantTip(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('ruleKey: $ruleKey, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('readAt: $readAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    ruleKey,
    title,
    body,
    scheduledAt,
    readAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssistantTip &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.ruleKey == this.ruleKey &&
          other.title == this.title &&
          other.body == this.body &&
          other.scheduledAt == this.scheduledAt &&
          other.readAt == this.readAt &&
          other.createdAt == this.createdAt);
}

class AssistantTipsCompanion extends UpdateCompanion<AssistantTip> {
  final Value<int> id;
  final Value<String> kind;
  final Value<String?> ruleKey;
  final Value<String> title;
  final Value<String> body;
  final Value<DateTime?> scheduledAt;
  final Value<DateTime?> readAt;
  final Value<DateTime> createdAt;
  const AssistantTipsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.ruleKey = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AssistantTipsCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    this.ruleKey = const Value.absent(),
    required String title,
    required String body,
    this.scheduledAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : kind = Value(kind),
       title = Value(title),
       body = Value(body);
  static Insertable<AssistantTip> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<String>? ruleKey,
    Expression<String>? title,
    Expression<String>? body,
    Expression<DateTime>? scheduledAt,
    Expression<DateTime>? readAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (ruleKey != null) 'rule_key': ruleKey,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (readAt != null) 'read_at': readAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AssistantTipsCompanion copyWith({
    Value<int>? id,
    Value<String>? kind,
    Value<String?>? ruleKey,
    Value<String>? title,
    Value<String>? body,
    Value<DateTime?>? scheduledAt,
    Value<DateTime?>? readAt,
    Value<DateTime>? createdAt,
  }) {
    return AssistantTipsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      ruleKey: ruleKey ?? this.ruleKey,
      title: title ?? this.title,
      body: body ?? this.body,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (ruleKey.present) {
      map['rule_key'] = Variable<String>(ruleKey.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssistantTipsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('ruleKey: $ruleKey, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('readAt: $readAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ReceiptsTable receipts = $ReceiptsTable(this);
  late final $ReceiptItemsTable receiptItems = $ReceiptItemsTable(this);
  late final $MerchantRulesTable merchantRules = $MerchantRulesTable(this);
  late final $AssistantTipsTable assistantTips = $AssistantTipsTable(this);
  late final Index idxReceiptsPurchasedAt = Index(
    'idx_receipts_purchased_at',
    'CREATE INDEX idx_receipts_purchased_at ON receipts (purchased_at)',
  );
  late final Index idxReceiptsCategory = Index(
    'idx_receipts_category',
    'CREATE INDEX idx_receipts_category ON receipts (category_id)',
  );
  late final Index idxReceiptsDupe = Index(
    'idx_receipts_dupe',
    'CREATE INDEX idx_receipts_dupe ON receipts (purchased_at, total_minor)',
  );
  late final Index idxItemsReceipt = Index(
    'idx_items_receipt',
    'CREATE INDEX idx_items_receipt ON receipt_items (receipt_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    receipts,
    receiptItems,
    merchantRules,
    assistantTips,
    idxReceiptsPurchasedAt,
    idxReceiptsCategory,
    idxReceiptsDupe,
    idxItemsReceipt,
  ];
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String key,
      required int colorValue,
      Value<int> sortOrder,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> key,
      Value<int> colorValue,
      Value<int> sortOrder,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          Category,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
          Category,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                key: key,
                colorValue: colorValue,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String key,
                required int colorValue,
                Value<int> sortOrder = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                key: key,
                colorValue: colorValue,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      Category,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (Category, BaseReferences<_$AppDatabase, $CategoriesTable, Category>),
      Category,
      PrefetchHooks Function()
    >;
typedef $$ReceiptsTableCreateCompanionBuilder =
    ReceiptsCompanion Function({
      Value<int> id,
      Value<String> merchant,
      required DateTime purchasedAt,
      required int totalMinor,
      Value<String> currency,
      required int categoryId,
      Value<String?> imagePath,
      Value<String> rawOcrText,
      Value<String> parserSource,
      Value<double> confidence,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$ReceiptsTableUpdateCompanionBuilder =
    ReceiptsCompanion Function({
      Value<int> id,
      Value<String> merchant,
      Value<DateTime> purchasedAt,
      Value<int> totalMinor,
      Value<String> currency,
      Value<int> categoryId,
      Value<String?> imagePath,
      Value<String> rawOcrText,
      Value<String> parserSource,
      Value<double> confidence,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$ReceiptsTableFilterComposer
    extends Composer<_$AppDatabase, $ReceiptsTable> {
  $$ReceiptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purchasedAt => $composableBuilder(
    column: $table.purchasedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalMinor => $composableBuilder(
    column: $table.totalMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawOcrText => $composableBuilder(
    column: $table.rawOcrText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parserSource => $composableBuilder(
    column: $table.parserSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReceiptsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReceiptsTable> {
  $$ReceiptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchant => $composableBuilder(
    column: $table.merchant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purchasedAt => $composableBuilder(
    column: $table.purchasedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalMinor => $composableBuilder(
    column: $table.totalMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawOcrText => $composableBuilder(
    column: $table.rawOcrText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parserSource => $composableBuilder(
    column: $table.parserSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReceiptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReceiptsTable> {
  $$ReceiptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get merchant =>
      $composableBuilder(column: $table.merchant, builder: (column) => column);

  GeneratedColumn<DateTime> get purchasedAt => $composableBuilder(
    column: $table.purchasedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalMinor => $composableBuilder(
    column: $table.totalMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get rawOcrText => $composableBuilder(
    column: $table.rawOcrText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parserSource => $composableBuilder(
    column: $table.parserSource,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ReceiptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReceiptsTable,
          Receipt,
          $$ReceiptsTableFilterComposer,
          $$ReceiptsTableOrderingComposer,
          $$ReceiptsTableAnnotationComposer,
          $$ReceiptsTableCreateCompanionBuilder,
          $$ReceiptsTableUpdateCompanionBuilder,
          (Receipt, BaseReferences<_$AppDatabase, $ReceiptsTable, Receipt>),
          Receipt,
          PrefetchHooks Function()
        > {
  $$ReceiptsTableTableManager(_$AppDatabase db, $ReceiptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReceiptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReceiptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReceiptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> merchant = const Value.absent(),
                Value<DateTime> purchasedAt = const Value.absent(),
                Value<int> totalMinor = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String> rawOcrText = const Value.absent(),
                Value<String> parserSource = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ReceiptsCompanion(
                id: id,
                merchant: merchant,
                purchasedAt: purchasedAt,
                totalMinor: totalMinor,
                currency: currency,
                categoryId: categoryId,
                imagePath: imagePath,
                rawOcrText: rawOcrText,
                parserSource: parserSource,
                confidence: confidence,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> merchant = const Value.absent(),
                required DateTime purchasedAt,
                required int totalMinor,
                Value<String> currency = const Value.absent(),
                required int categoryId,
                Value<String?> imagePath = const Value.absent(),
                Value<String> rawOcrText = const Value.absent(),
                Value<String> parserSource = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ReceiptsCompanion.insert(
                id: id,
                merchant: merchant,
                purchasedAt: purchasedAt,
                totalMinor: totalMinor,
                currency: currency,
                categoryId: categoryId,
                imagePath: imagePath,
                rawOcrText: rawOcrText,
                parserSource: parserSource,
                confidence: confidence,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReceiptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReceiptsTable,
      Receipt,
      $$ReceiptsTableFilterComposer,
      $$ReceiptsTableOrderingComposer,
      $$ReceiptsTableAnnotationComposer,
      $$ReceiptsTableCreateCompanionBuilder,
      $$ReceiptsTableUpdateCompanionBuilder,
      (Receipt, BaseReferences<_$AppDatabase, $ReceiptsTable, Receipt>),
      Receipt,
      PrefetchHooks Function()
    >;
typedef $$ReceiptItemsTableCreateCompanionBuilder =
    ReceiptItemsCompanion Function({
      Value<int> id,
      required int receiptId,
      required String name,
      Value<int> quantity,
      Value<int?> unitPriceMinor,
      required int lineTotalMinor,
      Value<int> position,
    });
typedef $$ReceiptItemsTableUpdateCompanionBuilder =
    ReceiptItemsCompanion Function({
      Value<int> id,
      Value<int> receiptId,
      Value<String> name,
      Value<int> quantity,
      Value<int?> unitPriceMinor,
      Value<int> lineTotalMinor,
      Value<int> position,
    });

class $$ReceiptItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ReceiptItemsTable> {
  $$ReceiptItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get receiptId => $composableBuilder(
    column: $table.receiptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPriceMinor => $composableBuilder(
    column: $table.unitPriceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lineTotalMinor => $composableBuilder(
    column: $table.lineTotalMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReceiptItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReceiptItemsTable> {
  $$ReceiptItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get receiptId => $composableBuilder(
    column: $table.receiptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPriceMinor => $composableBuilder(
    column: $table.unitPriceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lineTotalMinor => $composableBuilder(
    column: $table.lineTotalMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReceiptItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReceiptItemsTable> {
  $$ReceiptItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get receiptId =>
      $composableBuilder(column: $table.receiptId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get unitPriceMinor => $composableBuilder(
    column: $table.unitPriceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lineTotalMinor => $composableBuilder(
    column: $table.lineTotalMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$ReceiptItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReceiptItemsTable,
          ReceiptItem,
          $$ReceiptItemsTableFilterComposer,
          $$ReceiptItemsTableOrderingComposer,
          $$ReceiptItemsTableAnnotationComposer,
          $$ReceiptItemsTableCreateCompanionBuilder,
          $$ReceiptItemsTableUpdateCompanionBuilder,
          (
            ReceiptItem,
            BaseReferences<_$AppDatabase, $ReceiptItemsTable, ReceiptItem>,
          ),
          ReceiptItem,
          PrefetchHooks Function()
        > {
  $$ReceiptItemsTableTableManager(_$AppDatabase db, $ReceiptItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReceiptItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReceiptItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReceiptItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> receiptId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int?> unitPriceMinor = const Value.absent(),
                Value<int> lineTotalMinor = const Value.absent(),
                Value<int> position = const Value.absent(),
              }) => ReceiptItemsCompanion(
                id: id,
                receiptId: receiptId,
                name: name,
                quantity: quantity,
                unitPriceMinor: unitPriceMinor,
                lineTotalMinor: lineTotalMinor,
                position: position,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int receiptId,
                required String name,
                Value<int> quantity = const Value.absent(),
                Value<int?> unitPriceMinor = const Value.absent(),
                required int lineTotalMinor,
                Value<int> position = const Value.absent(),
              }) => ReceiptItemsCompanion.insert(
                id: id,
                receiptId: receiptId,
                name: name,
                quantity: quantity,
                unitPriceMinor: unitPriceMinor,
                lineTotalMinor: lineTotalMinor,
                position: position,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReceiptItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReceiptItemsTable,
      ReceiptItem,
      $$ReceiptItemsTableFilterComposer,
      $$ReceiptItemsTableOrderingComposer,
      $$ReceiptItemsTableAnnotationComposer,
      $$ReceiptItemsTableCreateCompanionBuilder,
      $$ReceiptItemsTableUpdateCompanionBuilder,
      (
        ReceiptItem,
        BaseReferences<_$AppDatabase, $ReceiptItemsTable, ReceiptItem>,
      ),
      ReceiptItem,
      PrefetchHooks Function()
    >;
typedef $$MerchantRulesTableCreateCompanionBuilder =
    MerchantRulesCompanion Function({
      Value<int> id,
      required String merchantKey,
      required int categoryId,
      Value<int> hitCount,
      Value<DateTime> updatedAt,
    });
typedef $$MerchantRulesTableUpdateCompanionBuilder =
    MerchantRulesCompanion Function({
      Value<int> id,
      Value<String> merchantKey,
      Value<int> categoryId,
      Value<int> hitCount,
      Value<DateTime> updatedAt,
    });

class $$MerchantRulesTableFilterComposer
    extends Composer<_$AppDatabase, $MerchantRulesTable> {
  $$MerchantRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchantKey => $composableBuilder(
    column: $table.merchantKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hitCount => $composableBuilder(
    column: $table.hitCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MerchantRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $MerchantRulesTable> {
  $$MerchantRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchantKey => $composableBuilder(
    column: $table.merchantKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hitCount => $composableBuilder(
    column: $table.hitCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MerchantRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MerchantRulesTable> {
  $$MerchantRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get merchantKey => $composableBuilder(
    column: $table.merchantKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hitCount =>
      $composableBuilder(column: $table.hitCount, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MerchantRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MerchantRulesTable,
          MerchantRule,
          $$MerchantRulesTableFilterComposer,
          $$MerchantRulesTableOrderingComposer,
          $$MerchantRulesTableAnnotationComposer,
          $$MerchantRulesTableCreateCompanionBuilder,
          $$MerchantRulesTableUpdateCompanionBuilder,
          (
            MerchantRule,
            BaseReferences<_$AppDatabase, $MerchantRulesTable, MerchantRule>,
          ),
          MerchantRule,
          PrefetchHooks Function()
        > {
  $$MerchantRulesTableTableManager(_$AppDatabase db, $MerchantRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MerchantRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MerchantRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MerchantRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> merchantKey = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<int> hitCount = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MerchantRulesCompanion(
                id: id,
                merchantKey: merchantKey,
                categoryId: categoryId,
                hitCount: hitCount,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String merchantKey,
                required int categoryId,
                Value<int> hitCount = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MerchantRulesCompanion.insert(
                id: id,
                merchantKey: merchantKey,
                categoryId: categoryId,
                hitCount: hitCount,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MerchantRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MerchantRulesTable,
      MerchantRule,
      $$MerchantRulesTableFilterComposer,
      $$MerchantRulesTableOrderingComposer,
      $$MerchantRulesTableAnnotationComposer,
      $$MerchantRulesTableCreateCompanionBuilder,
      $$MerchantRulesTableUpdateCompanionBuilder,
      (
        MerchantRule,
        BaseReferences<_$AppDatabase, $MerchantRulesTable, MerchantRule>,
      ),
      MerchantRule,
      PrefetchHooks Function()
    >;
typedef $$AssistantTipsTableCreateCompanionBuilder =
    AssistantTipsCompanion Function({
      Value<int> id,
      required String kind,
      Value<String?> ruleKey,
      required String title,
      required String body,
      Value<DateTime?> scheduledAt,
      Value<DateTime?> readAt,
      Value<DateTime> createdAt,
    });
typedef $$AssistantTipsTableUpdateCompanionBuilder =
    AssistantTipsCompanion Function({
      Value<int> id,
      Value<String> kind,
      Value<String?> ruleKey,
      Value<String> title,
      Value<String> body,
      Value<DateTime?> scheduledAt,
      Value<DateTime?> readAt,
      Value<DateTime> createdAt,
    });

class $$AssistantTipsTableFilterComposer
    extends Composer<_$AppDatabase, $AssistantTipsTable> {
  $$AssistantTipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ruleKey => $composableBuilder(
    column: $table.ruleKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AssistantTipsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssistantTipsTable> {
  $$AssistantTipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ruleKey => $composableBuilder(
    column: $table.ruleKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssistantTipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssistantTipsTable> {
  $$AssistantTipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get ruleKey =>
      $composableBuilder(column: $table.ruleKey, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AssistantTipsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssistantTipsTable,
          AssistantTip,
          $$AssistantTipsTableFilterComposer,
          $$AssistantTipsTableOrderingComposer,
          $$AssistantTipsTableAnnotationComposer,
          $$AssistantTipsTableCreateCompanionBuilder,
          $$AssistantTipsTableUpdateCompanionBuilder,
          (
            AssistantTip,
            BaseReferences<_$AppDatabase, $AssistantTipsTable, AssistantTip>,
          ),
          AssistantTip,
          PrefetchHooks Function()
        > {
  $$AssistantTipsTableTableManager(_$AppDatabase db, $AssistantTipsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssistantTipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssistantTipsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssistantTipsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> ruleKey = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime?> scheduledAt = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AssistantTipsCompanion(
                id: id,
                kind: kind,
                ruleKey: ruleKey,
                title: title,
                body: body,
                scheduledAt: scheduledAt,
                readAt: readAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kind,
                Value<String?> ruleKey = const Value.absent(),
                required String title,
                required String body,
                Value<DateTime?> scheduledAt = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AssistantTipsCompanion.insert(
                id: id,
                kind: kind,
                ruleKey: ruleKey,
                title: title,
                body: body,
                scheduledAt: scheduledAt,
                readAt: readAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AssistantTipsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssistantTipsTable,
      AssistantTip,
      $$AssistantTipsTableFilterComposer,
      $$AssistantTipsTableOrderingComposer,
      $$AssistantTipsTableAnnotationComposer,
      $$AssistantTipsTableCreateCompanionBuilder,
      $$AssistantTipsTableUpdateCompanionBuilder,
      (
        AssistantTip,
        BaseReferences<_$AppDatabase, $AssistantTipsTable, AssistantTip>,
      ),
      AssistantTip,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ReceiptsTableTableManager get receipts =>
      $$ReceiptsTableTableManager(_db, _db.receipts);
  $$ReceiptItemsTableTableManager get receiptItems =>
      $$ReceiptItemsTableTableManager(_db, _db.receiptItems);
  $$MerchantRulesTableTableManager get merchantRules =>
      $$MerchantRulesTableTableManager(_db, _db.merchantRules);
  $$AssistantTipsTableTableManager get assistantTips =>
      $$AssistantTipsTableTableManager(_db, _db.assistantTips);
}
