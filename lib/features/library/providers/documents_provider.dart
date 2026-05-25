import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../models/document_model.dart';

final documentsProvider = StateNotifierProvider<DocumentsNotifier, AsyncValue<List<DocumentModel>>>((ref) {
  return DocumentsNotifier();
});

class DocumentsNotifier extends StateNotifier<AsyncValue<List<DocumentModel>>> {
  RealtimeChannel? _subscription;

  DocumentsNotifier() : super(const AsyncValue.loading()) {
    _loadDocuments();
    _subscribeToRealtime();
  }

  Future<void> _loadDocuments() async {
    try {
      final data = await SupabaseService.instance.client
          .from('documents')
          .select('*')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      final List<DocumentModel> docs = (data as List).map((json) => DocumentModel.fromJson(json)).toList();
      state = AsyncValue.data(docs);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void _subscribeToRealtime() {
    _subscription = SupabaseService.instance.client
        .channel('public:documents')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'documents',
          callback: (payload) {
            _loadDocuments(); // Reload entirely on any change for simplicity MVP
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    _subscription?.unsubscribe();
    super.dispose();
  }
}
