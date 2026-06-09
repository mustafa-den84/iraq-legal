import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/language_provider.dart';
import '../constants/app_colors.dart';
import '../constants/translations.dart';

class EmergencyContact {
  final String nameAr;
  final String nameEn;
  final String nameKu;
  final String phone;
  final IconData icon;

  EmergencyContact({
    required this.nameAr,
    required this.nameEn,
    required this.nameKu,
    required this.phone,
    required this.icon,
  });

  String getName(String lang) {
    switch (lang) {
      case 'ar':
        return nameAr;
      case 'ku':
        return nameKu;
      default:
        return nameEn;
    }
  }
}

class EmergencyScreen extends StatelessWidget {
  EmergencyScreen({super.key});

  final List<EmergencyContact> contacts = [
    EmergencyContact(
      nameAr: 'الشرطة',
      nameEn: 'Police',
      nameKu: 'پۆلیس',
      phone: '104',
      icon: Icons.local_police,
    ),
    EmergencyContact(
      nameAr: 'الإسعاف',
      nameEn: 'Ambulance',
      nameKu: 'ئەمبولانس',
      phone: '122',
      icon: Icons.local_hospital,
    ),
    EmergencyContact(
      nameAr: 'الدفاع المدني',
      nameEn: 'Civil Defense',
      nameKu: 'بەرگری مەدەنی',
      phone: '115',
      icon: Icons.fire_extinguisher,
    ),
    EmergencyContact(
      nameAr: 'الكهرباء',
      nameEn: 'Electricity',
      nameKu: 'کارەبا',
      phone: '121',
      icon: Icons.electrical_services,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final lang = langProvider.currentLang;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          AppTranslations.get('emergency', lang),
          style: const TextStyle(color: AppColors.text),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return Card(
            color: AppColors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.border),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(contact.icon, color: Colors.white),
              ),
              title: Text(
                contact.getName(lang),
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                contact.phone,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.phone, color: AppColors.primary),
                onPressed: () => _callPhone(contact.phone),
              ),
              onTap: () => _callPhone(contact.phone),
            ),
          );
        },
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
