import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:yv_counter/data_model/mala.dart';
import 'package:yv_counter/l10n/app_localizations.dart';

/// A row of four summary stat tiles: total malas, total japs, current streak,
/// longest streak.
class MalaStatsCard extends StatelessWidget {
  const MalaStatsCard({
    super.key,
    required this.malas,
    required this.malaLabel,
    required this.japLabel,
    required this.localizations,
  });

  final List<Mala> malas;
  final String malaLabel;
  final String japLabel;
  final AppLocalizations localizations;

  @override
  Widget build(BuildContext context) {
    final totalMalas = malas.fold(0, (sum, m) => sum + m.count);
    final totalJaps = malas.fold(0, (sum, m) => sum + m.japs);
    final currentStreak = _currentStreak(malas);
    final longestStreak = _longestStreak(malas);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          children: [
            _StatTile(
              label: '${localizations.total} $malaLabel',
              value: totalMalas.toString(),
            ),
            _StatTile(
              label: '${localizations.total} $japLabel',
              value: totalJaps.toString(),
            ),
            _StatTile(
              label: localizations.currentStreak,
              value: localizations.days(count: currentStreak),
            ),
            _StatTile(
              label: localizations.longestStreak,
              value: localizations.days(count: longestStreak),
            ),
          ],
        ),
      ),
    );
  }

  /// Consecutive days ending today (or yesterday if today has no count).
  static int _currentStreak(List<Mala> malas) {
    final activeDays =
        malas
            .where((m) => m.count > 0)
            .map((m) => DateUtils.dateOnly(m.date))
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a)); // newest first

    if (activeDays.isEmpty) return 0;

    int streak = 0;
    DateTime check = DateUtils.dateOnly(DateTime.now());

    // If today has no count, allow streak to start from yesterday.
    if (!activeDays.contains(check)) {
      check = check.subtract(const Duration(days: 1));
    }

    for (final day in activeDays) {
      if (day == check) {
        streak++;
        check = check.subtract(const Duration(days: 1));
      } else if (day.isBefore(check)) {
        break;
      }
    }
    return streak;
  }

  /// The longest consecutive-day run across all history.
  static int _longestStreak(List<Mala> malas) {
    final activeDays =
        malas
            .where((m) => m.count > 0)
            .map((m) => DateUtils.dateOnly(m.date))
            .toSet()
            .toList()
          ..sort(); // oldest first

    if (activeDays.isEmpty) return 0;

    int longest = 1;
    int current = 1;

    for (int i = 1; i < activeDays.length; i++) {
      if (activeDays[i].difference(activeDays[i - 1]).inDays == 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }
    return longest;
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Bar chart showing mala counts for the last 7 days.
class MalaWeeklyChart extends StatelessWidget {
  const MalaWeeklyChart({
    super.key,
    required this.malas,
    required this.malaLabel,
  });

  final List<Mala> malas;
  final String malaLabel;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final today = DateUtils.dateOnly(DateTime.now());

    double maxVal = 0;
    final groups = List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      final count = malas
          .where((m) => DateUtils.isSameDay(m.date, day))
          .fold(0, (sum, m) => sum + m.count)
          .toDouble();
      if (count > maxVal) maxVal = count;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: count,
            color: color,
            width: 18,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });

    final chartMaxY = maxVal > 0 ? (maxVal * 1.3).ceilToDouble() : 5.0;

    return BarChart(
      BarChartData(
        maxY: chartMaxY,
        barGroups: groups,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (value, meta) {
                final day = today.subtract(Duration(days: 6 - value.toInt()));
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('E').format(day),
                        style: const TextStyle(fontSize: 9),
                      ),
                      Text(
                        DateFormat('d MMM').format(day),
                        style: const TextStyle(fontSize: 7),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                if (value == 0 || value == meta.max) {
                  return const SizedBox.shrink();
                }
                if (value % 1 != 0) return const SizedBox.shrink();
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(
                  '${rod.toY.toInt()} $malaLabel',
                  const TextStyle(fontSize: 12),
                ),
          ),
        ),
      ),
    );
  }
}

/// Bar chart showing daily mala counts for the last 30 days.
class MalaLast30DaysChart extends StatelessWidget {
  const MalaLast30DaysChart({
    super.key,
    required this.malas,
    required this.malaLabel,
  });

  final List<Mala> malas;
  final String malaLabel;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final today = DateUtils.dateOnly(DateTime.now());

    double maxVal = 0;
    final groups = List.generate(30, (i) {
      final day = today.subtract(Duration(days: 29 - i));
      final count = malas
          .where((m) => DateUtils.isSameDay(m.date, day))
          .fold(0, (sum, m) => sum + m.count)
          .toDouble();
      if (count > maxVal) maxVal = count;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: count,
            color: color,
            width: 6,
            borderRadius: BorderRadius.circular(3),
          ),
        ],
      );
    });

    final chartMaxY = maxVal > 0 ? (maxVal * 1.3).ceilToDouble() : 5.0;

    return BarChart(
      BarChartData(
        maxY: chartMaxY,
        barGroups: groups,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx != 0 && idx != 29 && idx % 5 != 0) {
                  return const SizedBox.shrink();
                }
                final day = today.subtract(Duration(days: 29 - idx));
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat('d MMM').format(day),
                    style: const TextStyle(fontSize: 8),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                if (value == 0 || value == meta.max) {
                  return const SizedBox.shrink();
                }
                if (value % 1 != 0) return const SizedBox.shrink();
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final day = today.subtract(Duration(days: 29 - group.x));
              return BarTooltipItem(
                '${DateFormat('d MMM').format(day)}\n${rod.toY.toInt()} $malaLabel',
                const TextStyle(fontSize: 12),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Bar chart showing monthly mala totals for the last 12 months.
class MalaMonthlyChart extends StatelessWidget {
  const MalaMonthlyChart({
    super.key,
    required this.malas,
    required this.malaLabel,
  });

  final List<Mala> malas;
  final String malaLabel;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final now = DateTime.now();

    // Sum counts per year-month key.
    final monthly = <String, int>{};
    for (final mala in malas) {
      final key =
          '${mala.date.year}-${mala.date.month.toString().padLeft(2, '0')}';
      monthly[key] = (monthly[key] ?? 0) + mala.count;
    }

    // Build last 12 months list (oldest → newest).
    double maxVal = 0;
    final monthDates = List.generate(12, (i) {
      return DateTime(now.year, now.month - (11 - i), 1);
    });

    final groups = monthDates.asMap().entries.map((entry) {
      final i = entry.key;
      final monthDate = entry.value;
      final key =
          '${monthDate.year}-${monthDate.month.toString().padLeft(2, '0')}';
      final count = (monthly[key] ?? 0).toDouble();
      if (count > maxVal) maxVal = count;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: count,
            color: color,
            width: 14,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();

    final chartMaxY = maxVal > 0 ? (maxVal * 1.3).ceilToDouble() : 5.0;

    return BarChart(
      BarChartData(
        maxY: chartMaxY,
        barGroups: groups,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final monthDate = monthDates[value.toInt()];
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat("MMM ''yy").format(monthDate),
                    style: const TextStyle(fontSize: 8),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) {
                if (value == 0 || value == meta.max) {
                  return const SizedBox.shrink();
                }
                if (value % 1 != 0) return const SizedBox.shrink();
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(
                  '${rod.toY.toInt()} $malaLabel',
                  const TextStyle(fontSize: 12),
                ),
          ),
        ),
      ),
    );
  }
}
