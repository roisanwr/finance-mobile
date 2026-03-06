import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/portfolio_model.dart';
import 'portfolio_provider.dart';
import 'asset_transaction_provider.dart';
import '../../wallets/presentation/wallet_provider.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  static const colorDarkBase = Color(0xFF101214);
  static const colorDarkCard = Color(0xFF1A1D21);
  static const colorAccentTeal = Color(0xFF00D2CC);
  static const colorAccentOrange = Color(0xFFFF9F43);
  static const colorBuy = Colors.greenAccent;
  static const colorSell = Colors.redAccent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioState = ref.watch(portfolioProvider);

    return Scaffold(
      backgroundColor: colorDarkBase,
      appBar: AppBar(
        backgroundColor: colorDarkBase,
        elevation: 0,
        title: const Text(
          'ASET INVESTASI',
          style: TextStyle(color: Colors.white54, fontSize: 14, letterSpacing: 2, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: portfolioState.when(
        data: (portfolios) {
          if (portfolios.isEmpty) return _buildEmptyState();

          return RefreshIndicator(
            color: colorAccentTeal,
            onRefresh: () async => ref.refresh(portfolioProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: portfolios.length,
              itemBuilder: (context, index) {
                final item = portfolios[index];
                return _buildPortfolioCard(item);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: colorAccentTeal)),
        error: (error, stack) => Center(child: Text('Error:\n$error', style: const TextStyle(color: Colors.redAccent))),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorAccentOrange,
        child: const Icon(Icons.add, color: colorDarkBase),
        onPressed: () => _showAddTransactionModal(context, ref),
      ),
    );
  }

  Widget _buildPortfolioCard(PortfolioModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorDarkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: colorAccentOrange.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.trending_up, color: colorAccentOrange, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.assetName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('${item.tickerSymbol} • ${item.assetType}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.totalUnits.toStringAsFixed(4)} Unit',
                style: const TextStyle(color: colorAccentTeal, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                'Avg: Rp ${item.averageBuyPrice.toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pie_chart_outline, size: 80, color: Colors.white10),
          const SizedBox(height: 16),
          const Text('Portofolio Kosong', style: TextStyle(color: Colors.white54, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Klik + untuk mulai mencatat pembelian aset.', style: TextStyle(color: Colors.white30, fontSize: 14)),
        ],
      ),
    );
  }

  void _showAddTransactionModal(BuildContext context, WidgetRef ref) {
    final tickerController = TextEditingController();
    final nameController = TextEditingController();
    final unitsController = TextEditingController();
    final priceController = TextEditingController();
    
    String txType = 'BELI';
    String assetType = 'KRIPTO';
    String? selectedWalletId;
    bool useWallet = true;

    final assetTypes = ['KRIPTO', 'SAHAM', 'LOGAM_MULIA', 'PROPERTI', 'BISNIS', 'LAINNYA'];

    showModalBottomSheet(
      context: context,
      backgroundColor: colorDarkCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final walletsAsync = ref.watch(walletProvider);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24, right: 24, top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Transaksi Aset', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),

                    // Tipe Transaksi
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Beli', style: TextStyle(color: Colors.white, fontSize: 14)),
                            value: 'BELI',
                            groupValue: txType,
                            activeColor: colorBuy,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) => setModalState(() => txType = val!),
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Jual', style: TextStyle(color: Colors.white, fontSize: 14)),
                            value: 'JUAL',
                            groupValue: txType,
                            activeColor: colorSell,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (val) => setModalState(() => txType = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Identitas Aset
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: tickerController,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              labelText: 'Ticker (BTC)',
                              labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorAccentOrange)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: nameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Nama (Bitcoin)',
                              labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorAccentOrange)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Kategori Aset
                    DropdownButton<String>(
                      value: assetType,
                      dropdownColor: colorDarkBase,
                      isExpanded: true,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      underline: Container(height: 1, color: Colors.white10),
                      items: assetTypes.map((t) => DropdownMenuItem(value: t, child: Text(t.replaceAll('_', ' ')))).toList(),
                      onChanged: (val) => setModalState(() => assetType = val!),
                    ),
                    const SizedBox(height: 16),

                    // Unit dan Harga
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: unitsController,
                            style: const TextStyle(color: colorAccentTeal, fontWeight: FontWeight.bold, fontSize: 18),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Jumlah Unit',
                              labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorAccentTeal)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: priceController,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Harga per Unit (Rp)',
                              labelStyle: TextStyle(color: Colors.white54, fontSize: 12),
                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
                              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: colorAccentTeal)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Integrasi Arus Kas
                    Row(
                      children: [
                        Checkbox(
                          value: useWallet,
                          activeColor: colorAccentOrange,
                          onChanged: (val) => setModalState(() => useWallet = val!),
                        ),
                        Text(txType == 'BELI' ? 'Potong saldo dompet' : 'Masukkan ke dompet', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                    if (useWallet)
                      walletsAsync.when(
                        data: (wallets) {
                          if (wallets.isEmpty) return const Text('Buat dompet dulu di menu Wallets!', style: TextStyle(color: colorSell));
                          selectedWalletId ??= wallets.first.id;
                          return DropdownButton<String>(
                            value: selectedWalletId,
                            dropdownColor: colorDarkBase,
                            isExpanded: true,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            underline: Container(height: 1, color: Colors.white10),
                            items: wallets.map((w) => DropdownMenuItem(value: w.id, child: Text('${w.name} (${w.type.name})'))).toList(),
                            onChanged: (val) => setModalState(() => selectedWalletId = val),
                          );
                        },
                        loading: () => const LinearProgressIndicator(color: colorAccentOrange),
                        error: (e, s) => Text('Error load dompet: $e', style: const TextStyle(color: colorSell)),
                      ),
                    
                    const SizedBox(height: 32),

                    // Tombol Simpan Eksekusi
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorAccentOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          final units = double.tryParse(unitsController.text.trim());
                          final price = double.tryParse(priceController.text.trim());
                          final ticker = tickerController.text.trim();
                          final name = nameController.text.trim();

                          if (units == null || units <= 0 || price == null || price <= 0 || ticker.isEmpty || name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Isi semua data dengan valid!')));
                            return;
                          }

                          ref.read(assetTransactionProvider.notifier).recordTransaction(
                            assetName: name,
                            assetType: assetType,
                            tickerSymbol: ticker,
                            txType: txType,
                            units: units,
                            pricePerUnit: price,
                            walletId: useWallet ? selectedWalletId : null,
                          );
                          Navigator.pop(context);
                        },
                        child: const Text('EKSEKUSI TRANSAKSI', style: TextStyle(color: colorDarkBase, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }
}
