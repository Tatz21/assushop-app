enum LedgerType {
  collection,
  sale;

  String get label {
    switch (this) {
      case LedgerType.collection:
        return 'Collection';
      case LedgerType.sale:
        return 'Sale';
    }
  }
}

class LedgerTransactionModel {
  final String id;
  final String outletId;
  final DateTime date;
  final LedgerType type;
  final double amount;
  final String reference; // e.g., 'Cash', 'UPI', 'Cheque', 'INV-20260820-002'
  final String remarks;

  const LedgerTransactionModel({
    required this.id,
    required this.outletId,
    required this.date,
    required this.type,
    required this.amount,
    required this.reference,
    this.remarks = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'outletId': outletId,
        'date': date.toIso8601String(),
        'type': type.name,
        'amount': amount,
        'reference': reference,
        'remarks': remarks,
      };

  factory LedgerTransactionModel.fromJson(Map<String, dynamic> json) =>
      LedgerTransactionModel(
        id: json['id'] as String,
        outletId: json['outletId'] as String,
        date: DateTime.parse(json['date'] as String),
        type: LedgerType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => LedgerType.sale,
        ),
        amount: (json['amount'] as num).toDouble(),
        reference: json['reference'] as String,
        remarks: json['remarks'] as String? ?? '',
      );
}
