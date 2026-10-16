import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'widgets/app_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Profile Card',
      theme: AppTheme.lightTheme,
      home: const ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Digit terakhir NIM: 6
  static const int d = 6;

  // Perhitungan ukuran berdasarkan NIM
  static const double cardPadding = 16.0 + d;
  static const double cardRadius = 8.0 + d;
  static const double buttonHeight = 40.0 + d;
  static const double buttonRadius = 4.0 + d;
  static const double avatarSize = 40.0 + (2 * d);
  static const double nameNimSpacing = 8.0 + d;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Profile Card'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                cardRadius,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(
                cardPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar profil
                  CircleAvatar(
                    radius: avatarSize / 2,
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(
                      Icons.person,
                      size: avatarSize / 1.5,
                      color: Colors.blue,
                    ),
                  ),

                  // Nama mahasiswa
                  SizedBox(height: nameNimSpacing),
                  const Text(
                    'Muhammad Rafi Andaresta Pratama',
                  ),

                  // NIM
                  const Text(
                    'NIM: 20240801126',
                  ),

                  // Program studi
                  const SizedBox(height: 8),
                  const Text(
                    'Program Studi Teknik Informatika',
                  ),

                  // Deskripsi diri
                  const SizedBox(height: 8),
                  const Text(
                    'Saya adalah mahasiswa Teknik Informatika '
                        'yang tertarik mempelajari pemrograman, '
                        'teknologi, dan pengembangan aplikasi.',
                    textAlign: TextAlign.center,
                  ),

                  // Tombol GitHub
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Kunjungi GitHub Saya',
                    icon: Icons.code,
                    url: 'https://github.com/Pratama-1703',
                    height: buttonHeight,
                    borderRadius: buttonRadius,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}