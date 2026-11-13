import 'dart:io';

void main() {
  // Katalog toko oleh-oleh di Medan menggunakan Map<String, record>
  final Map<String, ({String nama, String kategori, int harga})> katalog = {
    'P01': (nama: 'Kopi Sidikalang 250 g', kategori: 'Kopi', harga: 45000),
    'P02': (nama: 'Kopi Gayo 250 g', kategori: 'Kopi', harga: 55000),
    'P03': (nama: 'Teh Kayu Aro 100 g', kategori: 'Teh', harga: 25000),
    'P04': (nama: 'Gula Aren 500 g', kategori: 'Pemanis', harga: 30000),
    'P05': (nama: 'Bolu Meranti', kategori: 'Makanan', harga: 80000),
  };

  print('========================================');
  print('          KATALOG TOKO OLEH-OLEH        ');
  print('========================================');
  print('${'Kode'.padRight(6)} | ${'Nama Produk'.padRight(22)} | ${'Kategori'.padRight(10)} | ${'Harga'.padLeft(10)}');
  print('-' * 56);

  // Tampilkan katalog sebagai tabel rapi menggunakan padRight/padLeft[cite: 27]
  for (final entry in katalog.entries) {
    final kode = entry.key;
    final produk = entry.value;
    print(
      '${kode.padRight(6)} | '
      '${produk.nama.padRight(22)} | '
      '${produk.kategori.padRight(10)} | '
      'Rp ${produk.harga.toString().padLeft(8)}',
    );
  }
  print('========================================');

  stdout.write('Masukkan Pesanan (contoh: P01x2, P03x1): ');
  final String input = stdin.readLineSync() ?? '';

  if (input.trim().isEmpty) {
    print('Pesanan kosong.');
    return;
  }

  // Pecah input dengan split(',') lalu split('x') untuk tiap item[cite: 27]
  final List<String> itemMentah = input.split(',');
  final List<({String kode, int jumlah})> pesananValid = [];
  final List<String> itemDitolak = [];

  for (var rawItem in itemMentah) {
    final parts = rawItem.trim().split('x');
    if (parts.length != 2) {
      itemDitolak.add(rawItem.trim());
      continue;
    }

    final kode = parts[0].trim().toUpperCase();
    final jumlah = int.tryParse(parts[1].trim());

    // Cari produk dengan katalog[kode] dan tangani input tidak valid agar tidak crash[cite: 27, 28]
    if (!katalog.containsKey(kode) || jumlah == null || jumlah <= 0) {
      itemDitolak.add(rawItem.trim());
    } else {
      pesananValid.add((kode: kode, jumlah: jumlah));
    }
  }

  // Hitung subtotal tiap item (.map) dan total keseluruhan (.fold)
  final List<({String nama, int hargaSatuan, int jumlah, int subtotal, String kategori})> rincianBelanja =
      pesananValid.map((item) {
    // Operator ! aman digunakan karena kuncinya sudah divalidasi dengan containsKey di atas
    final produk = katalog[item.kode]!;
    final subtotal = produk.harga * item.jumlah;
    return (
      nama: produk.nama,
      hargaSatuan: produk.harga,
      jumlah: item.jumlah,
      subtotal: subtotal,
      kategori: produk.kategori,
    );
  }).toList();

  final int totalBelanja = rincianBelanja.fold<int>(
    0,
    (sum, item) => sum + item.subtotal,
  );

  // Diskon 10% jika total belanja >= Rp 100.000
  final bool dapatDiskon = totalBelanja >= 100000;
  final double diskon = dapatDiskon ? totalBelanja * 0.10 : 0.0;
  final double totalBayar = totalBelanja - diskon;

  // Set kategori produk yang dibeli[cite: 28]
  final Set<String> kategoriDibeli = rincianBelanja.map((e) => e.kategori).toSet();

  print('\n========================================');
  print('              STRUK BELANJA             ');
  print('========================================');
  for (final rincian in rincianBelanja) {
    print('${rincian.nama} x${rincian.jumlah}');
    print('  @Rp ${rincian.hargaSatuan} = Rp ${rincian.subtotal.toString().padLeft(8)}');
  }
  print('-' * 40);
  print('Total Belanja  : Rp ${totalBelanja.toStringAsFixed(0)}');
  if (dapatDiskon) {
    print('Diskon (10%)   : Rp ${diskon.toStringAsFixed(0)}');
  } else {
    print('Diskon (10%)   : Rp 0 (Belanja min. Rp 100rb)');
  }
  print('Total Bayar    : Rp ${totalBayar.toStringAsFixed(0)}');
  print('----------------------------------------');
  print('Kategori Produk yang Dibeli : ${kategoriDibeli.join(', ')}');
  if (itemDitolak.isNotEmpty) {
    print('Item Ditolak/Tidak Valid    : ${itemDitolak.join(', ')}');
  }
  print('========================================');
  print('      TERIMA KASIH TELAH BERBELANJA     ');
  print('========================================');
}