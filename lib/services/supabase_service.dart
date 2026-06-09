import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/place.dart';
import '../models/question.dart';
import '../models/answer.dart';
import '../models/lawyer.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://kyvmaysiyyxkwthjbozz.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_h8MhQD9byC16MbLWQFGqgg_IzjJE3yt';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static final supabase = Supabase.instance.client;

  // Fetch places by type
  static Future<List<Place>> fetchPlaces(String type) async {
    final response = await supabase
        .from('places')
        .select('*')
        .eq('type', type)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Place.fromJson(json)).toList();
  }

  // Fetch places with filters
  static Future<List<Place>> fetchPlacesWithFilters({
    required String type,
    String? city,
    String? subType,
    String? searchTerm,
  }) async {
    var query = supabase
        .from('places')
        .select('*')
        .eq('type', type);

    if (city != null && city != 'all') {
      query = query.eq('city', city);
    }

    if (subType != null && subType != 'all') {
      query = query.eq('sub_type', subType);
    }

    if (searchTerm != null && searchTerm.isNotEmpty) {
      query = query.or('name_ar.ilike.%$searchTerm%,name_en.ilike.%$searchTerm%,name_ku.ilike.%$searchTerm%');
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List).map((json) => Place.fromJson(json)).toList();
  }

  // Fetch distinct types
  static Future<Map<String, int>> fetchTypesWithCounts() async {
    final response = await supabase.from('places').select('type');

    final counts = <String, int>{};
    for (var place in response) {
      final type = place['type'] as String;
      counts[type] = (counts[type] ?? 0) + 1;
    }

    return counts;
  }

  // Fetch distinct cities for a type
  static Future<List<String>> fetchCities(String type) async {
    final response = await supabase
        .from('places')
        .select('city')
        .eq('type', type);

    final cities = (response as List)
        .map((e) => e['city'] as String)
        .toSet()
        .toList()
      ..sort();

    return cities;
  }

  // Fetch distinct subtypes for a type
  static Future<List<String>> fetchSubTypes(String type) async {
    final response = await supabase
        .from('places')
        .select('sub_type')
        .eq('type', type)
        .not('sub_type', 'is', null);

    final subTypes = (response as List)
        .map((e) => e['sub_type'] as String)
        .toSet()
        .toList()
      ..sort();

    return subTypes;
  }

  // Search for similar questions
  static Future<List<Map<String, dynamic>>> searchQuestions(String question, String lang) async {
    final response = await supabase
        .from('questions')
        .select('*, answers(*)')
        .ilike('question', '%$question%')
        .eq('lang', lang)
        .limit(5);

    return response as List<Map<String, dynamic>>;
  }

  // Insert question and answer
  static Future<void> insertQA(String question, String answer, String lang) async {
    final questionData = await supabase
        .from('questions')
        .insert({'question': question, 'lang': lang})
        .select()
        .single();

    await supabase.from('answers').insert({
      'question_id': questionData['id'],
      'answer': answer,
    });
  }

  // Lawyer registration
  static Future<Lawyer> registerLawyer(Map<String, dynamic> lawyerData) async {
    final response = await supabase
        .from('lawyers')
        .insert(lawyerData)
        .select()
        .single();

    return Lawyer.fromJson(response);
  }

  // Lawyer login
  static Future<Map<String, dynamic>?> loginLawyer(String phone, String password) async {
    final response = await supabase
        .from('lawyers')
        .select('*')
        .eq('phone', phone)
        .eq('password_hash', password)
        .maybeSingle();

    if (response == null) return null;

    // Generate a simple token (in production, use proper JWT)
    final token = 'lawyer_${response['id']}_${DateTime.now().millisecondsSinceEpoch}';

    return {
      'lawyer': Lawyer.fromJson(response),
      'token': token,
    };
  }

  // Fetch lawyer profile
  static Future<Lawyer?> fetchLawyerProfile(String token) async {
    // Extract lawyer ID from token
    final parts = token.split('_');
    if (parts.length < 2) return null;

    final lawyerId = int.tryParse(parts[1]);
    if (lawyerId == null) return null;

    final response = await supabase
        .from('lawyers')
        .select('*')
        .eq('id', lawyerId)
        .maybeSingle();

    if (response == null) return null;

    return Lawyer.fromJson(response);
  }

  // Update lawyer profile
  static Future<Lawyer> updateLawyerProfile(int lawyerId, Map<String, dynamic> updateData) async {
    final response = await supabase
        .from('lawyers')
        .update(updateData)
        .eq('id', lawyerId)
        .select()
        .single();

    return Lawyer.fromJson(response);
  }

  // Fetch visible lawyers for public view
  static Future<List<Lawyer>> fetchVisibleLawyers() async {
    final response = await supabase
        .from('lawyers')
        .select('*')
        .eq('is_visible', true)
        .eq('status', 'approved')
        .order('rating', ascending: false);

    return (response as List).map((json) => Lawyer.fromJson(json)).toList();
  }
}
