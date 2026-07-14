class Transaction {
  final int id; // Tipe data integer
  final DateTime tanggal; // Tipe data tanggal/waktu (DateTime)
  final double nominal; // Tipe data angka desimal (double) untuk jumlah uang
  final String? keterangan; // Tipe data teks (String) untuk catatan transaksi (bolehbernilai null)
  final String jenis; // Tipe data teks (String): "Pemasukan" atau "Pengeluaran"
// Digunakan untuk membuat/menginstansiasi Object dari Class ini
  Transaction({
    required this.id,
    required this.tanggal,
    required this.nominal,
    this.keterangan,
    required this.jenis,
  });
}

class DummyData {
// Menyimpan data di static field agar persisten (bisa dimodifikasi / push)
  static final List<Transaction> list = [
    Transaction(
      id: 1,
      tanggal: DateTime.now().subtract(const Duration(days: 2)),
      nominal: 2500000.0,
      keterangan: 'Uang Saku Bulanan',
      jenis: 'Pemasukan',
    ),
    Transaction(
      id: 2,
      tanggal: DateTime.now().subtract(const Duration(days: 1)),
      nominal: 150000.0,
      keterangan: 'Beli Buku Pemrograman',
      jenis: 'Pengeluaran',
    )
  ];
}