import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/supabase_service.dart';
import '../widgets/type_card.dart';
import '../constants/app_colors.dart';
import '../constants/translations.dart';
import 'type_list_screen.dart';
import 'lawyer_login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, int> typeStats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTypes();
  }

  Future<void> fetchTypes() async {
    try {
      final stats = await SupabaseService.fetchTypesWithCounts();
      setState(() {
        typeStats = stats;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final lang = langProvider.currentLang;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          AppTranslations.get('title', lang),
          style: const TextStyle(color: AppColors.text),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: AppColors.text),
            onPressed: () => langProvider.toggleLanguage(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : typeStats.isEmpty
              ? Center(
                  child: Text(
                    AppTranslations.get('no_results', lang),
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LawyerLoginScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.account_circle),
                        label: const Text('Lawyer Portal'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: typeStats.length,
                          itemBuilder: (context, index) {
                            final type = typeStats.keys.elementAt(index);
                            final count = typeStats[type]!;
                            return TypeCard(
                              type: type,
                              count: count,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TypeListScreen(type: type),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
