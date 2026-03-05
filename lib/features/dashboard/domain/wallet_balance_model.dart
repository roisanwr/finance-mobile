class WalletBalanceModel {
  final String walletId;
  final String name;
  final double balance;

  WalletBalanceModel({
    required this.walletId,
    required this.name,
    required this.balance,
  });

  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) {
    return WalletBalanceModel(
      walletId: json['wallet_id'].toString(),
      name: json['name'].toString(),
      // Konversi aman karena dari Supabase bisa berformat int atau numeric
      balance: double.parse(json['balance'].toString()),
    );
  }
}
