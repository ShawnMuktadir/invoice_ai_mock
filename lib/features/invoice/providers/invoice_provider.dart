import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/invoice_model.dart';

class InvoiceNotifier extends StateNotifier<List<InvoiceModel>> {
  late Box<InvoiceModel> _invoiceBox;

  InvoiceNotifier() : super([]) {
    _initialize();
  }

  void _initialize() {
    _invoiceBox = Hive.box<InvoiceModel>('invoices');
    // Load all invoices from Hive
    state = _invoiceBox.values.toList();

    // If no invoices exist, add mock data for demo purposes
    if (state.isEmpty) {
      _addMockInvoices();
    }
  }

  void _addMockInvoices() {
    final uuid = const Uuid();
    final now = DateTime.now();

    final mockInvoices = [
      InvoiceModel(
        id: uuid.v4(),
        fileName: 'medical_invoice_001.pdf',
        uploadedAt: now.subtract(const Duration(days: 2)),
        type: InvoiceType.medical,
        riskLevel: RiskLevel.low,
        vendor: 'City Hospital',
        invoiceDate: now.subtract(const Duration(days: 3)),
        amount: 850.00,
        tax: 127.50,
        isProcessed: true,
      ),
      InvoiceModel(
        id: uuid.v4(),
        fileName: 'goods_invoice_045.pdf',
        uploadedAt: now.subtract(const Duration(days: 5)),
        type: InvoiceType.goods,
        riskLevel: RiskLevel.high,
        vendor: 'Tech Supplies Inc',
        invoiceDate: now.subtract(const Duration(days: 6)),
        amount: 2450.00,
        tax: 367.50,
        isProcessed: true,
        notes: 'Flagged: Unusual amount for this vendor',
      ),
      InvoiceModel(
        id: uuid.v4(),
        fileName: 'service_invoice_032.pdf',
        uploadedAt: now.subtract(const Duration(days: 8)),
        type: InvoiceType.service,
        riskLevel: RiskLevel.low,
        vendor: 'Clean Pro Services',
        invoiceDate: now.subtract(const Duration(days: 9)),
        amount: 320.00,
        tax: 48.00,
        isProcessed: true,
      ),
    ];

    for (final invoice in mockInvoices) {
      _invoiceBox.put(invoice.id, invoice);
    }
    state = _invoiceBox.values.toList();
  }

  Future<InvoiceModel> addInvoice(String fileName, {String? filePath}) async {
    final uuid = const Uuid();
    final newInvoice = InvoiceModel(
      id: uuid.v4(),
      fileName: fileName,
      filePath: filePath,
      uploadedAt: DateTime.now(),
      type: InvoiceType.other,
      riskLevel: RiskLevel.low,
      vendor: 'Processing...',
      invoiceDate: DateTime.now(),
      amount: 0.0,
      tax: 0.0,
      isProcessed: false,
    );

    // Save to Hive
    await _invoiceBox.put(newInvoice.id, newInvoice);

    // Update state
    state = [...state, newInvoice];
    return newInvoice;
  }

  Future<void> updateInvoice(InvoiceModel updatedInvoice) async {
    // Save to Hive
    await _invoiceBox.put(updatedInvoice.id, updatedInvoice);

    // Update state
    state = [
      for (final invoice in state)
        if (invoice.id == updatedInvoice.id) updatedInvoice else invoice,
    ];
  }

  Future<void> deleteInvoice(String id) async {
    // Delete from Hive
    await _invoiceBox.delete(id);

    // Update state
    state = state.where((invoice) => invoice.id != id).toList();
  }
}

final invoiceProvider = StateNotifierProvider<InvoiceNotifier, List<InvoiceModel>>((ref) {
  return InvoiceNotifier();
});

// Computed providers
final totalInvoicesProvider = Provider<int>((ref) {
  return ref.watch(invoiceProvider).length;
});

final dailyProcessedProvider = Provider<int>((ref) {
  final invoices = ref.watch(invoiceProvider);
  final today = DateTime.now();
  return invoices.where((invoice) {
    return invoice.uploadedAt.year == today.year &&
        invoice.uploadedAt.month == today.month &&
        invoice.uploadedAt.day == today.day;
  }).length;
});

final flaggedInvoicesProvider = Provider<int>((ref) {
  final invoices = ref.watch(invoiceProvider);
  return invoices.where((invoice) => invoice.riskLevel == RiskLevel.high).length;
});

final flaggedInvoicesListProvider = Provider<List<InvoiceModel>>((ref) {
  final invoices = ref.watch(invoiceProvider);
  return invoices.where((invoice) => invoice.riskLevel == RiskLevel.high).toList();
});