import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../invoice/providers/invoice_provider.dart';
import '../../invoice/models/invoice_model.dart';
import '../../../core/theme/app_theme.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('History & Reports'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'History'),
            Tab(text: 'Reports'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _HistoryTab(),
          _ReportsTab(),
        ],
      ),
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(invoiceProvider);

    // Debug: Print invoice count and details
    print('📋 History Tab - Total invoices: ${invoices.length}');
    for (var invoice in invoices) {
      print('  - ${invoice.fileName} (${invoice.vendor}) - ${invoice.uploadedAt}');
    }

    if (invoices.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No invoices yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    // Sort invoices by upload date - most recent first
    final sortedInvoices = List<InvoiceModel>.from(invoices)
      ..sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedInvoices.length,
      itemBuilder: (context, index) {
        final invoice = sortedInvoices[index];
        return _InvoiceListItem(invoice: invoice);
      },
    );
  }
}

class _InvoiceListItem extends StatelessWidget {
  final InvoiceModel invoice;

  const _InvoiceListItem({required this.invoice});

  Color _getRiskColor() {
    switch (invoice.riskLevel) {
      case RiskLevel.low:
        return AppTheme.lowRisk;
      case RiskLevel.medium:
        return AppTheme.mediumRisk;
      case RiskLevel.high:
        return AppTheme.highRisk;
    }
  }

  String _getRiskLabel() {
    return invoice.riskLevel.name.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        isThreeLine: true,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 8,
          height: double.infinity,
          decoration: BoxDecoration(
            color: _getRiskColor(),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          invoice.vendor,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              invoice.fileName,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM dd, yyyy').format(invoice.uploadedAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${invoice.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getRiskColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getRiskLabel(),
                style: TextStyle(
                  color: _getRiskColor(),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          context.push('/invoice/${invoice.id}');
        },
      ),
    );
  }
}

class _ReportsTab extends ConsumerWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoices = ref.watch(invoiceProvider);

    if (invoices.isEmpty) {
      return const Center(
        child: Text('No data available for reports'),
      );
    }

    // Calculate data for charts
    final typeData = _calculateTypeDistribution(invoices);
    final riskData = _calculateRiskDistribution(invoices);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invoice Type Distribution',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: typeData,
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Risk Level Distribution',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: riskData.values.reduce((a, b) => a > b ? a : b) + 1,
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(
                            toY: riskData['low']!.toDouble(),
                            color: AppTheme.lowRisk,
                            width: 40,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(
                            toY: riskData['medium']!.toDouble(),
                            color: AppTheme.mediumRisk,
                            width: 40,
                          ),
                        ],
                      ),
                      BarChartGroupData(
                        x: 2,
                        barRods: [
                          BarChartRodData(
                            toY: riskData['high']!.toDouble(),
                            color: AppTheme.highRisk,
                            width: 40,
                          ),
                        ],
                      ),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            switch (value.toInt()) {
                              case 0:
                                return const Text('Low');
                              case 1:
                                return const Text('Medium');
                              case 2:
                                return const Text('High');
                              default:
                                return const Text('');
                            }
                          },
                        ),
                      ),
                    ),
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _SummaryCard(invoices: invoices),
        ],
      ),
    );
  }

  List<PieChartSectionData> _calculateTypeDistribution(
      List<InvoiceModel> invoices) {
    final Map<InvoiceType, int> typeCounts = {};
    for (final invoice in invoices) {
      typeCounts[invoice.type] = (typeCounts[invoice.type] ?? 0) + 1;
    }

    final colors = {
      InvoiceType.medical: Colors.blue,
      InvoiceType.goods: Colors.green,
      InvoiceType.service: Colors.orange,
      InvoiceType.other: Colors.grey,
    };

    return typeCounts.entries.map((entry) {
      final percentage = (entry.value / invoices.length * 100).toStringAsFixed(1);
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${entry.key.name}\n$percentage%',
        color: colors[entry.key],
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Map<String, int> _calculateRiskDistribution(List<InvoiceModel> invoices) {
    int low = 0, medium = 0, high = 0;
    for (final invoice in invoices) {
      switch (invoice.riskLevel) {
        case RiskLevel.low:
          low++;
          break;
        case RiskLevel.medium:
          medium++;
          break;
        case RiskLevel.high:
          high++;
          break;
      }
    }
    return {'low': low, 'medium': medium, 'high': high};
  }
}

class _SummaryCard extends StatelessWidget {
  final List<InvoiceModel> invoices;

  const _SummaryCard({required this.invoices});

  @override
  Widget build(BuildContext context) {
    final totalAmount = invoices.fold<double>(
      0,
      (sum, invoice) => sum + invoice.totalAmount,
    );
    final avgAmount = totalAmount / invoices.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _SummaryRow('Total Invoices:', '${invoices.length}'),
            _SummaryRow('Total Amount:', '\$${totalAmount.toStringAsFixed(2)}'),
            _SummaryRow('Average Amount:', '\$${avgAmount.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}