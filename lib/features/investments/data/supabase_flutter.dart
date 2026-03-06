import 'package:supabase_flutter/supabase_flutter.dart';

class AssetTransactionRepository {
  final SupabaseClient _supabase;

  AssetTransactionRepository(this._supabase);

  Future<void> recordTransaction({
    required String assetName,
    required String assetType, // KRIPTO, SAHAM, LOGAM_MULIA, dll
    required String tickerSymbol,
    required String txType, // BELI atau JUAL
    required double units,
    required double pricePerUnit,
    String? walletId, // ID Dompet Kas jika transaksinya memotong/menambah uang fiat
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User belum login!');

    final totalAmount = units * pricePerUnit;

    // ==========================================
    // LANGKAH 1: CARI ATAU BUAT KATALOG ASET
    // ==========================================
    var assetResponse = await _supabase
        .from('assets')
        .select('id')
        .eq('ticker_symbol', tickerSymbol.toUpperCase())
        .eq('asset_type', assetType)
        .maybeSingle();

    String assetId;
    if (assetResponse == null) {
      // Aset belum terdaftar di database global, kita daftarkan
      final newAsset = await _supabase.from('assets').insert({
        'name': assetName,
        'asset_type': assetType,
        'ticker_symbol': tickerSymbol.toUpperCase(),
      }).select('id').single();
      assetId = newAsset['id'].toString();
    } else {
      assetId = assetResponse['id'].toString();
    }

    // ==========================================
    // LANGKAH 2: CARI ATAU BUKA PORTOFOLIO USER
    // ==========================================
    var portfolioResponse = await _supabase
        .from('user_portfolios')
        .select('id')
        .eq('user_id', userId)
        .eq('asset_id', assetId)
        .maybeSingle();

    String portfolioId;
    if (portfolioResponse == null) {
      // User belum pernah punya aset ini, buka portofolio baru
      final newPortfolio = await _supabase.from('user_portfolios').insert({
        'user_id': userId,
        'asset_id': assetId,
      }).select('id').single();
      portfolioId = newPortfolio['id'].toString();
    } else {
      portfolioId = portfolioResponse['id'].toString();
    }

    // ==========================================
    // LANGKAH 3: INTEGRASI ARUS KAS FIAT (OPSIONAL TAPI KRUSIAL)
    // ==========================================
    String? fiatTxId;
    if (walletId != null) {
      // Logika Logis: 
      // Kalau BELI aset, uang kas KELUAR. 
      // Kalau JUAL aset, uang kas MASUK.
      final fiatTxType = txType == 'BELI' ? 'PENGELUARAN' : 'PEMASUKAN';
      final desc = '$txType $units $tickerSymbol @ Rp${pricePerUnit.toStringAsFixed(0)}';

      final newFiatTx = await _supabase.from('fiat_transactions').insert({
        'user_id': userId,
        'wallet_id': walletId,
        'transaction_type': fiatTxType,
        'amount': totalAmount,
        'description': desc,
      }).select('id').single();
      
      fiatTxId = newFiatTx['id'].toString();
    }

    // ==========================================
    // LANGKAH 4: CATAT TRANSAKSI ASET 
    // (Trigger PostgreSQL akan jalan otomatis setelah ini)
    // ==========================================
    await _supabase.from('asset_transactions').insert({
      'user_id': userId,
      'portfolio_id': portfolioId,
      'transaction_type': txType,
      'units': units,
      'price_per_unit': pricePerUnit,
      'total_amount': totalAmount,
      if (fiatTxId != null) 'linked_fiat_transaction_id': fiatTxId,
    });
  }
}
