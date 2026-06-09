import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/translations.dart';

class TypeCard extends StatelessWidget {
  final String type;
  final int count;
  final VoidCallback onTap;

  const TypeCard({
    super.key,
    required this.type,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_getIcon(type), size: 32, color: _getColor(type)),
            const SizedBox(height: 12),
            Text(
              AppTranslations.getTypeLabel(type, 'en'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$count ${AppTranslations.get('available', 'en')}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'court':
        return Icons.gavel;
      case 'police':
        return Icons.local_police;
      case 'government':
        return Icons.account_balance;
      case 'school':
        return Icons.school;
      default:
        return Icons.location_city;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case 'court':
        return AppColors.courtColor;
      case 'police':
        return AppColors.policeColor;
      case 'government':
        return AppColors.governmentColor;
      case 'school':
        return AppColors.schoolColor;
      default:
        return AppColors.textSecondary;
    }
  }
}
