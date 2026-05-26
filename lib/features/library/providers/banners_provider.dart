import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';
import '../models/banner_model.dart';

final bannersProvider = FutureProvider<List<BannerModel>>((ref) async {
  final data = await SupabaseService.instance.client
      .from('banners')
      .select('*')
      .eq('is_active', true)
      .order('order', ascending: true);

  return (data as List)
      .map((item) => BannerModel.fromJson(item as Map<String, dynamic>))
      .toList();
});
