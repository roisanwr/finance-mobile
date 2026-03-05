import 'dart:ui'; // Wajib untuk BackdropFilter (blur effect)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Palet Warna Futuristik
  static const colorDarkBase = Color(0xFF101214);
  static const colorDarkCard = Color(0xFF1A1D21);
  static const colorAccentOrange = Color(0xFFFF9F43);
  static const colorAccentTeal = Color(0xFF00D2CC);
  static const colorTextGlow = Color(0x3300D2CC); // Faint teal glow

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth(bool isLogin) async {
    // Logic validasi kosongkan biar UI fokus...
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi dulu dong datanya, G!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authRepo = ref.read(authRepositoryProvider);
      if (isLogin) {
        await authRepo.signIn(_emailController.text, _passwordController.text);
      } else {
        await authRepo.signUp(_emailController.text, _passwordController.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registrasi sukses! Silakan login.')),
          );
        }
      }
    } on AuthException catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.redAccent),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error gaib: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar untuk responsivitas dasar
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colorDarkBase, // Latar belakang gelap absolut
      body: Stack(
        children: [
          // 1. Ornamen Geometris Latar Belakang (Faint Glow Lines)
          Positioned(
            top: screenSize.height * 0.1,
            left: -screenSize.width * 0.2,
            child: Icon(
              Icons.blur_circular,
              size: screenSize.width * 0.8,
              color: colorAccentTeal.withOpacity(0.05),
            ),
          ),
          Positioned(
            bottom: -screenSize.height * 0.1,
            right: -screenSize.width * 0.1,
            child: Icon(
              Icons.grain,
              size: screenSize.width * 0.6,
              color: colorAccentOrange.withOpacity(0.05),
            ),
          ),

          // 2. Konten Utama
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // --- AREA LOGO FUTURISTIK ---
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glowing Ring
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colorAccentTeal.withOpacity(0.2),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                      ),
                      // Combined Abstract Icons (Dollar & Bitcoin)
                      // Combined Abstract Icons (Dollar & Bitcoin)
                      SizedBox(
                        width: 70,
                        height: 60,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 0,
                              child: Icon(
                                Icons.attach_money,
                                size: 50,
                                color: colorAccentTeal.withOpacity(0.7),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: Icon(
                                Icons.currency_bitcoin,
                                size: 55,
                                color: colorAccentOrange.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'FINANCE HUB',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2.0,
                      shadows: [
                        Shadow(color: colorAccentTeal, blurRadius: 10),
                      ], // Glow effect on text
                    ),
                  ),
                  const SizedBox(height: 50),

                  // --- KOTAK INPUT (GLASSMORPHISM STYLE) ---
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 10,
                        sigmaY: 10,
                      ), // Efek buram latar belakang
                      child: Container(
                        padding: const EdgeInsets.all(30.0),
                        decoration: BoxDecoration(
                          color: colorDarkCard.withOpacity(
                            0.8,
                          ), // Semi-transparan
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.05),
                          ), // Border tipis
                        ),
                        child: Column(
                          children: [
                            _buildFuturisticInput(
                              controller: _emailController,
                              label: 'EMAIL ADDRESS',
                              icon: Icons.alternate_email,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 25),
                            _buildFuturisticInput(
                              controller: _passwordController,
                              label: 'SECURE PASSWORD',
                              icon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.white30,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),

                            // --- TOMBOL LOGIN GRADIEN (OREN-IJO) ---
                            if (_isLoading)
                              const CircularProgressIndicator(
                                color: colorAccentTeal,
                              )
                            else
                              Container(
                                width: double.infinity,
                                height: 55,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  gradient: const LinearGradient(
                                    colors: [
                                      colorAccentOrange,
                                      colorAccentTeal,
                                    ], // Gradien Oren-Ijo
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorAccentTeal.withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () => _handleAuth(true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors
                                        .transparent, // Transparan agar gradien terlihat
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text(
                                    'LOGIN TO HUB',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // --- AREA REGISTRASI ---
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'New here, G?',
                        style: TextStyle(color: Colors.white60),
                      ),
                      TextButton(
                        onPressed: () => _handleAuth(false),
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                            color: colorAccentTeal,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: colorTextGlow, blurRadius: 5),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Pembantu untuk Membuat Input Field Futuristik
  Widget _buildFuturisticInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white30,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          cursorColor: colorAccentTeal,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: colorAccentTeal.withOpacity(0.5),
              size: 20,
            ),
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white10),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: colorAccentTeal, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
