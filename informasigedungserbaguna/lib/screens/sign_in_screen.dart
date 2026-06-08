import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:informasigedungserbaguna/screens/admin_home_screen.dart';
import 'package:informasigedungserbaguna/screens/main_navigation_screen.dart';
import 'package:informasigedungserbaguna/screens/sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String _errorMessage = '';
  bool _isLoading = false;
  bool _passwordVisible = false;

  static const _adminUsername = 'admin';
  static const _adminEmail = 'admin@gmail.com';
  static const _adminPassword = 'admin123';

  // --- STYLE CONSTANTS (Warna & Radius dari Contoh) ---
  final _kHeaderColor = const Color(0xFF8D6E63); // Coklat header
  final _kInputBgColor = const Color(0xFFF7F7F7); // Latar belakang input
  final _kInputRadius = BorderRadius.circular(10.0); // Radius sudut halus
  final _kTextColor = Colors.black87;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang layar putih solid
      // --- AppBar Kustom Sesuai Contoh ---
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: _kHeaderColor, // Warna coklat
        foregroundColor: Colors.white, // Teks putih
        elevation: 1, // Sedikit bayangan
      ),
      // --- Tata Letak Kolom Di Tengah ---
      body: Center(
        child: Container(
          // Membatasi lebar agar mirip dengan contoh web
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            // Padding luar agar tidak mentok ke pinggir
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Input Field Username/Email ---
                Container(
                  decoration: BoxDecoration(
                    color: _kInputBgColor, // Latar belakang abu-abu sangat muda
                    borderRadius: _kInputRadius, // Sudut bulat
                  ),
                  child: TextField(
                    controller: _usernameController,
                    keyboardType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.none,
                    autocorrect: false,
                    style: TextStyle(color: _kTextColor, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText:
                          'Username atau Email', // Menggunakan hintText seperti contoh
                      border: InputBorder.none, // Menghilangkan border standar
                      contentPadding: EdgeInsets.all(
                        16.0,
                      ), // Jarak teks ke dalam input
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                // --- Input Field Password ---
                Container(
                  decoration: BoxDecoration(
                    color: _kInputBgColor,
                    borderRadius: _kInputRadius,
                  ),
                  child: TextField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    style: TextStyle(color: _kTextColor, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16.0),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                // --- Tombol Sign In ---
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity, // Tombol selebar input
                          child: ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                0xFFF0E5F8,
                              ), // Ungu muda pudar dari contoh
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: _kInputRadius,
                              ),
                              elevation: 0, // Tanpa bayangan seperti contoh
                            ),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 16.0),
                // --- Teks Sign Up ---
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.purple[700], // Warna ungu
                    ),
                    child: const Text(
                      "Don't have an account? Sign up",
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- LOGIKA LOGIN (Sama seperti sebelumnya) ---
  void _handleLogin() async {
    final credential = _usernameController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (credential.isEmpty || password.isEmpty) {
      _showError('Username/Email dan Password tidak boleh kosong.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final isAdminUsername = credential == _adminUsername;
    final isAdminEmail = credential == _adminEmail.toLowerCase();
    final isValidAdmin =
        (isAdminUsername || isAdminEmail) && password == _adminPassword;

    if (isValidAdmin) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('admin_logged_in', true);

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AdminHomeScreen()),
      );
      return;
    }

    if (!credential.contains('@')) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Gunakan email untuk login pengguna atau gunakan kredensial admin.';
      });
      _showError(_errorMessage);
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('admin_logged_in');

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _usernameController.text.trim(),
        password: password,
      );

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            e.message ?? 'Gagal melakukan login. Periksa kembali data Anda.';
      });
      _showError(_errorMessage);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
