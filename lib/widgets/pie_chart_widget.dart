import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Pie chart widget using `fl_chart` with grouping and simple interactivity.
class PieChartWidget extends StatefulWidget {
  final Map<String, double> data;
  final Map<String, Color> colors;
  final double size;
  /// Max number of categories to show separately (rest will be grouped into 'Inne')
  final int maxSections;

  const PieChartWidget({
    super.key,
    required this.data,
    required this.colors,
    this.size = 150,
    this.maxSections = 8,
  });

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final total = widget.data.values.fold(0.0, (a, b) => a + b);

    if (total <= 0) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade300),
            child: const Center(child: Text('Brak', style: TextStyle(color: Colors.black54))),
          ),
        ),
      );
    }

    final entries = widget.data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(widget.maxSections).toList();
    final rest = entries.skip(widget.maxSections).toList();
    final otherValue = rest.fold(0.0, (s, e) => s + e.value);

    final shown = List<MapEntry<String, double>>.from(top);
    if (otherValue > 0) shown.add(MapEntry('Inne', otherValue));

    final sections = <PieChartSectionData>[];
    for (var i = 0; i < shown.length; i++) {
      final e = shown[i];
      final color = widget.colors[e.key] ?? (e.key == 'Inne' ? Colors.grey : Colors.primaries[i % Colors.primaries.length]);
      final isTouched = _touchedIndex == i;

      sections.add(PieChartSectionData(
        value: e.value,
        color: color,
        radius: isTouched ? widget.size * 0.3 : widget.size * 0.22,
        title: '',
        showTitle: false,
      ));
    }

    return SizedBox(
      width: widget.size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: widget.size * 0.35,
                    sectionsSpace: 2,
                    startDegreeOffset: -90,
                    borderData: FlBorderData(show: false),
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        if (response == null || response.touchedSection == null) {
                          setState(() => _touchedIndex = null);
                          return;
                        }
                        final idx = response.touchedSection!.touchedSectionIndex;
                        if (idx < 0 || idx >= shown.length) {
                          setState(() => _touchedIndex = null);
                          return;
                        }
                        setState(() => _touchedIndex = idx);
                      },
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${total.toStringAsFixed(0)} zł', style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (_touchedIndex != null)
                      const SizedBox(height: 4),
                    if (_touchedIndex != null && _touchedIndex! >= 0 && _touchedIndex! < shown.length)
                      Builder(builder: (ctx) {
                        final entry = shown[_touchedIndex!];
                        final pct = (entry.value / total) * 100;
                        return Text('${entry.key}: ${entry.value.toStringAsFixed(2)} zł • ${pct.toStringAsFixed(1)}%', style: TextStyle(fontSize: 11, color: Colors.grey[700]));
                      }),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          _buildLegend(context, shown, entries.length > widget.maxSections, entries),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context, List<MapEntry<String, double>> shown, bool hasMore, List<MapEntry<String,double>> allEntries) {
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (ctx, idx) {
                final e = shown[idx];
                final color = widget.colors[e.key] ?? (e.key == 'Inne' ? Colors.grey : Colors.primaries[idx % Colors.primaries.length]);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 8, backgroundColor: color),
                    const SizedBox(width: 6),
                    Text('${e.key} (${e.value.toStringAsFixed(0)})', style: const TextStyle(fontSize: 12)),
                  ],
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: shown.length,
            ),
          ),
          if (hasMore)
            TextButton(
              onPressed: () => _showAllCategoriesModal(context, allEntries),
              child: const Text('Pokaż wszystkie'),
            ),
        ],
      ),
    );
  }

  void _showAllCategoriesModal(BuildContext context, List<MapEntry<String,double>> allEntries) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.6,
            child: Column(
              children: [
                const SizedBox(height: 12),
                const Text('Wszystkie kategorie', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: allEntries.length,
                    separatorBuilder: (_, __) => const Divider(height: 8),
                    itemBuilder: (ctx, i) {
                      final e = allEntries[i];
                      final color = widget.colors[e.key] ?? Colors.primaries[i % Colors.primaries.length];
                      return ListTile(
                        leading: CircleAvatar(backgroundColor: color),
                        title: Text(e.key),
                        trailing: Text(e.value.toStringAsFixed(2)),
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
}