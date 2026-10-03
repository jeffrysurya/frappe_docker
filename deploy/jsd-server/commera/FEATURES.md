# Fitur App Commera

Dokumentasi ini merangkum fitur-fitur yang tersedia di app
[`bwhtech/commera`](https://github.com/bwhtech/commera) — app yang dipakai
pada stack `commera` di `jsd-server` (lihat [README.md](../README.md) untuk
detail deployment). Sumber: source code & `SETUP_GUIDE.md` di repo
`bwhtech/commera` (tag `v16-beta.1`).

Untuk **cara memakainya** — flowchart setup sampai checkout, input & rekonsiliasi
stok, laporan penjualan, dan penanganan return — lihat
[OPERATIONS.md](OPERATIONS.md). Untuk **arti tiap field & checkbox** di setiap
DocType Commera, lihat [CONFIGURATION.md](CONFIGURATION.md).

Commera mengubah site ERPNext menjadi toko online lengkap: storefront yang
di-render server-side (Jinja + Tailwind + Alpine, tanpa SPA) untuk pembeli,
dan dashboard merchant Vue 3 + Frappe UI untuk pengelola toko. ERPNext tetap
jadi satu-satunya sumber data — stok, harga, pajak, dan akuntansi tidak
pernah jadi salinan kedua yang bisa "ngambang" beda dari data aslinya.

Dua companion app wajib diinstal bersama Commera:
[`bwh_payments`](https://github.com/bwhtech/bwh_payments) (payment gateway)
dan [`bwh_shipping`](https://github.com/bwhtech/bwh_shipping) (shipping
carrier). Urutan install: `erpnext` → `bwh_payments` → `bwh_shipping` →
`commera`.

## 1. Storefront (untuk pembeli)

- **Server-rendered, cepat, SEO-friendly** — Jinja/Alpine/Tailwind, tanpa
  payload SPA di antara pembeli dan halaman produk.
- **Bilingual + RTL-ready** — Bahasa berbasis URL (`/en/`, `/ar/`) memakai
  sistem translasi native Frappe, layout right-to-left didukung penuh (bukan
  tempelan).
- **Themeable tanpa fork** — Theme adalah data: record `Shop Theme` + folder
  template. Theme bisa punya route sendiri, mewajibkan login per-route, dan
  override halaman bawaan apa pun — jadi toko bisa restyle checkout tanpa
  maintain fork.
- **Halaman yang tersedia**: home/landing (`index`), listing produk
  (`products/list`), detail produk (`products/details`), keranjang
  (`cart/cart`), checkout (`cart/checkout`), akun (`account/dashboard`,
  `profile`, `address`, `wishlist`), custom content page (`shop_web_page`).
- **Guest checkout maupun akun terdaftar** didukung.
- **Wishlist**, alamat pengiriman tersimpan, riwayat & status pesanan dari
  halaman akun pembeli.
- **Back-in-stock notification** — pembeli bisa subscribe notifikasi saat
  produk yang habis stok tersedia lagi (`OOS Notify Subscription`).
- **Size chart** per item/item group.
- **Merchandising**: hero banner landing page, promo banner, recommended
  variants.
- **Multi-store / pickup lokasi fisik** — mendukung beberapa lokasi toko
  fisik untuk opsi pickup saat checkout.

## 2. Katalog produk & varian

- **Style Attribute Configurator (SAC)** — model satu template pakaian
  (misal: kaos) dengan atribut warna & ukuran, lalu generate dan publish
  semua variannya (SKU) sekaligus, tidak perlu bikin manual satu-satu.
- **Color swatch** — atribut warna bisa ditampilkan sebagai swatch visual,
  bukan cuma teks, lengkap dengan editor swatch-nya.
- **Bulk publish variants** — publish banyak varian/template sekaligus dari
  dashboard (tab Bulk Actions/Import di Commera Settings, atau tombol
  "Publish Variants for All Templates").
- **Bulk image upload** — upload gambar produk dalam jumlah banyak sekaligus,
  lengkap dengan log hasil upload.
- **Ecommerce Category & mapping ke Item Group** — struktur kategori
  storefront terpisah dari Item Group ERPNext tapi bisa dipetakan.
- **Product review & rating** — pembeli bisa memberi ulasan produk; ada
  antrean moderasi ulasan di dashboard (Reviews / Review Detail).

## 3. Dashboard Merchant (`/commera`, Vue 3 + Frappe UI)

Terdaftar di layar desk apps ERPNext, jadi tampil berdampingan dengan
ERPNext, bukan aplikasi terpisah yang harus dibuka manual.

- **Overview** — ringkasan revenue, jumlah order, dan apa yang perlu
  di-fulfill, dibandingkan dengan periode sebelumnya.
- **Orders** — filter berdasarkan belum di-fulfill, belum dibayar, open,
  atau closed; bisa drill-down ke status pembayaran & pengiriman per order.
- **Products** — kelola template, varian, harga, dan inventory, termasuk
  bulk publish & bulk image upload.
- **Customers** — profil dan riwayat pelanggan.
- **Collections & Attributes** — struktur katalog (kategori, atribut warna/
  ukuran), bisa diedit tanpa masuk ke desk ERPNext.
- **Pricing & Inventory/Adjustments** — kelola harga dan penyesuaian stok.
- **Analytics** — funnel revenue, inventory, dan storefront (lihat bagian 5).
- **Storefront** — ganti theme, susun menu navigasi, edit halaman konten
  dengan live preview.
- **Reviews** — kelola/moderasi ulasan produk.

## 4. Pembayaran & Pengiriman (via companion apps)

Provider dikonfigurasi dari dashboard (bukan dari desk), masing-masing
punya kredensial sendiri dan bisa diaktif/nonaktifkan independen. Callback
gateway bersifat idempotent, jadi webhook yang terkirim ulang saat pembeli
kembali ke situs tidak akan menagih dobel.

**Payment** (`bwh_payments`):

- Razorpay — kartu, UPI, netbanking, wallet (India).
- Stripe — kartu & wallet, global.
- Telr — kartu & metode lokal di kawasan GCC.
- Tabby — buy-now-pay-later 4x cicilan (MENA); via app tambahan
  `tabby_frappe`.
- Cash on Delivery — dengan biaya sendiri, threshold bebas biaya, dan akun
  akuntansi tujuan booking-nya.

**Shipping** (`bwh_shipping`):

- Shiprocket — agregator kurir domestik India, cek serviceability per
  kode pos.
- AfterShip — label & tracking global lintas ratusan kurir.
- Setiap carrier quote ongkir sendiri saat checkout; delivery option
  mengatur apa yang bisa dipilih pembeli.

## 5. Analytics

- **Storefront tracking (first-party)** — data tidak keluar dari situs,
  menjadi sumber report Storefront di dashboard.
- **Google Analytics 4** — event `page_view`, `view_item`, `add_to_cart`,
  `begin_checkout`, `purchase`; dengan service account + measurement ID,
  dashboard bisa membaca balik datanya lewat GA4 Data API.
- **Meta Pixel** — event `PageView`, `ViewContent`, `AddToCart`,
  `InitiateCheckout`, `Purchase`; dengan access token, dashboard membaca
  balik datanya lewat Graph API.
- Kedua integrasi eksternal (GA4, Meta) opsional dan nonaktif sampai API
  key diisi. Karena dashboard membaca datanya balik (bukan cuma mengirim),
  funnel-nya tampil berdampingan dengan angka revenue asli, bukan cuma di
  tab lain.
- **Custom tracking script** — bisa menyisipkan script tracking pihak
  ketiga tambahan.

## 6. Returns & Refunds

- Return reason yang bisa dikonfigurasi.
- Return delivery note dan partial refund yang dibukukan kembali ke
  ERPNext (bukan pencatatan terpisah).

## 7. Search

- Index pencarian atas katalog yang bisa dikonfigurasi (field mana yang
  diindeks, bagaimana hasil dipetakan), di-rebuild setiap malam.

## 8. SEO & AI discoverability

- Metadata per-halaman.
- `sitemap.xml` yang di-generate otomatis (termasuk versi segmented).
- `llms.txt` untuk discoverability oleh AI crawler.
- Open Graph image yang di-render dari template saat request (bukan file
  statis).

## 9. Administrasi & konfigurasi (Desk)

Semua bisa diatur dari **Desk → Commera Ecommerce**, sebagian besar juga
punya panel di dashboard `/commera`:

- **Commera Settings** — pengaturan utama: price list, warehouse, shipping
  & returns, pengaturan COD, payment mode, email, item group mapping.
- **Landing Page Settings** — hero banner & seksi promosi halaman utama.
- **Shop Theme / Shop Themed Route / Shop Theme Settings** — manajemen
  theme & routing-nya.
- **Size Chart**.
- **Analytics Settings** — koneksi GA4/Meta & custom tracking script.
- **Bulk Image Upload / Bulk Publish Variants / Style Attribute
  Configurator** — tools operasional katalog skala besar.
- **OG Image Template** — template Open Graph image.
- Konfigurasi footer & navbar toko (`Footer Section Config`,
  `Footer Link`, `Navbar` di Commera Settings), lengkap dengan halaman
  live-preview editor-nya.

## Catatan versi

- Membutuhkan Frappe `>=16,<17` dan ERPNext (stok/harga/pajak/akuntansi).
- `commera` dipin ke tag `v16-beta.1` (rilis beta pertama untuk v16).
  `bwh_payments` dan `bwh_shipping` di upstream baru punya branch
  `develop`/`main` (belum ada `version-16`/tag rilis), jadi keduanya tetap
  dipin ke `develop` (lihat [`apps.json`](apps.json) dan catatan di
  [README.md](../README.md)).
- `commera` sengaja tidak memasukkan `frappe/payments` ke `required_apps`
  — `bwh_payments` menyediakan Payment Gateway Profile/base class sendiri.
