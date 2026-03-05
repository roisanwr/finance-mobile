import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/portfolio_model.dart';

class PortfolioRepository {
  final SupabaseClient _supabase;

  PortfolioRepository(this._supabase);

  // Mengambil daftar aset yang dimiliki user
  Future<List<PortfolioModel>> fetchUserPortfolios() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User belum login!');

    // Query JOIN di Supabase: Ambil portfolio, dan tarik data 'name, asset_type, ticker_symbol' dari tabel foreign key 'assets'
    final response = await _supabase
        .from('user_portfolios')
        .select('*, assets(name, asset_type, ticker_symbol)')
        .eq('user_id', userId)
        .gt(
          'total_units',
          0,
        ); // Hanya tampilkan yang unitnya lebih dari 0 (belum dijual semua)

    return (response as List<dynamic>)
        .map((data) => PortfolioModel.fromJson(data as Map<String, dynamic>))
        .toList();
  }
}
