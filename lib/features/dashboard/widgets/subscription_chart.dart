import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../database/app_database.dart';

class SubscriptionChart extends StatelessWidget {
  final List<Subscription> subscriptions;

  const SubscriptionChart({super.key, required this.subscriptions});

  @override
  Widget build(BuildContext context) {
    if (subscriptions.isEmpty) {
      return const Center(child: Text('No data for this year'));
    }

    // Aggregate data by month
    final Map<int, double> monthlyData = {};
    for (int i = 1; i <= 12; i++) {
      monthlyData[i] = 0.0;
    }

    for (var subscription in subscriptions) {
      final month = subscription.subscriptionDate.month;
      monthlyData[month] = (monthlyData[month] ?? 0) + subscription.amount;
    }

    final List<FlSpot> spots = [];
    double maxAmount = 0;

    monthlyData.forEach((month, amount) {
      spots.add(FlSpot(month.toDouble(), amount));
      if (amount > maxAmount) maxAmount = amount;
    });

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxAmount > 0 ? maxAmount / 5 : 1000,
          getDrawingHorizontalLine: (value) {
            return const FlLine(color: Color(0xffe7e8ec), strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final month = value.toInt();
                if (month >= 1 && month <= 12) {
                  return SideTitleWidget(
                    meta: meta, // Try meta instead of axisSide
                    child: Text(
                      DateFormat('MMM').format(
                        DateTime(2024, month),
                      ), // Dummy year, just need month name
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60, // Increased reserved size
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                return Text(
                  NumberFormat.compact().format(value),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.left,
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 1,
        maxX: 12,
        minY: 0,
        maxY: maxAmount * 1.2, // Add some padding to top
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppConstants.primaryColor,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppConstants.primaryColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
