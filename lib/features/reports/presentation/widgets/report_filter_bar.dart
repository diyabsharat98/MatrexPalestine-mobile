import 'package:flutter/material.dart';

import '../../../../core/utils/formatters.dart';

/// Date-range trigger shared by every Reports-on-Mobile screen — tapping it
/// opens the platform date-range picker (same UX already used by the
/// customer statement screen).
class ReportDateRangeBar extends StatelessWidget {
  const ReportDateRangeBar({super.key, required this.from, required this.to, required this.onTap});

  final DateTime from;
  final DateTime to;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.date_range, size: 18),
            const SizedBox(width: 8),
            Text('${Formatters.date(from)}  –  ${Formatters.date(to)}'),
          ],
        ),
      ),
    );
  }
}

/// Horizontally-scrolling single-select chip row for a report's `group_by`.
class ReportGroupByChips extends StatelessWidget {
  const ReportGroupByChips({super.key, required this.options, required this.value, required this.onChanged});

  final Map<String, String> options;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.entries
            .map((entry) => Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: ChoiceChip(
                    label: Text(entry.value),
                    selected: entry.key == value,
                    onSelected: (_) => onChanged(entry.key),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
