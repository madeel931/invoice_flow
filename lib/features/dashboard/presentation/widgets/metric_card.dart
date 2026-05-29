import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';

class _MetricDisplayEntry {
  final String text;
  final bool isMore;

  _MetricDisplayEntry({required this.text, this.isMore = false});
}

class MetricCard extends StatelessWidget {
  final String title;
  final String breakdownTitle;
  final Map<String, double> amounts;
  final String fallbackCurrency;
  final IconData icon;
  final List<Color> gradientColors;

  const MetricCard({
    super.key,
    required this.title,
    required this.breakdownTitle,
    required this.amounts,
    required this.fallbackCurrency,
    required this.icon,
    required this.gradientColors,
  });

  List<_MetricDisplayEntry> _getDisplayEntries() {
    if (amounts.isEmpty) {
      return [
        _MetricDisplayEntry(
          text: AppFormatters.formatCurrencyCompact(0.0, fallbackCurrency),
        )
      ];
    }

    if (amounts.length == 1) {
      final entry = amounts.entries.first;
      return [
        _MetricDisplayEntry(
          text: AppFormatters.formatCurrencyCompact(entry.value, entry.key),
        )
      ];
    }

    final sorted = _sortCurrencyEntries(amounts);

    if (amounts.length <= 3) {
      return sorted
          .map((entry) => _MetricDisplayEntry(
                text: AppFormatters.formatCurrencyCompact(entry.value, entry.key),
              ))
          .toList();
    } else {
      // More than 3: show top 2 and "+N more"
      final top2 = sorted.take(2).map((entry) => _MetricDisplayEntry(
            text: AppFormatters.formatCurrencyCompact(entry.value, entry.key),
          )).toList();
      top2.add(_MetricDisplayEntry(
        text: '+${amounts.length - 2} more',
        isMore: true,
      ));
      return top2;
    }
  }

  List<MapEntry<String, double>> _sortCurrencyEntries(Map<String, double> amounts) {
    final entries = amounts.entries.toList();
    entries.sort((a, b) {
      // Deterministic sort: highest amount first, alphabetical by currency code on tie
      int cmp = b.value.compareTo(a.value);
      if (cmp != 0) return cmp;
      return a.key.compareTo(b.key);
    });
    return entries;
  }

  void _showBreakdownBottomSheet(BuildContext context) {
    final entries = _sortCurrencyEntries(amounts);
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Premium Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  breakdownTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: entries.length,
                    separatorBuilder: (context, index) => Divider(
                      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left side: Currency Code
                            Text(
                              entry.key,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            // Right side: Formatted Full Amount
                            Text(
                              AppFormatters.formatCurrency(entry.value, entry.key),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasBreakdown = amounts.length > 1;

    // Build metric text representation
    final displayEntries = _getDisplayEntries();
    final summaryText = displayEntries.map((e) => e.text).join('\n');

    Widget cardContent = Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Row(
                children: [
                  if (hasBreakdown) ...[
                    const Icon(
                      Icons.info_outline,
                      color: Colors.white54,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Icon(icon, color: Colors.white70, size: 24),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            summaryText,
            style: TextStyle(
              color: Colors.white,
              fontSize: summaryText.contains('\n') ? 20 : 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: hasBreakdown ? () => _showBreakdownBottomSheet(context) : null,
            splashColor: Colors.white.withValues(alpha: 0.15),
            highlightColor: Colors.white.withValues(alpha: 0.05),
            child: cardContent,
          ),
        ),
      ),
    );
  }
}
