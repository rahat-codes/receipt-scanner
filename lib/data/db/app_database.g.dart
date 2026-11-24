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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ReceiptsTable receipts = $ReceiptsTable(this);
  late final Index idxReceiptsPurchasedAt = Index(
    'idx_receipts_purchased_at',
    'CREATE INDEX idx_receipts_purchased_at ON receipts (purchased_at)',
  );
  late final Index idxReceiptsCategory = Index(
    'idx_receipts_category',
    'CREATE INDEX idx_receipts_category ON receipts (category_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    receipts,
    idxReceiptsPurchasedAt,
    idxReceiptsCategory,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ReceiptsTableTableManager get receipts =>
      $$ReceiptsTableTableManager(_db, _db.receipts);
}
