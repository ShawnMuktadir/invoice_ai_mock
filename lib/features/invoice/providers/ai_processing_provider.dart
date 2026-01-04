import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ai_step_model.dart';
import '../models/invoice_model.dart';
import 'invoice_provider.dart';
import '../../../core/constants/app_constants.dart';

class AIProcessingNotifier extends StateNotifier<List<AIStepModel>> {
  final Ref ref;
  bool _isProcessing = false;

  AIProcessingNotifier(this.ref) : super(AIStepModel.getDefaultSteps());

  bool get isProcessing => _isProcessing;

  Future<void> startProcessing(String invoiceId) async {
    if (_isProcessing) return;

    _isProcessing = true;

    // Reset all steps to pending
    state = AIStepModel.getDefaultSteps();

    // Process each step with animation delay
    for (int i = 0; i < state.length; i++) {
      // Mark current step as processing
      state = [
        for (int j = 0; j < state.length; j++)
          if (j == i)
            state[j].copyWith(status: StepStatus.processing)
          else
            state[j],
      ];

      // Wait for step to complete
      await Future.delayed(
        Duration(milliseconds: AppConstants.stepAnimationDurationMs),
      );

      // Mark current step as completed
      state = [
        for (int j = 0; j < state.length; j++)
          if (j == i)
            state[j].copyWith(status: StepStatus.completed)
          else
            state[j],
      ];

      // Delay before next step
      await Future.delayed(
        Duration(milliseconds: AppConstants.stepDelayMs),
      );
    }

    // Processing complete - update invoice with mock data
    await _updateInvoiceAfterProcessing(invoiceId);

    _isProcessing = false;
  }

  Future<void> _updateInvoiceAfterProcessing(String invoiceId) async {
    final invoices = ref.read(invoiceProvider);
    final invoice = invoices.firstWhere((inv) => inv.id == invoiceId);

    // Generate realistic mock data based on filename
    final intelligentData = _generateIntelligentMockData(invoice.fileName);

    final updatedInvoice = invoice.copyWith(
      type: intelligentData.type,
      riskLevel: intelligentData.riskLevel,
      vendor: intelligentData.vendor,
      amount: intelligentData.amount,
      tax: intelligentData.tax,
      invoiceDate: intelligentData.invoiceDate,
      notes: intelligentData.notes,
      isProcessed: true,
    );

    await ref.read(invoiceProvider.notifier).updateInvoice(updatedInvoice);
  }

  _IntelligentMockData _generateIntelligentMockData(String fileName) {
    final random = Random();
    final now = DateTime.now();
    final lowerFileName = fileName.toLowerCase();

    // Detect invoice type from filename
    InvoiceType type;
    List<String> possibleVendors;
    double baseAmount;

    if (lowerFileName.contains('medical') ||
        lowerFileName.contains('hospital') ||
        lowerFileName.contains('doctor') ||
        lowerFileName.contains('pharmacy') ||
        lowerFileName.contains('clinic')) {
      type = InvoiceType.medical;
      possibleVendors = [
        'City General Hospital',
        'MediCare Clinic',
        'HealthPlus Pharmacy',
        'St. Mary\'s Medical Center',
        'Quick Care Urgent Care',
      ];
      baseAmount = 200 + random.nextDouble() * 2000; // $200 - $2200
    } else if (lowerFileName.contains('goods') ||
        lowerFileName.contains('product') ||
        lowerFileName.contains('purchase') ||
        lowerFileName.contains('equipment') ||
        lowerFileName.contains('supply')) {
      type = InvoiceType.goods;
      possibleVendors = [
        'Tech Supplies Inc',
        'Office Depot',
        'Global Equipment Co',
        'Prime Goods Wholesale',
        'Quality Products Ltd',
      ];
      baseAmount = 150 + random.nextDouble() * 1800; // $150 - $1950
    } else if (lowerFileName.contains('service') ||
        lowerFileName.contains('maintenance') ||
        lowerFileName.contains('consulting') ||
        lowerFileName.contains('repair') ||
        lowerFileName.contains('clean')) {
      type = InvoiceType.service;
      possibleVendors = [
        'Clean Pro Services',
        'Tech Support LLC',
        'Maintenance Masters',
        'Professional Consulting Group',
        'Expert Repairs Inc',
      ];
      baseAmount = 100 + random.nextDouble() * 900; // $100 - $1000
    } else {
      // Default to other and pick random
      type = InvoiceType.other;
      possibleVendors = [
        'General Vendors Inc',
        'Business Services Co',
        'Various Supplies Ltd',
        'Standard Invoice Corp',
        'Miscellaneous Services',
      ];
      baseAmount = 100 + random.nextDouble() * 1500; // $100 - $1600
    }

    // Select vendor
    final vendor = possibleVendors[random.nextInt(possibleVendors.length)];

    // Calculate amount and tax (15% tax rate)
    final amount = double.parse(baseAmount.toStringAsFixed(2));
    final tax = double.parse((amount * 0.15).toStringAsFixed(2));

    // Generate invoice date (1-30 days ago)
    final daysAgo = random.nextInt(30) + 1;
    final invoiceDate = now.subtract(Duration(days: daysAgo));

    // Determine risk level (weighted toward low risk)
    RiskLevel riskLevel;
    String? notes;
    final riskRoll = random.nextInt(100);

    if (riskRoll < 70) {
      // 70% low risk
      riskLevel = RiskLevel.low;
    } else if (riskRoll < 90) {
      // 20% medium risk
      riskLevel = RiskLevel.medium;
      notes = 'Flagged: Amount slightly above vendor average';
    } else {
      // 10% high risk
      riskLevel = RiskLevel.high;
      final reasons = [
        'Unusual amount for this vendor',
        'Multiple invoices from same vendor in short period',
        'Invoice number sequence appears irregular',
        'Tax calculation discrepancy detected',
      ];
      notes = 'Flagged: ${reasons[random.nextInt(reasons.length)]}';
    }

    return _IntelligentMockData(
      type: type,
      vendor: vendor,
      amount: amount,
      tax: tax,
      riskLevel: riskLevel,
      invoiceDate: invoiceDate,
      notes: notes,
    );
  }

  void reset() {
    state = AIStepModel.getDefaultSteps();
    _isProcessing = false;
  }
}

final aiProcessingProvider =
    StateNotifierProvider<AIProcessingNotifier, List<AIStepModel>>((ref) {
  return AIProcessingNotifier(ref);
});

// Helper class for intelligent mock data
class _IntelligentMockData {
  final InvoiceType type;
  final String vendor;
  final double amount;
  final double tax;
  final RiskLevel riskLevel;
  final DateTime invoiceDate;
  final String? notes;

  _IntelligentMockData({
    required this.type,
    required this.vendor,
    required this.amount,
    required this.tax,
    required this.riskLevel,
    required this.invoiceDate,
    this.notes,
  });
}