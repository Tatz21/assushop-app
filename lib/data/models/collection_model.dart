class CollectionModel {
  final String id;
  final String invoiceNo;
  final String outletId;
  final String outletName;
  final String outletCode;
  final String outletAddress;
  final double amount;
  final String paymentMode; // Cash, UPI, Cheque
  final String remarks;
  final DateTime date;
  final String status;

  const CollectionModel({
    required this.id,
    required this.invoiceNo,
    required this.outletId,
    required this.outletName,
    required this.outletCode,
    required this.outletAddress,
    required this.amount,
    required this.paymentMode,
    required this.remarks,
    required this.date,
    this.status = 'Completed',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoiceNo': invoiceNo,
        'outletId': outletId,
        'outletName': outletName,
        'outletCode': outletCode,
        'outletAddress': outletAddress,
        'amount': amount,
        'paymentMode': paymentMode,
        'remarks': remarks,
        'date': date.toIso8601String(),
        'status': status,
      };

  factory CollectionModel.fromJson(Map<String, dynamic> json) =>
      CollectionModel(
        id: json['id'] as String,
        invoiceNo: json['invoiceNo'] as String,
        outletId: json['outletId'] as String,
        outletName: json['outletName'] as String,
        outletCode: json['outletCode'] as String,
        outletAddress: json['outletAddress'] as String,
        amount: (json['amount'] as num).toDouble(),
        paymentMode: json['paymentMode'] as String,
        remarks: json['remarks'] as String? ?? '',
        date: DateTime.parse(json['date'] as String),
        status: json['status'] as String? ?? 'Completed',
      );
}
