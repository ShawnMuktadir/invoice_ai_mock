import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TokenMeter extends StatelessWidget {
  final int remainingTokens;
  final int totalTokens;

  const TokenMeter({
    super.key,
    required this.remainingTokens,
    required this.totalTokens,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = remainingTokens / totalTokens;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Free Tokens',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getTokenColor(percentage).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$remainingTokens / $totalTokens',
                    style: TextStyle(
                      color: _getTokenColor(percentage),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 12,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getTokenColor(percentage),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getTokenMessage(percentage),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTokenColor(double percentage) {
    if (percentage > 0.5) {
      return AppTheme.completed;
    } else if (percentage > 0.2) {
      return AppTheme.mediumRisk;
    } else {
      return AppTheme.highRisk;
    }
  }

  String _getTokenMessage(double percentage) {
    if (percentage > 0.5) {
      return 'You have plenty of tokens remaining';
    } else if (percentage > 0.2) {
      return 'Consider upgrading for more tokens';
    } else {
      return 'Running low on tokens!';
    }
  }
}