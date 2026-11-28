import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/receipts_controller.dart';
import '../../application/stats_controller.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/money.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/aurora_background.dart';
import '../theme/frosted_tile.dart';
import '../theme/glass_panel.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  int? _touchedIndex;

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _selectedMonth.year == now.year && _selectedMonth.month == now.month;
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    if (_isCurrentMonth) return; // Cannot navigate past current month
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    const currency = 'KRW';
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = Localizations.localeOf(context).languageCode;
    final categoryTotalsAsync = ref.watch(categoryTotalsProvider((_selectedMonth, currency)));
    final monthlyTotalsAsync = ref.watch(monthlyTotalsProvider(currency));
    final categoriesAsync = ref.watch(categoriesProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    final categoriesMap = <String, Category>{};
    categoriesAsync.whenData((cats) {
      for (final c in cats) {
        categoriesMap[c.key] = c;
      }
    });

    return AuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(l10n.statsTitle),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Month Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  key: const Key('prev_month_button'),
                  icon: Icon(Icons.chevron_left_rounded, color: onSurface),
                  onPressed: _previousMonth,
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_selectedMonth),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onSurface),
                ),
                IconButton(
                  key: const Key('next_month_button'),
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    color: _isCurrentMonth ? onSurface.withValues(alpha: 0.30) : onSurface,
                  ),
                  onPressed: _isCurrentMonth ? null : _nextMonth,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Donut Chart Card (GlassPanel)
            categoryTotalsAsync.when(
              loading: () => const GlassPanel(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (e, _) => GlassPanel(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text('Error: $e', style: TextStyle(color: onSurface))),
                ),
              ),
              data: (totals) {
                final hasData = totals.isNotEmpty && totals.any((t) => t.totalMinor > 0);
                if (!hasData) {
                  return GlassPanel(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          l10n.noReceiptsMonth,
                          style: TextStyle(fontSize: 16, color: onSurface.withValues(alpha: 0.60)),
                        ),
                      ),
                    ),
                  );
                }

                final totalSum = totals.fold(0, (sum, t) => sum + t.totalMinor);
                final percents = calculatePercents(totals.map((t) => t.totalMinor).toList());
                final summaryText = totals
                    .map((t) => '${_getLocalizedCategoryName(l10n, t.categoryKey)}: ${Money(t.totalMinor, currency: currency).format(currentLocale)}')
                    .join(', ');

                return Semantics(
                  label: 'Category spending for ${DateFormat('MMMM yyyy').format(_selectedMonth)}: $summaryText',
                  child: GlassPanel(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.category, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: onSurface)),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 220,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                PieChart(
                                  PieChartData(
                                    pieTouchData: PieTouchData(
                                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                        setState(() {
                                          if (!event.isInterestedForInteractions || pieTouchResponse == null || pieTouchResponse.touchedSection == null) {
                                            _touchedIndex = null;
                                            return;
                                          }
                                          _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                        });
                                      },
                                    ),
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 60,
                                    sections: totals.asMap().entries.map((entry) {
                                      final idx = entry.key;
                                      final t = entry.value;
                                      final isTouched = idx == _touchedIndex;
                                      final radius = isTouched ? 45.0 : 38.0;
                                      final pct = percents[idx];

                                      return PieChartSectionData(
                                        color: Color(t.colorValue),
                                        value: t.totalMinor.toDouble(),
                                        title: '${pct.toStringAsFixed(0)}%',
                                        radius: radius,
                                        titleStyle: TextStyle(
                                          fontSize: isTouched ? 16 : 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      Money(totalSum, currency: currency).format(currentLocale),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: onSurface,
                                        fontFeatures: const [FontFeature.tabularFigures()],
                                      ),
                                    ),
                                    Text(
                                      l10n.total,
                                      style: TextStyle(fontSize: 12, color: onSurface.withValues(alpha: 0.60)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...totals.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final t = entry.value;
                            final isTouched = idx == _touchedIndex;
                            final pct = percents[idx];
                            final catName = _getLocalizedCategoryName(l10n, t.categoryKey);

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _touchedIndex = _touchedIndex == idx ? null : idx;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: isTouched ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: Color(t.colorValue))),
                                        const SizedBox(width: 8),
                                        Text(
                                          catName,
                                          style: TextStyle(
                                            color: onSurface,
                                            fontWeight: isTouched ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${Money(t.totalMinor, currency: currency).format(currentLocale)} (${pct.toStringAsFixed(1)}%)',
                                      style: TextStyle(
                                        color: onSurface,
                                        fontWeight: isTouched ? FontWeight.bold : FontWeight.w500,
                                        fontFeatures: const [FontFeature.tabularFigures()],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Bar Chart Card (FrostedTile)
            monthlyTotalsAsync.when(
              loading: () => const FrostedTile(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (e, _) => FrostedTile(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text('Error: $e', style: TextStyle(color: onSurface))),
                ),
              ),
              data: (monthTotals) {
                if (monthTotals.isEmpty) {
                  return const SizedBox.shrink();
                }

                final maxVal = monthTotals.map((m) => m.totalMinor).reduce((a, b) => a > b ? a : b).toDouble();
                final summaryText = monthTotals
                    .map((m) => '${m.month}: ${abbreviateAmount(m.totalMinor, currency, currentLocale)}')
                    .join(', ');

                return Semantics(
                  label: 'Last 6 months spending: $summaryText',
                  child: FrostedTile(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.lastSixMonths, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: onSurface)),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: maxVal > 0 ? maxVal * 1.25 : 100,
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final index = value.toInt();
                                        if (index >= 0 && index < monthTotals.length) {
                                          final parts = monthTotals[index].month.split('-');
                                          final monthNum = int.tryParse(parts[1]) ?? 1;
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 6.0),
                                            child: Text(
                                              currentLocale.startsWith('ko') ? '$monthNum월' : DateFormat('MMM').format(DateTime(2025, monthNum, 1)),
                                              style: TextStyle(fontSize: 12, color: onSurface),
                                            ),
                                          );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                gridData: const FlGridData(show: false),
                                borderData: FlBorderData(show: false),
                                barGroups: monthTotals.asMap().entries.map((entry) {
                                  final idx = entry.key;
                                  final m = entry.value;
                                  final isCurrent = m.month == DateFormat('yyyy-MM').format(_selectedMonth);

                                  return BarChartGroupData(
                                    x: idx,
                                    showingTooltipIndicators: m.totalMinor > 0 ? [0] : [],
                                    barRods: [
                                      BarChartRodData(
                                        toY: m.totalMinor.toDouble(),
                                        color: isCurrent ? Theme.of(context).colorScheme.primary : AppColors.iris.withValues(alpha: 0.60),
                                        width: 20,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ],
                                  );
                                }).toList(),
                                barTouchData: BarTouchData(
                                  enabled: false,
                                  touchTooltipData: BarTouchTooltipData(
                                    getTooltipColor: (_) => Colors.transparent,
                                    tooltipPadding: EdgeInsets.zero,
                                    tooltipMargin: 4,
                                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                      final m = monthTotals[group.x];
                                      if (m.totalMinor == 0) return null;
                                      return BarTooltipItem(
                                        abbreviateAmount(m.totalMinor, currency, currentLocale),
                                        TextStyle(
                                          color: onSurface.withValues(alpha: 0.80),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedCategoryName(AppLocalizations l10n, String key) {
    switch (key) {
      case 'food': return l10n.category_food;
      case 'groceries': return l10n.category_groceries;
      case 'transport': return l10n.category_transport;
      case 'shopping': return l10n.category_shopping;
      case 'health': return l10n.category_health;
      case 'entertainment': return l10n.category_entertainment;
      case 'utilities': return l10n.category_utilities;
      default: return l10n.category_other;
    }
  }
}
