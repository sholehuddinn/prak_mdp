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
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedJenis = 'Semua';

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  /// Memuat semua data transaksi dari database SQLite dengan filter.
  Future<void> loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    final filterJenis = _selectedJenis == 'Semua'
        ? 'Semua'
        : _selectedJenis.toLowerCase();

    List<Transaction> transactions = await DatabaseHelper.instance.getAllTransactions(
      startDate: _startDate,
      endDate: _endDate,
      jenis: filterJenis,
    );

    setState(() {
      _transactions = transactions;
      _isLoading = false;
    });
  }

  Future<void> _showFilterDialog() async {
    DateTime? startDate = _startDate;
    DateTime? endDate = _endDate;
    String selectedJenis = _selectedJenis;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Transaksi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setModalState(() {
                                startDate = picked;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(
                            startDate == null
                                ? 'Tanggal Awal'
                                : DateFormat('dd/MM/yyyy').format(startDate!),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: endDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setModalState(() {
                                endDate = picked;
                              });
                            }
                          },
                          icon: const Icon(Icons.event),
                          label: Text(
                            endDate == null
                                ? 'Tanggal Akhir'
                                : DateFormat('dd/MM/yyyy').format(endDate!),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Kategori'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Semua', 'Pemasukan', 'Pengeluaran'].map((jenis) {
                      return ChoiceChip(
                        label: Text(jenis),
                        selected: selectedJenis == jenis,
                        onSelected: (_) {
                          setModalState(() {
                            selectedJenis = jenis;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _startDate = null;
                              _endDate = null;
                              _selectedJenis = 'Semua';
                            });
                            Navigator.pop(context);
                            loadTransactions();
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _startDate = startDate;
                              _endDate = endDate;
                              _selectedJenis = selectedJenis;
                            });
                            Navigator.pop(context);
                            loadTransactions();
                          },
                          child: const Text('Terapkan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Navigasi ke halaman Edit Transaksi.
  Future<void> handleEdit(Transaction transaction) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionFormPage(transaction: transaction),
      ),
    );
    loadTransactions();
  }
  /// Menghapus transaksi dengan konfirmasi dialog.
  Future<void> handleDelete(Transaction transaction) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('Konfirmasi Hapus'),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus transaksi "${transaction.keterangan}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      await DatabaseHelper.instance.deleteTransaction(transaction.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Transaksi berhasil dihapus!'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      loadTransactions();
    }
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
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter transaksi',
          ),
        ],
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