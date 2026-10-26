class SaleItemModel {
  final String skuId;
  final String skuCode;
  final String productName;
  final int quantity;
  final double baseRate;
  final double discountPercent;
  final double gstPercentage;

  const SaleItemModel({
    required this.skuId,
    required this.skuCode,
    required this.productName,
    required this.quantity,
    required this.baseRate,
    this.discountPercent = 0.0,
    required this.gstPercentage,
  });

  double get subtotal => quantity * baseRate;
  double get discountAmount => subtotal * (discountPercent / 100);
  double get taxableAmount => subtotal - discountAmount;
  double get gstAmount => taxableAmount * (gstPercentage / 100);
  double get totalAmount => taxableAmount + gstAmount;

  Map<String, dynamic> toJson() => {
        'skuId': skuId,
        'skuCode': skuCode,
        'productName': productName,
        'quantity': quantity,
        'baseRate': baseRate,
        'discountPercent': discountPercent,
        'gstPercentage': gstPercentage,
      };

  factory SaleItemModel.fromJson(Map<String, dynamic> json) => SaleItemModel(
        skuId: json['skuId'] as String,
        skuCode: json['skuCode'] as String,
        productName: json['productName'] as String,
        quantity: (json['quantity'] as num).toInt(),
        baseRate: (json['baseRate'] as num).toDouble(),
        discountPercent: (json['discountPercent'] as num?)?.toDouble() ?? 0.0,
        gstPercentage: (json['gstPercentage'] as num).toDouble(),
      );
}

class SaleInvoiceModel {
  final String id;
  final String invoiceNumber;
  final String outletId;
  final String outletName;
  final String salesmanId;
  final DateTime date;
  final List<SaleItemModel> items;
  final String paymentMode; // 'Credit' | 'Cash' | 'UPI'
  final String remarks;

  const SaleInvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.outletId,
    required this.outletName,
    required this.salesmanId,
    required this.date,
    required this.items,
    this.paymentMode = 'Credit',
    this.remarks = '',
  });

  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.subtotal);
  double get totalDiscount =>
      items.fold(0.0, (sum, item) => sum + item.discountAmount);
  double get totalGst => items.fold(0.0, (sum, item) => sum + item.gstAmount);
  double get grandTotal =>
      items.fold(0.0, (sum, item) => sum + item.totalAmount);

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoiceNumber': invoiceNumber,
        'outletId': outletId,
        'outletName': outletName,
        'salesmanId': salesmanId,
        'date': date.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
        'paymentMode': paymentMode,
        'remarks': remarks,
      };

  factory SaleInvoiceModel.fromJson(Map<String, dynamic> json) =>
      SaleInvoiceModel(
        id: json['id'] as String,
        invoiceNumber: json['invoiceNumber'] as String,
        outletId: json['outletId'] as String,
        outletName: json['outletName'] as String,
        salesmanId: json['salesmanId'] as String,
        date: DateTime.parse(json['date'] as String),
        items: (json['items'] as List<dynamic>)
            .map((e) => SaleItemModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        paymentMode: json['paymentMode'] as String? ?? 'Credit',
        remarks: json['remarks'] as String? ?? '',
      );
}
