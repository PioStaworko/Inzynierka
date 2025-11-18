// lib/widgets/monthly_bar_chart.dart

import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/expense_model.dart';
import '../models/income_model.dart';

class MonthlyBarChart extends StatelessWidget {
  final List<Expense> expenses;
  final List<Income> incomes;

  const MonthlyBarChart({
    super.key,
    required this.expenses,
    required this.incomes,
  });

  @override
  Widget build(BuildContext context) {
    // 1. PRZYGOTOWANIE DANYCH (AGREGACJA)
    // Tworzymy mapę: numer miesiąca (1-12) -> [suma wydatków, suma przychodów]
    final Map<int, List<double>> monthlyData = {};
    
    // Inicjalizujemy zerami dla obecnego roku (12 miesięcy)
    for (int i = 1; i <= 12; i++) {
      monthlyData[i] = [0.0, 0.0]; // [Wydatki, Przychody]
    }

    final currentYear = DateTime.now().year;

    // Sumujemy wydatki
    for (var e in expenses) {
      if (e.date.year == currentYear) {
        monthlyData[e.date.month]![0] += e.amount;
      }
    }

    // Sumujemy przychody
    for (var i in incomes) {
      if (i.date.year == currentYear) {
        monthlyData[i.date.month]![1] += i.amount;
      }
    }

    // Obliczamy maksymalną wartość na wykresie, żeby ustawić skalę Y
    double maxY = 0;
    monthlyData.forEach((key, value) {
      maxY = max(maxY, max(value[0], value[1]));
    });
    // Dodajemy 20% buforu na górze, żeby słupki nie dotykały sufitu
    maxY = maxY * 1.2;
    if (maxY == 0) maxY = 100; // Zabezpieczenie, gdy brak danych

    // 2. BUDOWANIE WYKRESU
    return AspectRatio(
      aspectRatio: 1.5, // Proporcje wykresu
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Theme.of(context).colorScheme.surface, // Kolor tła karty (zgodny z trybem ciemnym)
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
                    // Konfiguracja osi i linii pomocniczych
                    gridData: const FlGridData(show: false), // Ukrywamy kratkę
                    borderData: FlBorderData(show: false),   // Ukrywamy ramkę
                    
                    // Konfiguracja opisów osi (Tytuły)
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      // Oś Y (Lewa)
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false), // Ukrywamy liczby po lewej dla czystości
                      ),
                      // Oś X (Dolna - Miesiące)
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const style = TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            );
                            String text;
                            switch (value.toInt()) {
                              case 1: text = 'STY'; break;
                              case 3: text = 'MAR'; break;
                              case 5: text = 'MAJ'; break;
                              case 7: text = 'LIP'; break;
                              case 9: text = 'WRZ'; break;
                              case 11: text = 'LIS'; break;
                              default: return const SizedBox(); // Pokazujemy co drugi miesiąc, żeby nie było tłoku
                            }
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(text, style: style),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    // DANE WYKRESU (Słupki)
                    barGroups: _generateGroups(monthlyData),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Legenda pod wykresem
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

  // Metoda pomocnicza do generowania grup słupków
  List<BarChartGroupData> _generateGroups(Map<int, List<double>> data) {
    return List.generate(12, (index) {
      final month = index + 1;
      final values = data[month]!; // [wydatki, przychody]
      
      return BarChartGroupData(
        x: month,
        barRods: [
          // Słupek Wydatków (Czerwony)
          BarChartRodData(
            toY: values[0],
            color: Colors.red,
            width: 8,
            borderRadius: BorderRadius.circular(2),
          ),
          // Słupek Przychodów (Zielony)
          BarChartRodData(
            toY: values[1],
            color: Colors.green,
            width: 8,
            borderRadius: BorderRadius.circular(2),
          ),
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