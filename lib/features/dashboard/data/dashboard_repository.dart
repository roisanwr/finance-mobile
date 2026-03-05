import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/wallet_balance_model.dart';

class DashboardRepository {
  final SupabaseClient _supabase;

  DashboardRepository(this._supabase);

  Future<List<WalletBalanceModel>> fetchWalletBalances() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User belum login!');

    // Tembak langsung ke VIEW wallet_balances, bukan ke tabel biasa
    final response = await _supabase
        .from('wallet_balances')
        .select()
        .eq('user_id', userId);

    return (response as List<dynamic>)
        .map(
          (data) => WalletBalanceModel.fromJson(data as Map<String, dynamic>),
        )
        .toList();
  }
}
