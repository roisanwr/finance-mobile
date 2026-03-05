enum FiatTxType { PEMASUKAN, PENGELUARAN, TRANSFER }

class FiatTransactionModel {
  final String id;
  final String userId;
  final String walletId;
  final String? toWalletId; // TAMBAHAN BARU: Dompet Tujuan
  final String? categoryId;
  final FiatTxType transactionType;
  final double amount;
  final String? description;
  final DateTime transactionDate;

  FiatTransactionModel({
    required this.id,
    required this.userId,
    required this.walletId,
    this.toWalletId,
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
      toWalletId: json['to_wallet_id']?.toString(), // Parsing dompet tujuan
      categoryId: json['category_id']?.toString(),
      transactionType: FiatTxType.values.firstWhere(
        (e) => e.name == json['transaction_type'],
        orElse: () => FiatTxType.PENGELUARAN,
      ),
      amount: double.parse(json['amount'].toString()),
      description: json['description']?.toString(),
      transactionDate: DateTime.parse(json['transaction_date'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'wallet_id': walletId,
      if (toWalletId != null) 'to_wallet_id': toWalletId, // Kirim jika ada
      if (categoryId != null) 'category_id': categoryId,
      'transaction_type': transactionType.name,
      'amount': amount,
      if (description != null) 'description': description,
      'transaction_date': transactionDate.toIso8601String(),
    };
  }
}
