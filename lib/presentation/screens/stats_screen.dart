import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/stats_controller.dart';
import '../../domain/entities/money.dart';
import '../../l10n/app_localizations.dart';
<<<<<<< HEAD
import '../theme/app_colors.dart';
=======
>>>>>>> 81934c3d0910c9ee266a23bdc899ef19ea894423
import '../theme/aurora_background.dart';
import '../theme/glass_panel.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    const currency = 'KRW';
    final l10n = AppLocalizations.of(context)!;
    final categoryTotalsAsync = ref.watch(categoryTotalsProvider((_selectedMonth, currency)));
    final monthlyTotalsAsync = ref.watch(monthlyTotalsProvider(currency));
<<<<<<< HEAD
    final onSurface = Theme.of(context).colorScheme.onSurface;
=======
>>>>>>> 81934c3d0910c9ee266a23bdc899ef19ea894423

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
<<<<<<< HEAD
                  icon: Icon(Icons.chevron_left_rounded, color: onSurface),
=======
                  icon: const Icon(Icons.chevron_left_rounded),
>>>>>>> 81934c3d0910c9ee266a23bdc899ef19ea894423
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
                    });
                  },
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_selectedMonth),
<<<<<<< HEAD
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onSurface),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right_rounded, color: onSurface),
=======
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
>>>>>>> 81934c3d0910c9ee266a23bdc899ef19ea894423
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Donut Chart Card
            GlassPanel(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
<<<<<<< HEAD
                    Text(l10n.category, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: onSurface)),
                    const SizedBox(height: 20),
                    categoryTotalsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: onSurface))),
=======
                    Text(l10n.category, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    categoryTotalsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
>>>>>>> 81934c3d0910c9ee266a23bdc899ef19ea894423
                      data: (totals) {
                        if (totals.isEmpty || totals.every((t) => t.totalMinor == 0)) {
                          return SizedBox(
                            height: 200,
<<<<<<< HEAD
                            child: Center(child: Text(l10n.noReceiptsMonth, style: TextStyle(color: onSurface.withValues(alpha: 0.60)))),
=======
                            child: Center(child: Text(l10n.noReceiptsMonth)),
>>>>>>> 81934c3d0910c9ee266a23bdc899ef19ea894423
                          );
                        }

                        final totalSum = totals.fold(0, (sum, t) => sum + t.totalMinor);

                        return Column(
                          children: [
                            SizedBox(
                              height: 220,
                              child: PieChart(
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
                                    final pct = totalSum > 0 ? (t.totalMinor / totalSum) * 100 : 0.0;

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
                            ),
                            const SizedBox(height: 16),
                            ...totals.map((t) {
                              final pct = totalSum > 0 ? (t.totalMinor / totalSum) * 100 : 0.0;
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: Color(t.colorValue))),
                                        const SizedBox(width: 8),
<<<<<<< HEAD
                                        Text(t.categoryKey, style: TextStyle(color: onSurface)),
                                      ],
                                    ),
                                    Text(
                                      '${Money(t.totalMinor).format()} (${pct.toStringAsFixed(1)}%)',
                                      style: TextStyle(color: onSurface, fontWeight: FontWeight.w500),
                                    ),
=======
                                        Text(t.categoryKey),
                                      ],
                                    ),
                                    Text('${Money(t.totalMinor).format()} (${pct.toStringAsFixed(1)}%)'),
>>>>>>> 81934c3d0910c9ee266a23bdc899ef19ea894423
                                  ],
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bar Chart Card (Last 6 Months)
            GlassPanel(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
<<<<<<< HEAD
                    Text('Last 6 Months', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: onSurface)),
                    const SizedBox(height: 20),
                    monthlyTotalsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e', style: TextStyle(color: onSurface))),
                      data: (monthTotals) {
                        if (monthTotals.isEmpty) {
                          return SizedBox(height: 150, child: Center(child: Text('No data', style: TextStyle(color: onSurface.withValues(alpha: 0.60)))));
=======
                    const Text('Last 6 Months', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    monthlyTotalsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                      data: (monthTotals) {
                        if (monthTotals.isEmpty) {
                          return const SizedBox(height: 150, child: Center(child: Text('No data')));
>>>>>>> 81934c3d0910c9ee266a23bdc899ef19ea894423
                        }

                        final maxVal = monthTotals.map((m) => m.totalMinor).reduce((a, b) => a > b ? a : b).toDouble();

                        return SizedBox(
                          height: 200,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: maxVal > 0 ? maxVal * 1.2 : 100,
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index >= 0 && index < monthTotals.length) {
                                        final parts = monthTotals[index].month.split('-');
<<<<<<< HEAD
                                        return Text('${parts[1]}월', style: TextStyle(fontSize: 12, color: onSurface));
=======
                                        return Text('${parts[1]}월', style: const TextStyle(fontSize: 12));
>>>>>>> 81934c3d0910c9ee266a23bdc899ef19ea894423
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
                                  barRods: [
                                    BarChartRodData(
                                      toY: m.totalMinor.toDouble(),
<<<<<<< HEAD
                                      color: isCurrent ? Theme.of(context).colorScheme.primary : AppColors.iris.withValues(alpha: 0.60),
=======
                                      color: isCurrent ? const Color(0xFF12B5A6) : const Color(0xFF7C83FD).withValues(alpha: 0.6),
>>>>>>> 81934c3d0910c9ee266a23bdc899ef19ea894423
                                      width: 18,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
