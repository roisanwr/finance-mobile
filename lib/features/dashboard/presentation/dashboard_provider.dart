import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_provider.dart';
import '../data/dashboard_repository.dart';
import '../domain/wallet_balance_model.dart';

// 1. Inject Supabase
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return DashboardRepository(supabase);
});

// 2. Provider untuk mengambil daftar saldo tiap dompet
final dashboardBalancesProvider = FutureProvider<List<WalletBalanceModel>>((
  ref,
) async {
  return ref.read(dashboardRepositoryProvider).fetchWalletBalances();
});

// 3. Provider Turunan (Computed State) untuk menghitung Total Kekayaan
final netWorthProvider = Provider<AsyncValue<double>>((ref) {
  final balancesAsync = ref.watch(dashboardBalancesProvider);

  // Jika data saldo sudah ada, jumlahkan semuanya secara otomatis
  return balancesAsync.whenData((balances) {
    return balances.fold(0.0, (sum, item) => sum + item.balance);
  });
});
