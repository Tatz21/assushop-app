class ProductModel {
  final String id;
  final String skuCode;
  final String name;
  final String category;
  final String packSize;
  final double mrp;
  final double baseRate;
  final double gstPercentage;
  final int stock;

  const ProductModel({
    required this.id,
    required this.skuCode,
    required this.name,
    required this.category,
    required this.packSize,
    required this.mrp,
    required this.baseRate,
    required this.gstPercentage,
    this.stock = 100,
  });

  ProductModel copyWith({
    String? id,
    String? skuCode,
    String? name,
    String? category,
    String? packSize,
    double? mrp,
    double? baseRate,
    double? gstPercentage,
    int? stock,
  }) {
    return ProductModel(
      id: id ?? this.id,
      skuCode: skuCode ?? this.skuCode,
      name: name ?? this.name,
      category: category ?? this.category,
      packSize: packSize ?? this.packSize,
      mrp: mrp ?? this.mrp,
      baseRate: baseRate ?? this.baseRate,
      gstPercentage: gstPercentage ?? this.gstPercentage,
      stock: stock ?? this.stock,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'skuCode': skuCode,
        'name': name,
        'category': category,
        'packSize': packSize,
        'mrp': mrp,
        'baseRate': baseRate,
        'gstPercentage': gstPercentage,
        'stock': stock,
      };

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        id: json['id'] as String,
        skuCode: json['skuCode'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        packSize: json['packSize'] as String,
        mrp: (json['mrp'] as num).toDouble(),
        baseRate: (json['baseRate'] as num).toDouble(),
        gstPercentage: (json['gstPercentage'] as num).toDouble(),
        stock: (json['stock'] as num?)?.toInt() ?? 100,
      );
}
