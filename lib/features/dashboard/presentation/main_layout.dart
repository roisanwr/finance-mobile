import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_provider.dart';
import '../../wallets/presentation/wallet_screen.dart';
import '../../transactions/presentation/transaction_screen.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _currentIndex = 0;

  // Daftar halaman sementara (Dummy Screens)
  final List<Widget> _pages = [
    const _DummyPage(title: 'Dashboard Utama', icon: Icons.dashboard),
    const WalletScreen(),
    const TransactionScreen(),
    const _DummyPage(title: 'Portofolio Investasi', icon: Icons.trending_up),
  ];

  @override
  Widget build(BuildContext context) {
    // Menggunakan palet gelap agar senada dengan layar login
    const colorDarkBase = Color(0xFF101214);
    const colorAccentTeal = Color(0xFF00D2CC);

    return Scaffold(
      backgroundColor: colorDarkBase,
      appBar: AppBar(
        backgroundColor: colorDarkBase,
        elevation: 0,
        title: Text(
          'FINANCE HUB',
          style: TextStyle(
            color: colorAccentTeal.withOpacity(0.8),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white54),
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
            },
          ),
        ],
      ),
      // IndexedStack menahan state halaman agar tidak reload saat berpindah tab
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.05)),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: colorDarkBase,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: colorAccentTeal,
          unselectedItemColor: Colors.white30,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Wallets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.sync_alt),
              label: 'Cashflow',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up),
              label: 'Invest',
            ),
          ],
        ),
      ),
    );
  }
}

// Komponen sementara untuk mengisi konten halaman
class _DummyPage extends StatelessWidget {
  final String title;
  final IconData icon;

  const _DummyPage({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.white10),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Modul sedang dibangun...',
            style: TextStyle(color: Colors.white30, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
