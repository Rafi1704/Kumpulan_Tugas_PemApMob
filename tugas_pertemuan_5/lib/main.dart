
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Stok Barang',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const StokBarangPage(),
    );
  }
}

class StokBarangPage extends StatefulWidget {
  const StokBarangPage({super.key});

  @override
  State<StokBarangPage> createState() => _StokBarangPageState();
}

class _StokBarangPageState extends State<StokBarangPage> {
  final _formKey = GlobalKey<FormState>();

  final _namaController = TextEditingController();
  final _tanggalMasukController = TextEditingController();
  final _tanggalKeluarController = TextEditingController();
  final _kodeController = TextEditingController();
  final _stokController = TextEditingController();

  bool _isSaving = false;

  final CollectionReference<Map<String, dynamic>> _collection =
  FirebaseFirestore.instance.collection('stok_barang');

  Future<void> _simpanBarang() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final String namaBarang = _namaController.text.trim();
      final String tanggalMasuk =
      _tanggalMasukController.text.trim();
      final String tanggalKeluar =
      _tanggalKeluarController.text.trim();

      // Kode barang harus sesuai dua digit terakhir NIM: 26.
      final int kodeBarang =
      int.parse(_kodeController.text.trim());

      final int jumlahStok =
      int.parse(_stokController.text.trim());

      await _collection.add({
        'nama_barang': namaBarang,
        'tanggal_masuk': tanggalMasuk,
        'tanggal_keluar': tanggalKeluar,
        'kode_barang': kodeBarang,
        'jumlah_stok': jumlahStok,
        'waktu': FieldValue.serverTimestamp(),
      });

      _formKey.currentState!.reset();
      _namaController.clear();
      _tanggalMasukController.clear();
      _tanggalKeluarController.clear();
      _kodeController.clear();
      _stokController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Barang berhasil disimpan ke Firebase!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan barang: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _tanggalMasukController.dispose();
    _tanggalKeluarController.dispose();
    _kodeController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.inventory_2_outlined),
        ),
        validator: validator ??
                (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label wajib diisi';
              }
              return null;
            },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencatatan Stok Barang'),
        backgroundColor:
        Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.inventory,
                size: 70,
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              const Text(
                'Form Input Stok Barang',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Muhammad Rafi Andaresta Pratama',
                textAlign: TextAlign.center,
              ),
              const Text(
                'NIM: 20240801126',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              _buildField(
                label: 'Nama Barang',
                controller: _namaController,
                hint: 'Masukkan nama barang',
              ),

              _buildField(
                label: 'Tanggal Masuk Barang',
                controller: _tanggalMasukController,
                hint: 'Contoh: 16-10-2026',
              ),

              _buildField(
                label: 'Tanggal Keluar Barang',
                controller: _tanggalKeluarController,
                hint: 'Contoh: 17-10-2026',
              ),

              _buildField(
                label: 'Kode Barang',
                controller: _kodeController,
                hint: 'Masukkan kode barang: 26',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Kode Barang wajib diisi';
                  }

                  final int? kode = int.tryParse(value.trim());

                  if (kode == null) {
                    return 'Kode barang harus bilangan bulat';
                  }

                  if (kode != 26) {
                    return 'Kode barang harus 26 sesuai NIM';
                  }

                  return null;
                },
              ),

              _buildField(
                label: 'Jumlah Stok',
                controller: _stokController,
                hint: 'Masukkan jumlah stok',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Jumlah Stok wajib diisi';
                  }

                  final int? stok = int.tryParse(value.trim());

                  if (stok == null) {
                    return 'Jumlah stok harus bilangan bulat';
                  }

                  if (stok < 0) {
                    return 'Jumlah stok tidak boleh negatif';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 8),

              ElevatedButton.icon(
                onPressed: _isSaving ? null : _simpanBarang,
                icon: _isSaving
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.save),
                label: Text(
                  _isSaving ? 'Menyimpan...' : 'Simpan Barang',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
