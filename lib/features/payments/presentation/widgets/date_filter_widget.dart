import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFilterWidget extends StatefulWidget {
  final DateTimeRange? selectedRange;
  final Function(DateTimeRange?) onRangeChanged;

  const DateFilterWidget({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
  });

  @override
  State<DateFilterWidget> createState() => _DateFilterWidgetState();
}

class _DateFilterWidgetState extends State<DateFilterWidget> {
  String? selectedPeriod;

  final Map<String, DateTimeRange Function()> quickFilters = {
    'Aujourd\'hui': () {
      final now = DateTime.now();
      return DateTimeRange(
        start: DateTime(now.year, now.month, now.day),
        end: DateTime(now.year, now.month, now.day, 23, 59, 59),
      );
    },
    'Cette semaine': () {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      return DateTimeRange(
        start: DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day),
        end: DateTime(now.year, now.month, now.day, 23, 59, 59),
      );
    },
    'Ce mois': () {
      final now = DateTime.now();
      return DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
      );
    },
    '30 derniers jours': () {
      final now = DateTime.now();
      return DateTimeRange(
        start: now.subtract(const Duration(days: 30)),
        end: now,
      );
    },
    '3 derniers mois': () {
      final now = DateTime.now();
      return DateTimeRange(
        start: DateTime(now.year, now.month - 2, now.day),
        end: now,
      );
    },
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtres rapides',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...quickFilters.entries.map((entry) {
              final isSelected = selectedPeriod == entry.key;
              return FilterChip(
                label: Text(entry.key),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => selectedPeriod = entry.key);
                    widget.onRangeChanged(entry.value());
                  } else {
                    setState(() => selectedPeriod = null);
                    widget.onRangeChanged(null);
                  }
                },
                selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                checkmarkColor: Theme.of(context).primaryColor,
              );
            }).toList(),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Période personnalisée',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _buildCustomDatePicker(context),
        if (widget.selectedRange != null) ...[
          const SizedBox(height: 8),
          _buildSelectedRangeInfo(),
        ],
      ],
    );
  }

  Widget _buildCustomDatePicker(BuildContext context) {
    return InkWell(
      onTap: _selectCustomDateRange,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.date_range, color: Colors.grey[600]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.selectedRange == null
                    ? 'Sélectionner une période personnalisée'
                    : 'Du ${DateFormat('dd/MM/yyyy').format(widget.selectedRange!.start)} au ${DateFormat('dd/MM/yyyy').format(widget.selectedRange!.end)}',
                style: TextStyle(
                  color: widget.selectedRange == null ? Colors.grey[600] : Colors.black87,
                ),
              ),
            ),
            if (widget.selectedRange != null)
              GestureDetector(
                onTap: _clearCustomRange,
                child: Icon(Icons.clear, size: 20, color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedRangeInfo() {
    if (widget.selectedRange == null) return const SizedBox.shrink();

    final duration = widget.selectedRange!.end.difference(widget.selectedRange!.start).inDays + 1;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Période sélectionnée : $duration jour${duration > 1 ? 's' : ''}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectCustomDateRange() async {
    // Réinitialiser le filtre rapide sélectionné
    setState(() => selectedPeriod = null);

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: widget.selectedRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      widget.onRangeChanged(picked);
    }
  }

  void _clearCustomRange() {
    setState(() => selectedPeriod = null);
    widget.onRangeChanged(null);
  }
}