import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/wallet_model.dart';
import '../../transactions/domain/fiat_transaction_model.dart';
import '../../transactions/presentation/fiat_transaction_provider.dart';

class WalletDetailScreen extends ConsumerWidget {
  final WalletModel wallet;

  const WalletDetailScreen({super.key, required this.wallet});

  static const colorDarkBase = Color(0xFF101214);
  static const colorDarkCard = Color(0xFF1A1D21);
  static const colorAccentTeal = Color(0xFF00D2CC);
  static const colorIncome = Colors.greenAccent;
  static const colorExpense = Colors.redAccent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Memanggil provider filter yang baru saja kita buat dengan parameter ID dompet ini
    final mutations = ref.watch(walletTransactionsProvider(wallet.id));

    return Scaffold(
      backgroundColor: colorDarkBase,
      appBar: AppBar(
        backgroundColor: colorDarkBase,
        elevation: 0,
        title: Text(wallet.name.toUpperCase(), style: const TextStyle(letterSpacing: 2, fontSize: 16)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white54),
            onPressed: () {
              // Placeholder untuk fitur Edit/Hapus Dompet nanti
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur Pengaturan Dompet segera hadir')));
            },
          )
        ],
      ),
      body: mutations.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mutations.length,
              itemBuilder: (context, index) {
                final tx = mutations[index];
                return _buildMutationCard(tx);
              },
            ),
    );
  }

  Widget _buildMutationCard(FiatTransactionModel tx) {
    // LOGIKA BUNGLON UNTUK TRANSFER
    bool isIncome;
    if (tx.transactionType == FiatTxType.TRANSFER) {
      // Jika dompet ini adalah tujuan transfer, berarti ini uang masuk (hijau)
      isIncome = tx.toWalletId == wallet.id;
    } else {
      isIncome = tx.transactionType == FiatTxType.PEMASUKAN;
    }

    final color = isIncome ? colorIncome : colorExpense;
    final icon = isIncome ? Icons.arrow_downward : Icons.arrow_upward;
    final sign = isIncome ? '+' : '-';

    // Penyesuaian deskripsi untuk memperjelas konteks transfer
    String displayDesc = tx.description ?? 'Tanpa Keterangan';
    if (tx.transactionType == FiatTxType.TRANSFER) {
      displayDesc = isIncome ? 'Transfer Masuk: $displayDesc' : 'Transfer Keluar: $displayDesc';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorDarkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(displayDesc, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(
          '${tx.transactionDate.day}/${tx.transactionDate.month}/${tx.transactionDate.year}', 
          style: const TextStyle(color: Colors.white54, fontSize: 12)
        ),
        trailing: Text(
          '$sign Rp ${tx.amount.toStringAsFixed(0)}',
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.white10),
          SizedBox(height: 16),
          Text('Belum Ada Mutasi', style: TextStyle(color: Colors.white54, fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Dompet ini belum memiliki riwayat transaksi.', style: TextStyle(color: Colors.white30, fontSize: 14)),
        ],
      ),
    );
  }
}
