// lib/widgets/monthly_bar_chart.dart

import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Import bazy danych, bo stamtąd pochodzą klasy ExpenseWithItems i Income
import '../data/app_database.dart'; 

class MonthlyBarChart extends StatelessWidget {
  // Lista "opakowanych" wydatków (nagłówek + pozycje)
  final List<ExpenseWithItems> expenses; 
  final List<Income> incomes;

  const MonthlyBarChart({
    super.key,
    required this.expenses,
    required this.incomes,
  });

  @override
  Widget build(BuildContext context) {
    final Map<int, List<double>> monthlyData = {};
    
    for (int i = 1; i <= 12; i++) {
      monthlyData[i] = [0.0, 0.0]; 
    }

    final currentYear = DateTime.now().year;

    // Sumujemy wydatki
    for (var entry in expenses) {
      // Dostęp do daty i kwoty przez .expense
      if (entry.expense.date.year == currentYear) {
        monthlyData[entry.expense.date.month]![0] += entry.expense.amount;
      }
    }

    // Sumujemy przychody
    for (var i in incomes) {
      if (i.date.year == currentYear) {
        monthlyData[i.date.month]![1] += i.amount;
      }
    }

    // Reszta kodu bez zmian (rysowanie wykresu)
    double maxY = 0;
    monthlyData.forEach((key, value) {
      maxY = max(maxY, max(value[0], value[1]));
    });
    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 100;

    return AspectRatio(
      aspectRatio: 1.5, 
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Theme.of(context).colorScheme.surface, 
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Bilans roczny ($currentYear)',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10);
                            String text;
                            switch (value.toInt()) {
                              case 1: text = 'STY';
                              case 3: text = 'MAR'; 
                              case 5: text = 'MAJ'; 
                              case 7: text = 'LIP'; 
                              case 9: text = 'WRZ';
                              case 11: text = 'LIS'; 
                              default: return const SizedBox(); 
                            }
                            return SideTitleWidget(axisSide: meta.axisSide, child: Text(text, style: style));
                          },
                        ),
                      ),
                    ),
                    barGroups: _generateGroups(monthlyData),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(Colors.green, 'Przychody'),
                  const SizedBox(width: 16),
                  _buildLegendItem(Colors.red, 'Wydatki'),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _generateGroups(Map<int, List<double>> data) {
    return List.generate(12, (index) {
      final month = index + 1;
      final values = data[month]!;
      return BarChartGroupData(
        x: month,
        barRods: [
          BarChartRodData(toY: values[0], color: Colors.red, width: 8, borderRadius: BorderRadius.circular(2)),
          BarChartRodData(toY: values[1], color: Colors.green, width: 8, borderRadius: BorderRadius.circular(2)),
        ],
      );
    });
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}