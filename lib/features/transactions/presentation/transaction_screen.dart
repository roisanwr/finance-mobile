import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/fiat_transaction_model.dart';
import 'fiat_transaction_provider.dart';
import '../../wallets/presentation/wallet_provider.dart';

class TransactionScreen extends ConsumerWidget {
  const TransactionScreen({super.key});

  static const colorDarkBase = Color(0xFF101214);
  static const colorDarkCard = Color(0xFF1A1D21);
  static const colorAccentTeal = Color(0xFF00D2CC);
  static const colorAccentOrange = Color(0xFFFF9F43);
  static const colorIncome = Colors.greenAccent;
  static const colorExpense = Colors.redAccent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txState = ref.watch(fiatTransactionProvider);

    return Scaffold(
      backgroundColor: colorDarkBase,
      body: txState.when(
        data: (transactions) {
          if (transactions.isEmpty) return _buildEmptyState();

          return RefreshIndicator(
            color: colorAccentTeal,
            onRefresh: () async => ref.refresh(fiatTransactionProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return _buildTransactionCard(tx);
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: colorAccentTeal),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error:\n$error',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorAccentTeal,
        child: const Icon(Icons.add, color: colorDarkBase),
        onPressed: () => _showAddTransactionModal(context, ref),
      ),
    );
  }

  Widget _buildTransactionCard(FiatTransactionModel tx) {
    final isIncome = tx.transactionType == FiatTxType.PEMASUKAN;
    final color = isIncome ? colorIncome : colorExpense;
    final icon = isIncome ? Icons.arrow_downward : Icons.arrow_upward;
    final sign = isIncome ? '+' : '-';

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
        title: Text(
          tx.description ?? 'Tanpa Keterangan',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${tx.transactionDate.day}/${tx.transactionDate.month}/${tx.transactionDate.year}',
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        trailing: Text(
          '$sign Rp ${tx.amount.toStringAsFixed(0)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sync_alt, size: 80, color: Colors.white10),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Transaksi',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Klik + untuk catat pemasukan/pengeluaran',
            style: TextStyle(color: Colors.white30, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showAddTransactionModal(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final descController = TextEditingController();
    FiatTxType selectedType = FiatTxType.PENGELUARAN;
    String? selectedWalletId;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorDarkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Mengambil list dompet secara real-time dari Riverpod
            final walletsAsync = ref.watch(walletProvider);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Catat Transaksi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Input Nominal
                  TextField(
                    controller: amountController,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixText: 'Rp ',
                      prefixStyle: TextStyle(
                        color: colorAccentTeal,
                        fontSize: 24,
                      ),
                      labelText: 'Nominal',
                      labelStyle: TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white10),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: colorAccentTeal),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Jenis Transaksi (Radio Buttons)
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<FiatTxType>(
                          title: const Text(
                            'Keluar',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          value: FiatTxType.PENGELUARAN,
                          groupValue: selectedType,
                          activeColor: colorExpense,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) =>
                              setModalState(() => selectedType = val!),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<FiatTxType>(
                          title: const Text(
                            'Masuk',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          value: FiatTxType.PEMASUKAN,
                          groupValue: selectedType,
                          activeColor: colorIncome,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (val) =>
                              setModalState(() => selectedType = val!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Dropdown Pilih Dompet
                  const Text(
                    'Pilih Dompet',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  walletsAsync.when(
                    data: (wallets) {
                      if (wallets.isEmpty)
                        return const Text(
                          'Buat dompet dulu di menu Wallets!',
                          style: TextStyle(color: colorExpense),
                        );

                      // Set default wallet jika belum dipilih
                      selectedWalletId ??= wallets.first.id;

                      return DropdownButton<String>(
                        value: selectedWalletId,
                        dropdownColor: colorDarkBase,
                        isExpanded: true,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        underline: Container(height: 1, color: Colors.white10),
                        items: wallets
                            .map(
                              (w) => DropdownMenuItem(
                                value: w.id,
                                child: Text('${w.name} (${w.type.name})'),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null)
                            setModalState(() => selectedWalletId = val);
                        },
                      );
                    },
                    loading: () =>
                        const LinearProgressIndicator(color: colorAccentTeal),
                    error: (e, s) => Text(
                      'Error load dompet: $e',
                      style: const TextStyle(color: colorExpense),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Input Keterangan
                  TextField(
                    controller: descController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Keterangan (misal: Beli Kopi, Gaji)',
                      labelStyle: TextStyle(color: Colors.white54),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white10),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: colorAccentTeal),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tombol Simpan
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorAccentTeal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final amount = double.tryParse(
                          amountController.text.trim(),
                        );
                        if (amount == null ||
                            amount <= 0 ||
                            selectedWalletId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Nominal tidak valid atau dompet belum dipilih',
                              ),
                            ),
                          );
                          return;
                        }

                        ref
                            .read(fiatTransactionProvider.notifier)
                            .addTransaction(
                              walletId: selectedWalletId!,
                              type: selectedType,
                              amount: amount,
                              description: descController.text.trim(),
                              date: DateTime.now(),
                            );
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'SIMPAN TRANSAKSI',
                        style: TextStyle(
                          color: colorDarkBase,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
