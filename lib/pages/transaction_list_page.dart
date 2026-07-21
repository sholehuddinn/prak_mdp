import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import 'transaction_form_page.dart';
import '../database/database_helper.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  /// Memuat semua data transaksi dari local DummyData list.
  /// Memuat semua data transaksi dari database SQLite.
  Future<void> loadTransactions() async {
    setState(() {
      _isLoading = true;
    });
// Ambil data dari SQLite
    List<Transaction> transactions = await DatabaseHelper.instance
        .getAllTransactions();
    setState(() {
      _transactions = transactions;
      _isLoading = false;
    });
  }

  /// Navigasi ke halaman Edit Transaksi.
  Future<void> handleEdit(Transaction transaction) async {
    // Fitur modul selanjutnya
  }

  /// Menghapus transaksi dengan konfirmasi dialog.
  Future<void> handleDelete(Transaction transaction) async {
    // Fitur modul selanjutnya
  }

  /// Format angka menjadi format Rupiah.
  String _formatRupiah(double value) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(value);
  }

  /// Format tanggal menjadi format Indonesia.
  String _formatTanggal(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  /// Format nominal dengan tanda + atau - sesuai jenis transaksi.
  String _formatNominal(Transaction transaction) {
    bool isPemasukan = transaction.jenis.toLowerCase() == 'pemasukan';
    return '${isPemasukan ? '+' : '-'}${_formatRupiah(transaction.nominal)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Transaksi',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              // Tampilan ketika belum ada transaksi
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada transaksi',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              // Daftar transaksi menggunakan ListView.builder
              : RefreshIndicator(
                  onRefresh: loadTransactions,
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: _transactions.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1.0,
                      thickness: 1.0,
                      indent: 70,
                      color: Color(0xFFEEEEEE),
                    ),
                    itemBuilder: (context, index) {
                      Transaction transaction = _transactions[index];

                      bool isPemasukan =
                          transaction.jenis.toLowerCase() == 'pemasukan';
                      Color jenisColor = isPemasukan
                          ? const Color(0xFF2E7D32)
                          : const Color(0xFFC62828);
                      IconData jenisIcon = isPemasukan
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: jenisColor.withValues(alpha: 0.1),
                          child: Icon(jenisIcon, color: jenisColor, size: 24),
                        ),
                        title: Text(
                          transaction.keterangan ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 12,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatTanggal(transaction.tanggal),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatNominal(transaction),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: jenisColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.more_vert,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    handleEdit(transaction);
                                  }
                                  if (value == 'delete') {
                                    handleDelete(transaction);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 18),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Hapus',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TransactionFormPage(),
            ),
          );
          loadTransactions();
        },
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}