import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../models/place.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  final String lang;
  final VoidCallback? onMapTap;

  const PlaceCard({
    super.key,
    required this.place,
    required this.lang,
    this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              place.getName(lang),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              place.city,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            if (place.subType != null) ...[
              const SizedBox(height: 4),
              Text(
                place.subType!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                if (place.phone != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _callPhone(place.phone!),
                      icon: const Icon(Icons.phone, size: 18),
                      label: const Text('Call'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                if (place.phone != null && place.latitude != null && place.longitude != null)
                  const SizedBox(width: 8),
                if (place.latitude != null && place.longitude != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onMapTap,
                      icon: const Icon(Icons.map, size: 18),
                      label: const Text('Map'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _callPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}
