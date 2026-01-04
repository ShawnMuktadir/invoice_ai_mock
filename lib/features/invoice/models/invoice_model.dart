import 'package:hive/hive.dart';

part 'invoice_model.g.dart';

@HiveType(typeId: 0)
enum InvoiceType {
  @HiveField(0)
  medical,
  @HiveField(1)
  goods,
  @HiveField(2)
  service,
  @HiveField(3)
  other,
}

@HiveType(typeId: 1)
enum RiskLevel {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
}

@HiveType(typeId: 2)
class InvoiceModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fileName;

  @HiveField(2)
  final String? filePath;

  @HiveField(3)
  final DateTime uploadedAt;

  @HiveField(4)
  final InvoiceType type;

  @HiveField(5)
  final RiskLevel riskLevel;

  @HiveField(6)
  final String vendor;

  @HiveField(7)
  final DateTime invoiceDate;

  @HiveField(8)
  final double amount;

  @HiveField(9)
  final double tax;

  @HiveField(10)
  final bool isProcessed;

  @HiveField(11)
  final String? notes;

  InvoiceModel({
    required this.id,
    required this.fileName,
    this.filePath,
    required this.uploadedAt,
    required this.type,
    required this.riskLevel,
    required this.vendor,
    required this.invoiceDate,
    required this.amount,
    required this.tax,
    this.isProcessed = false,
    this.notes,
  });

  double get totalAmount => amount + tax;

  InvoiceModel copyWith({
    String? id,
    String? fileName,
    String? filePath,
    DateTime? uploadedAt,
    InvoiceType? type,
    RiskLevel? riskLevel,
    String? vendor,
    DateTime? invoiceDate,
    double? amount,
    double? tax,
    bool? isProcessed,
    String? notes,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      type: type ?? this.type,
      riskLevel: riskLevel ?? this.riskLevel,
      vendor: vendor ?? this.vendor,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      amount: amount ?? this.amount,
      tax: tax ?? this.tax,
      isProcessed: isProcessed ?? this.isProcessed,
      notes: notes ?? this.notes,
    );
  }
}