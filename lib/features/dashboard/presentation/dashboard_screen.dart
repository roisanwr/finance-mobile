import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const colorDarkBase = Color(0xFF101214);
  static const colorDarkCard = Color(0xFF1A1D21);
  static const colorAccentTeal = Color(0xFF00D2CC);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final netWorthAsync = ref.watch(netWorthProvider);
    final balancesAsync = ref.watch(dashboardBalancesProvider);

    return Scaffold(
      backgroundColor: colorDarkBase,
      // Pull-to-refresh agar kamu bisa memuat ulang data dengan menggeser layar ke bawah
      body: RefreshIndicator(
        color: colorAccentTeal,
        onRefresh: () async {
          // Memaksa Riverpod untuk mengambil ulang data terbaru dari Supabase
          ref.invalidate(dashboardBalancesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 10),

            // --- KARTU TOTAL KEKAYAAN (NET WORTH) ---
            _buildNetWorthCard(netWorthAsync),

            const SizedBox(height: 40),
            const Text(
              'ALOKASI ASET',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),

            // --- DAFTAR SALDO PER DOMPET ---
            balancesAsync.when(
              data: (balances) {
                if (balances.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        'Belum ada data.\nCatat transaksimu dulu, G!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white30),
                      ),
                    ),
                  );
                }
                return Column(
                  children: balances
                      .map((b) => _buildBalanceTile(b.name, b.balance))
                      .toList(),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: colorAccentTeal),
              ),
              error: (e, s) => Text(
                'Error: $e',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetWorthCard(AsyncValue<double> netWorthAsync) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorDarkCard, colorDarkBase],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorAccentTeal.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: -5,
          ),
        ],
        border: Border.all(color: colorAccentTeal.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text(
            'TOTAL KEKAYAAN',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          netWorthAsync.when(
            data: (total) => Text(
              'Rp ${total.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(color: colorAccentTeal, blurRadius: 15),
                ], // Glow effect
              ),
            ),
            loading: () =>
                const CircularProgressIndicator(color: colorAccentTeal),
            error: (e, s) => const Text(
              'Error',
              style: TextStyle(color: Colors.redAccent, fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceTile(String name, double balance) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colorDarkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Rp ${balance.toStringAsFixed(0)}',
            style: const TextStyle(
              color: colorAccentTeal,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
