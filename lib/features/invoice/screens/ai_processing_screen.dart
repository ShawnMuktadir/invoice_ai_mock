import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/ai_step_model.dart';
import '../providers/ai_processing_provider.dart';
import '../../../core/theme/app_theme.dart';

class AIProcessingScreen extends ConsumerStatefulWidget {
  final String invoiceId;
  final String fileName;

  const AIProcessingScreen({
    super.key,
    required this.invoiceId,
    required this.fileName,
  });

  @override
  ConsumerState<AIProcessingScreen> createState() =>
      _AIProcessingScreenState();
}

class _AIProcessingScreenState extends ConsumerState<AIProcessingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    // Start processing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aiProcessingProvider.notifier).startProcessing(widget.invoiceId);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = ref.watch(aiProcessingProvider);
    final allCompleted = steps.every((step) => step.status == StepStatus.completed);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('AI Processing'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryIndigo.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              allCompleted ? Icons.check_circle : Icons.auto_awesome,
                              size: 40,
                              color: allCompleted
                                  ? AppTheme.completed
                                  : AppTheme.primaryIndigo,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            allCompleted ? 'Processing Complete!' : 'Processing Invoice',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.fileName,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Steps
                    ...steps.asMap().entries.map((entry) {
                      final index = entry.key;
                      final step = entry.value;
                      final isLast = index == steps.length - 1;
                      return _StepItem(
                        step: step,
                        isLast: isLast,
                        animationController: _animationController,
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Bottom Button
            if (allCompleted)
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // Reset processing state
                      ref.read(aiProcessingProvider.notifier).reset();

                      // Navigate to invoice detail screen to show results
                      context.go('/invoice/${widget.invoiceId}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryIndigo,
                    ),
                    child: const Text(
                      'View Results',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final AIStepModel step;
  final bool isLast;
  final AnimationController animationController;

  const _StepItem({
    required this.step,
    required this.isLast,
    required this.animationController,
  });

  Color _getStatusColor() {
    switch (step.status) {
      case StepStatus.pending:
        return AppTheme.pending;
      case StepStatus.processing:
        return AppTheme.processing;
      case StepStatus.completed:
        return AppTheme.completed;
      case StepStatus.failed:
        return AppTheme.failed;
    }
  }

  IconData _getStatusIcon() {
    switch (step.status) {
      case StepStatus.pending:
        return Icons.circle_outlined;
      case StepStatus.processing:
        return Icons.autorenew;
      case StepStatus.completed:
        return Icons.check_circle;
      case StepStatus.failed:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final isProcessing = step.status == StepStatus.processing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon column
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: 2,
                ),
              ),
              child: isProcessing
                  ? RotationTransition(
                      turns: animationController,
                      child: Icon(_getStatusIcon(), color: color, size: 24),
                    )
                  : Icon(_getStatusIcon(), color: color, size: 24),
            ),
            if (!isLast)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 2,
                height: 60,
                color: step.status == StepStatus.completed
                    ? AppTheme.completed
                    : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 16),

        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        step.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: step.status == StepStatus.pending
                                  ? Colors.grey[600]
                                  : Colors.black87,
                            ),
                      ),
                    ),
                    if (isProcessing)
                      ScaleTransition(
                        scale: Tween<double>(begin: 1.0, end: 1.2).animate(
                          CurvedAnimation(
                            parent: animationController,
                            curve: Curves.easeInOut,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.processing.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Processing...',
                            style: TextStyle(
                              color: AppTheme.processing,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  step.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                if (step.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.failed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      step.errorMessage!,
                      style: const TextStyle(
                        color: AppTheme.failed,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}