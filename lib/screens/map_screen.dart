import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../services/supabase_service.dart';
import '../models/place.dart';
import '../constants/app_colors.dart';
import '../constants/translations.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<Place> places = [];
  Map<String, int> typeStats = {};
  String selectedType = 'all';
  bool isLoading = true;
  LatLng? currentLocation;

  @override
  void initState() {
    super.initState();
    _loadData();
    _getCurrentLocation();
  }

  Future<void> _loadData() async {
    try {
      final [fetchedPlaces, fetchedTypes] = await Future.wait([
        SupabaseService.fetchPlaces('court'), // Default to courts
        SupabaseService.fetchTypesWithCounts(),
      ]);

      setState(() {
        places = fetchedPlaces as List<Place>;
        typeStats = fetchedTypes as Map<String, int>;
        selectedType = 'court';
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });

      if (currentLocation != null) {
        _mapController.move(currentLocation!, 14);
      }
    } catch (e) {
      // Handle location errors silently
    }
  }

  Future<void> _loadPlacesByType(String type) async {
    setState(() => isLoading = true);
    try {
      final fetchedPlaces = await SupabaseService.fetchPlaces(type);
      setState(() {
        places = fetchedPlaces;
        selectedType = type;
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
          AppTranslations.get('map', lang),
          style: const TextStyle(color: AppColors.text),
        ),
      ),
      body: Column(
        children: [
          // Type filter
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: AppColors.cardBackground,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: typeStats.length,
              itemBuilder: (context, index) {
                final type = typeStats.keys.elementAt(index);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(AppTranslations.getTypeLabel(type, lang)),
                    selected: selectedType == type,
                    onSelected: (selected) {
                      if (selected) _loadPlacesByType(type);
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.background,
                    labelStyle: TextStyle(
                      color: selectedType == type ? Colors.white : AppColors.text,
                    ),
                  ),
                );
              },
            ),
          ),
          // Map
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: currentLocation ?? const LatLng(33.3152, 44.3661), // Baghdad
                      initialZoom: 12,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.iraq_legal_guide',
                      ),
                      MarkerLayer(
                        markers: places
                            .where((p) => p.latitude != null && p.longitude != null)
                            .map((place) => Marker(
                                  point: LatLng(place.latitude!, place.longitude!),
                                  width: 40,
                                  height: 40,
                                  child: Icon(
                                    Icons.location_on,
                                    color: _getTypeColor(place.type),
                                    size: 40,
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
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
