// Samakan persis dengan ENUM di database Supabase kamu
enum WalletType { TUNAI, BANK, DOMPET_DIGITAL }

class WalletModel {
  final String id;
  final String userId;
  final String name;
  final WalletType type;
  final String currency;

  WalletModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.currency = 'IDR',
  });

  // Fungsi untuk mengubah data JSON dari Supabase menjadi Object Dart
  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      name: json['name'].toString(),
      // Mencocokkan string dari DB ke Enum Dart
      type: WalletType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => WalletType.TUNAI, // Fallback aman
      ),
      currency: json['currency'] ?? 'IDR',
    );
  }

  // Fungsi untuk mengubah Object Dart menjadi JSON sebelum dilempar ke Supabase
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'type': type.name,
      'currency': currency,
    };
  }
}
