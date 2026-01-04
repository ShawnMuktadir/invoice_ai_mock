import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/providers/auth_provider.dart';
import '../../invoice/providers/invoice_provider.dart';
import '../../invoice/services/file_picker_service.dart';
import '../widgets/status_card.dart';
import '../widgets/token_meter.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final totalInvoices = ref.watch(totalInvoicesProvider);
    final dailyProcessed = ref.watch(dailyProcessedProvider);
    final flaggedCount = ref.watch(flaggedInvoicesProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${user.name}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Here\'s your invoice overview',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: AppTheme.primaryIndigo.withOpacity(0.1),
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: AppTheme.primaryIndigo,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Token Meter
              TokenMeter(
                remainingTokens: user.remainingTokens,
                totalTokens: user.totalTokens,
              ),
              const SizedBox(height: 24),

              // Status Cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  StatusCard(
                    title: 'Total Invoices',
                    value: totalInvoices.toString(),
                    icon: Icons.receipt_long,
                    color: AppTheme.primaryIndigo,
                  ),
                  StatusCard(
                    title: 'Daily Processed',
                    value: dailyProcessed.toString(),
                    icon: Icons.today,
                    color: AppTheme.completed,
                  ),
                  StatusCard(
                    title: 'Flagged (Risk)',
                    value: flaggedCount.toString(),
                    icon: Icons.warning_amber_rounded,
                    color: AppTheme.highRisk,
                  ),
                  StatusCard(
                    title: 'Processing',
                    value: '0',
                    icon: Icons.autorenew,
                    color: AppTheme.processing,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Upload New Invoice Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => _showFilePickerDialog(context, ref),
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  label: const Text(
                    'Upload New Invoice',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryIndigo,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // View History Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.go('/history');
                  },
                  icon: Icon(Icons.history, color: AppTheme.primaryIndigo),
                  label: Text(
                    'View History',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryIndigo,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.primaryIndigo),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Recent Activity
              if (flaggedCount > 0) ...[
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: AppTheme.highRisk, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Attention Required',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.highRisk,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.highRisk.withOpacity(0.1),
                      child: Icon(Icons.flag, color: AppTheme.highRisk, size: 20),
                    ),
                    title: Text(
                      '$flaggedCount invoice${flaggedCount > 1 ? 's' : ''} flagged for review',
                    ),
                    subtitle: const Text('High risk detected'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.go('/history');
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Helper function to show file picker dialog
Future<void> _showFilePickerDialog(BuildContext context, WidgetRef ref) async {
  final filePickerService = FilePickerService();

  // Capture the parent context before showing bottom sheet
  final parentContext = context;

  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload Invoice',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how you want to upload your invoice',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppTheme.primaryIndigo,
                child: Icon(Icons.camera_alt, color: Colors.white),
              ),
              title: const Text('Take Photo'),
              subtitle: const Text('Use your camera'),
              onTap: () async {
                Navigator.pop(context);
                await _handleFilePick(parentContext, ref, filePickerService, FileSource.camera);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppTheme.primaryIndigo,
                child: Icon(Icons.photo_library, color: Colors.white),
              ),
              title: const Text('Choose from Gallery'),
              subtitle: const Text('Select an image'),
              onTap: () async {
                Navigator.pop(context);
                await _handleFilePick(parentContext, ref, filePickerService, FileSource.gallery);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppTheme.primaryIndigo,
                child: Icon(Icons.folder_open, color: Colors.white),
              ),
              title: const Text('Browse Files'),
              subtitle: const Text('PDF or image files'),
              onTap: () async {
                Navigator.pop(context);
                await _handleFilePick(parentContext, ref, filePickerService, FileSource.files);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

// Helper function to handle file picking
Future<void> _handleFilePick(
  BuildContext context,
  WidgetRef ref,
  FilePickerService filePickerService,
  FileSource source,
) async {
  PickedFileInfo? pickedFile;

  try {
    print('📁 Starting file pick from source: $source');

    // Pick file with timeout (30 seconds)
    pickedFile = await filePickerService.pickInvoiceFile(source).timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        print('⏱️ File selection timed out');
        throw Exception('File selection timed out. Please try again.');
      },
    );

    print('📄 File picked: ${pickedFile?.name ?? "null (user cancelled)"}');

    if (pickedFile == null) {
      // User cancelled - no error needed
      print('❌ User cancelled file selection');
      return;
    }

    print('✓ File info - Name: ${pickedFile.name}, Size: ${pickedFile.sizeInMB} MB, Valid: ${pickedFile.isValid}');

    // Validate file
    if (!pickedFile.isValid) {
      print('❌ Invalid file type: ${pickedFile.extension}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid file type: ${pickedFile.extension.toUpperCase()}. Please select PDF or image file.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // Wait briefly for context to remount after returning from native file picker
    await Future.delayed(const Duration(milliseconds: 100));

    // Show file preview and confirmation
    print('📋 Showing file preview dialog');
    if (!context.mounted) {
      print('❌ Context not mounted after delay, retrying...');
      // Wait a bit longer and try again
      await Future.delayed(const Duration(milliseconds: 200));
      if (!context.mounted) {
        print('❌ Context still not mounted - aborting');
        return;
      }
    }

    final confirmed = await _showFilePreviewDialog(context, pickedFile);
    print('✓ Preview dialog result: $confirmed');

    if (confirmed != true) {
      print('❌ User cancelled from preview dialog');
      return;
    }

    print('⏳ Creating invoice');

    // Create invoice with file info
    final newInvoice = await ref.read(invoiceProvider.notifier).addInvoice(
          pickedFile.name,
          filePath: pickedFile.path,
        );

    print('✓ Invoice created: ${newInvoice.id}');
    print('🚀 Navigating to processing screen');

    // Navigate to processing screen - this will automatically close any dialogs
    if (context.mounted) {
      context.push('/processing/${newInvoice.id}/${pickedFile.name}');
      print('✓ Navigation successful');
    } else {
      print('❌ Context not mounted for navigation');
    }
  } catch (e, stackTrace) {
    print('❌ ERROR in file pick: $e');
    print('Stack trace: $stackTrace');

    // Close loading if still showing - check if we can pop
    if (context.mounted && Navigator.canPop(context)) {
      try {
        Navigator.pop(context);
        print('✓ Closed loading dialog after error');
      } catch (popError) {
        print('⚠️ Could not close loading dialog: $popError');
      }
    }

    // Show error
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } else {
      print('❌ Context not mounted - cannot show error to user');
    }
  }
}

// Helper function to show file preview dialog
Future<bool?> _showFilePreviewDialog(
  BuildContext context,
  PickedFileInfo fileInfo,
) async {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm Upload'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                fileInfo.isPdf ? Icons.picture_as_pdf : Icons.image,
                size: 48,
                color: AppTheme.primaryIndigo,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileInfo.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${fileInfo.sizeInMB} MB • ${fileInfo.extension.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'This invoice will be processed using AI to extract information.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryIndigo,
          ),
          child: const Text('Process Invoice'),
        ),
      ],
    ),
  );
}