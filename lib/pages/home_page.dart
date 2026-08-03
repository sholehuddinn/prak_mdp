import 'package:flutter/material.dart';
import 'transaction_form_page.dart';
import 'transaction_list_page.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart';
import 'login_page.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String title = 'Money Notes';
  List<Transaction> _recentTransactions = [];
  bool _isLoadingTransactions = true;

  Map<String, String> profileMhs = const {
    'nama': 'M. Fajar Sholehuddin Maulana Putra',
    'nim': '202311420008',
    'kelas': 'Praktikum Mobile Device Programming',
  };

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadRecentTransactions();
  }

  Future<void> _loadUserProfile() async {
    final UserModel? user = await AuthService().getUser();
    if (user != null) {
      setState(() {
        profileMhs = {
          'nama': user.name,
          'nim': user.username,
          'email': user.email,
          'kelas': 'Praktikum Mobile Device Programming',
        };
      });
    }
  }

  Future<void> _loadRecentTransactions() async {
    final transactions = await DatabaseHelper.instance.getRecentTransactions();
    if (!mounted) return;

    setState(() {
      _recentTransactions = transactions;
      _isLoadingTransactions = false;
    });
  }

  Future<void> tampilkanDaftarTransaksi() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TransactionListPage()),
    );
    if (mounted) {
      await _loadRecentTransactions();
    }
  }

  Future<void> tambahTransaksi() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TransactionFormPage()),
    );
    if (mounted) {
      await _loadRecentTransactions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Keluar'),
                  content: const Text(

                    'Apakah Anda yakin ingin keluar dari aplikasi?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),

                      child: const Text('Batal'),

                    ),

                    TextButton(

                      onPressed: () => Navigator.pop(context, true),

                      child: const Text(
                        'Keluar',

                        style: TextStyle(color: Colors.red),

                      ),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await AuthService().logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,

                    MaterialPageRoute(builder: (context) => const LoginPage()),
                        (route) => false,

                  );
                }
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRecentTransactions,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeaderProfile(),
              _buildMainContent(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          tambahTransaksi();
        },
        backgroundColor: const Color(0xFF1565C0),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildHeaderProfile() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1565C0),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
        child: Row(
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2.5,
                ),
                color: Colors.white.withValues(alpha: 0.2),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profileMhs['nama'] ?? '-',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NIM: ${profileMhs['nim']}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    profileMhs['kelas'] ?? '-',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Akses Cepat',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 16),
          _buildMenuCard(
            icon: Icons.receipt_long_outlined,
            title: 'Lihat Transaksi',
            subtitle: 'History Transaksi',
            onTap: () {
              tampilkanDaftarTransaksi();
            },
          ),
          const SizedBox(height: 16),
          const Text(
            '5 Transaksi Terakhir',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 12),
          if (_isLoadingTransactions)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_recentTransactions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Belum ada transaksi yang tersimpan.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentTransactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final transaction = _recentTransactions[index];
                final isPemasukan = transaction.jenis.toLowerCase() == 'pemasukan';
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: isPemasukan
                            ? const Color(0xFF2E7D32).withValues(alpha: 0.15)
                            : const Color(0xFFC62828).withValues(alpha: 0.15),
                        child: Icon(
                          isPemasukan ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isPemasukan ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.keterangan ?? 'Tanpa keterangan',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF263238),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${transaction.tanggal.day}/${transaction.tanggal.month}/${transaction.tanggal.year}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${isPemasukan ? '+' : '-'}Rp ${transaction.nominal.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isPemasukan ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF1565C0),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF263238),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}