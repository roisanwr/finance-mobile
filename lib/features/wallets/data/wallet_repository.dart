import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/wallet_model.dart';

class WalletRepository {
  final SupabaseClient _supabase;

  WalletRepository(this._supabase);

  // Mengambil daftar dompet milik user yang sedang login
  Future<List<WalletModel>> fetchWallets() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User belum login!');

    // Query ke Supabase, persis seperti nulis SQL: SELECT * FROM wallets WHERE user_id = ?
    final response = await _supabase
        .from('wallets')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: true);

    // Ubah hasil response (List of Maps) menjadi List of WalletModel
    return (response as List<dynamic>)
        .map((data) => WalletModel.fromJson(data as Map<String, dynamic>))
        .toList();
  }

  // Menambahkan dompet baru ke database
  Future<void> addWallet({
    required String name,
    required WalletType type,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User belum login!');

    final newWallet = WalletModel(
      id: '', // Kosongkan, karena ID (UUID) di-generate otomatis oleh Supabase
      userId: userId,
      name: name,
      type: type,
    );

    // Insert ke Supabase
    await _supabase.from('wallets').insert(newWallet.toJson());
  }
}
