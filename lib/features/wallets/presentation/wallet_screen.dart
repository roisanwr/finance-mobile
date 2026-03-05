import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/wallet_model.dart';
import 'wallet_provider.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  static const colorDarkBase = Color(0xFF101214);
  static const colorDarkCard = Color(0xFF1A1D21);
  static const colorAccentTeal = Color(0xFF00D2CC);
  static const colorAccentOrange = Color(0xFFFF9F43);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Memantau data dari walletProvider
    final walletState = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: colorDarkBase,
      body: walletState.when(
        // KONDISI 1: DATA BERHASIL DIAMBIL
        data: (wallets) {
          if (wallets.isEmpty) {
            return _buildEmptyState();
          }
          return RefreshIndicator(
            color: colorAccentTeal,
            onRefresh: () async => ref.refresh(walletProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: wallets.length,
              itemBuilder: (context, index) {
                final wallet = wallets[index];
                return _buildWalletCard(wallet);
              },
            ),
          );
        },
        // KONDISI 2: SEDANG LOADING
        loading: () => const Center(
          child: CircularProgressIndicator(color: colorAccentTeal),
        ),
        // KONDISI 3: ERROR
        error: (error, stack) => Center(
          child: Text(
            'Terjadi Kesalahan:\n$error',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorAccentTeal,
        child: const Icon(Icons.add, color: colorDarkBase),
        onPressed: () => _showAddWalletModal(context, ref),
      ),
    );
  }

  // Desain Kartu Dompet
  Widget _buildWalletCard(WalletModel wallet) {
    IconData icon;
    Color iconColor;

    // Menentukan ikon berdasarkan tipe dompet
    switch (wallet.type) {
      case WalletType.TUNAI:
        icon = Icons.money;
        iconColor = Colors.greenAccent;
        break;
      case WalletType.BANK:
        icon = Icons.account_balance;
        iconColor = Colors.blueAccent;
        break;
      case WalletType.DOMPET_DIGITAL:
        icon = Icons.phone_android;
        iconColor = colorAccentOrange;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorDarkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          wallet.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          wallet.type.name.replaceAll('_', ' '),
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white30),
      ),
    );
  }

  // Tampilan jika dompet masih kosong
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.white10,
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Dompet',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Klik tombol + di bawah untuk menambah',
            style: TextStyle(color: Colors.white30, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // Modal (Pop-up bawah) untuk tambah dompet
  void _showAddWalletModal(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    WalletType selectedType = WalletType.BANK;

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
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(
                  context,
                ).viewInsets.bottom, // Agar tidak tertutup keyboard
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tambah Dompet Baru',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Input Nama Dompet
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nama Dompet (misal: BCA, GoPay)',
                      labelStyle: const TextStyle(color: Colors.white54),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white10),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: colorAccentTeal),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Dropdown Tipe Dompet
                  const Text(
                    'Tipe Dompet',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  DropdownButton<WalletType>(
                    value: selectedType,
                    dropdownColor: colorDarkBase,
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    underline: Container(height: 1, color: Colors.white10),
                    items: WalletType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.name.replaceAll('_', ' ')),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null)
                        setModalState(() => selectedType = value);
                    },
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
                        if (nameController.text.trim().isEmpty) return;

                        // Panggil fungsi addWallet dari provider
                        ref
                            .read(walletProvider.notifier)
                            .addWallet(
                              nameController.text.trim(),
                              selectedType,
                            );
                        Navigator.pop(context); // Tutup modal
                      },
                      child: const Text(
                        'SIMPAN',
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
