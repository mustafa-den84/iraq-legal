import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/supabase_service.dart';
import '../widgets/place_card.dart';
import '../models/place.dart';
import '../constants/app_colors.dart';
import '../constants/translations.dart';

class TypeListScreen extends StatefulWidget {
  final String type;

  const TypeListScreen({super.key, required this.type});

  @override
  State<TypeListScreen> createState() => _TypeListScreenState();
}

class _TypeListScreenState extends State<TypeListScreen> {
  List<Place> places = [];
  List<String> cities = [];
  List<String> subTypes = [];
  bool isLoading = true;
  String selectedCity = 'all';
  String selectedSubType = 'all';
  String searchTerm = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      final [fetchedPlaces, fetchedCities, fetchedSubTypes] = await Future.wait([
        SupabaseService.fetchPlacesWithFilters(
          type: widget.type,
          city: selectedCity == 'all' ? null : selectedCity,
          subType: selectedSubType == 'all' ? null : selectedSubType,
          searchTerm: searchTerm.isEmpty ? null : searchTerm,
        ),
        SupabaseService.fetchCities(widget.type),
        SupabaseService.fetchSubTypes(widget.type),
      ]);

      setState(() {
        places = fetchedPlaces as List<Place>;
        cities = ['all', ...(fetchedCities as List<String>)];
        subTypes = ['all', ...(fetchedSubTypes as List<String>)];
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
          AppTranslations.getTypeLabel(widget.type, lang),
          style: const TextStyle(color: AppColors.text),
        ),
      ),
      body: Column(
        children: [
          // Search and filters
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.cardBackground,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: AppTranslations.get('search_placeholder', lang),
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                  ),
                  onChanged: (value) {
                    searchTerm = value;
                    loadData();
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCity,
                        decoration: InputDecoration(
                          labelText: AppTranslations.get('all_cities', lang),
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.border),
                          ),
                        ),
                        items: cities
                            .map((city) => DropdownMenuItem(
                                  value: city,
                                  child: Text(city),
                                ))
                            .toList(),
                        onChanged: (value) {
                          selectedCity = value!;
                          loadData();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (subTypes.length > 1)
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedSubType,
                          decoration: InputDecoration(
                            labelText: AppTranslations.get('all_types', lang),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                          ),
                          items: subTypes
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            selectedSubType = value!;
                            loadData();
                          },
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Stats
          if (!isLoading)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '${places.length} ${AppTranslations.get('available', lang)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          // Places list
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : places.isEmpty
                    ? Center(
                        child: Text(
                          AppTranslations.get('no_results', lang),
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        itemCount: places.length,
                        itemBuilder: (context, index) {
                          return PlaceCard(
                            place: places[index],
                            lang: lang,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
