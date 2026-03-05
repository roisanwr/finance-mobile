import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/fiat_transaction_model.dart';

class FiatTransactionRepository {
  final SupabaseClient _supabase;

  FiatTransactionRepository(this._supabase);

  // Ambil histori transaksi user (diurutkan dari yang paling baru)
  Future<List<FiatTransactionModel>> fetchTransactions() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User belum login!');

    final response = await _supabase
        .from('fiat_transactions')
        .select()
        .eq('user_id', userId)
        .order('transaction_date', ascending: false); // Yang terbaru di atas

    return (response as List<dynamic>)
        .map(
          (data) => FiatTransactionModel.fromJson(data as Map<String, dynamic>),
        )
        .toList();
  }

  // Tambah catatan arus kas baru
  Future<void> addTransaction({
    required String walletId,
    String? categoryId,
    required FiatTxType type,
    required double amount,
    String? description,
    required DateTime date,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User belum login!');

    final newTx = FiatTransactionModel(
      id: '', // Di-generate oleh Supabase
      userId: userId,
      walletId: walletId,
      categoryId: categoryId,
      transactionType: type,
      amount: amount,
      description: description,
      transactionDate: date,
    );

    // Lempar datanya ke database
    await _supabase.from('fiat_transactions').insert(newTx.toJson());
  }
}
