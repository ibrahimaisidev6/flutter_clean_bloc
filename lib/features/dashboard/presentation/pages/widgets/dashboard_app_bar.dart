import 'package:flutter/material.dart';
import '../../../../../../core/constants/app_constants.dart';

class DashboardAppBar extends StatelessWidget {
  final String selectedPeriod;
  final List<String> periods;
  final Map<String, String> periodLabels;
  final Map<String, IconData> periodIcons;
  final Function(String) onPeriodChanged;
  final VoidCallback onRefresh;

  const DashboardAppBar({
    super.key,
    required this.selectedPeriod,
    required this.periods,
    required this.periodLabels,
    required this.periodIcons,
    required this.onPeriodChanged,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppConstants.primaryColor,
              AppConstants.primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: const FlexibleSpaceBar(
          title: Text(
            'Dashboard',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          centerTitle: false,
          titlePadding: EdgeInsets.only(left: 20, bottom: 16),
        ),
      ),
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        _buildPeriodSelector(),
        _buildRefreshButton(),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: PopupMenuButton<String>(
        icon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(periodIcons[selectedPeriod], size: 20),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
        onSelected: onPeriodChanged,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        itemBuilder: (context) => periods.map(_buildPeriodMenuItem).toList(),
      ),
    );
  }

  PopupMenuItem<String> _buildPeriodMenuItem(String period) {
    final isSelected = period == selectedPeriod;
    return PopupMenuItem(
      value: period,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppConstants.primaryColor.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                periodIcons[period],
                color: isSelected 
                    ? AppConstants.primaryColor 
                    : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              periodLabels[period] ?? period,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppConstants.primaryColor : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppConstants.primaryColor,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefreshButton() {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: onRefresh,
      ),
    );
  }
}