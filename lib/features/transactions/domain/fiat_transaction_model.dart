// Enum tipe transaksi sesuai dengan database Supabase
enum FiatTxType { PEMASUKAN, PENGELUARAN, TRANSFER }

class FiatTransactionModel {
  final String id;
  final String userId;
  final String walletId;
  final String?
  categoryId; // Bisa null karena opsional/belum kita buat fiturnya
  final FiatTxType transactionType;
  final double amount;
  final String? description;
  final DateTime transactionDate;

  FiatTransactionModel({
    required this.id,
    required this.userId,
    required this.walletId,
    this.categoryId,
    required this.transactionType,
    required this.amount,
    this.description,
    required this.transactionDate,
  });

  factory FiatTransactionModel.fromJson(Map<String, dynamic> json) {
    return FiatTransactionModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      walletId: json['wallet_id'].toString(),
      categoryId: json['category_id']?.toString(),
      transactionType: FiatTxType.values.firstWhere(
        (e) => e.name == json['transaction_type'],
        orElse: () => FiatTxType.PENGELUARAN, // Fallback aman
      ),
      // Parsing angka aman dari database (bisa int atau double)
      amount: double.parse(json['amount'].toString()),
      description: json['description']?.toString(),
      transactionDate: DateTime.parse(json['transaction_date'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'wallet_id': walletId,
      if (categoryId != null) 'category_id': categoryId,
      'transaction_type': transactionType.name,
      'amount': amount,
      if (description != null) 'description': description,
      'transaction_date': transactionDate.toIso8601String(),
    };
  }
}
