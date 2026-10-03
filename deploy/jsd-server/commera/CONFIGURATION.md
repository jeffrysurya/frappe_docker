# Referensi Konfigurasi Commera (per DocType, per Field)

Dokumen ini adalah **panduan setting**: seluruh 36 DocType milik app
[`bwhtech/commera`](https://github.com/bwhtech/commera), field demi field,
lengkap dengan arti setiap checkbox. Isinya diambil langsung dari definisi
DocType dan kode app (branch `develop`, yang dipakai image `jsd-commera`).

Dokumen pendamping:

- [FEATURES.md](FEATURES.md) — apa saja fiturnya.
- [OPERATIONS.md](OPERATIONS.md) — alur operasional (setup → posting produk →
  checkout → stok → laporan → retur).
- [../README.md](../README.md) — build & deploy image-nya.

---

## Cara membaca dokumen ini

Setiap DocType punya satu tabel dengan kolom:

| Kolom       | Arti                                                          |
| ----------- | ------------------------------------------------------------- |
| **Field**   | Label yang tampil di form, `fieldname` teknis di dalam kurung |
| **Tipe**    | Fieldtype Frappe (Data, Link, Check, Table, …)                |
| **W**       | Wajib diisi (✔ = `reqd`)                                      |
| **Default** | Nilai bawaan saat record baru dibuat                          |
| **Fungsi**  | Apa yang benar-benar berubah kalau field ini diisi/dicentang  |

Istilah yang dipakai:

- **Single** — DocType yang cuma punya satu record untuk seluruh site (contoh:
  Commera Settings). Tidak ada list view, langsung buka formnya.
- **Child table** — DocType yang tidak bisa dibuka sendiri; hanya muncul
  sebagai baris tabel di dalam DocType induknya.
- **Check** — checkbox; nilainya `1` (dicentang) atau `0`.
- **Link** — dropdown yang menunjuk ke record DocType lain.
- **Table** — grid berisi baris child table.

Semua DocType di bawah ada di **Desk → Commera Ecommerce** (modul
`Commera Ecommerce`) atau **Desk → Shop Themes** (modul `Shop Themes`).

---

## Peta cepat 36 DocType

| #   | DocType                                                                                              | Jenis       | Untuk apa                             |
| --- | ---------------------------------------------------------------------------------------------------- | ----------- | ------------------------------------- |
| 1   | [Commera Settings](#1-commera-settings)                                                              | Single      | Pusat konfigurasi toko (76 field)     |
| 2   | [Analytics Settings](#2-analytics-settings)                                                          | Single      | GA4, Meta Pixel, event log internal   |
| 3   | [Custom Tracking Script](#3-custom-tracking-script)                                                  | Child       | Script tracking pihak ketiga          |
| 4   | [Landing Page Settings](#4-landing-page-settings)                                                    | Single      | Halaman depan storefront non-theme    |
| 5   | [Landing Page Hero Banner](#5-landing-page-hero-banner)                                              | Child       | Baris banner hero                     |
| 6   | [Recommended Variant](#6-recommended-variant)                                                        | Child       | Daftar produk pilihan                 |
| 7   | [Shop Theme Settings](#7-shop-theme-settings)                                                        | Single      | Pemilih theme aktif + routing         |
| 8   | [Shop Theme](#8-shop-theme)                                                                          | Biasa       | Definisi satu theme                   |
| 9   | [Shop Themed Route](#9-shop-themed-route)                                                            | Child       | Route custom milik theme              |
| 10  | [Shop Default Theme Settings](#10-shop-default-theme-settings)                                       | Single      | Konten theme "Shop Default Theme"     |
| 11  | [Summer Theme Settings](#11-summer-theme-settings)                                                   | Single      | Konten theme "Summer Theme"           |
| 12  | [Summer Hero Slide](#12-summer-hero-slide)                                                           | Child       | Slide hero Summer Theme               |
| 13  | [Summer Promo Banner](#13-summer-promo-banner)                                                       | Child       | Banner promo Summer Theme             |
| 14  | [Style Attribute Configurator](#14-style-attribute-configurator)                                     | Biasa       | Generator varian dari Item template   |
| 15  | [Style Attribute Variant](#15-style-attribute-variant)                                               | Biasa       | **Produk yang tampil di storefront**  |
| 16  | [Color Size Item](#16-color-size-item)                                                               | Child       | Peta ukuran → Item code               |
| 17  | [Swatch](#17-swatch)                                                                                 | Biasa       | Warna/tekstur untuk atribut           |
| 18  | [Ecommerce Category](#18-ecommerce-category)                                                         | Biasa       | Menu & kategori storefront            |
| 19  | [Ecommerce Category Item Group](#19-ecommerce-category-item-group)                                   | Child       | Item Group tujuan satu menu           |
| 20  | [Item Group Map](#20-item-group-map)                                                                 | Child       | Pemetaan Item Group → Item Group toko |
| 21  | [Size Chart](#21-size-chart)                                                                         | Biasa       | Tabel ukuran per Brand + Item Group   |
| 22  | [Shop Web Page](#22-shop-web-page)                                                                   | Biasa       | Halaman konten statis toko            |
| 23  | [OG Image Template](#23-og-image-template)                                                           | Biasa       | Template gambar share sosmed          |
| 24  | [Return Reason](#24-return-reason)                                                                   | Child       | Pilihan alasan retur                  |
| 25  | [Footer Section Config](#25-footer-section-config)                                                   | Biasa       | Satu kolom footer                     |
| 26  | [Footer Link](#26-footer-link)                                                                       | Child       | Satu link di kolom footer             |
| 27  | [Footer Section Mapping](#27-footer-section-mapping)                                                 | Child       | Urutan kolom footer di toko           |
| 28  | [Search Content Field](#28-search-content-field)                                                     | Child       | Field yang diindeks pencarian         |
| 29  | [Search Result Field](#29-search-result-field)                                                       | Child       | Atribut di kartu hasil pencarian      |
| 30  | [Bulk Image Upload](#30-bulk-image-upload)                                                           | Submittable | Upload gambar massal via ZIP          |
| 31  | [Bulk Image Upload Log](#31-bulk-image-upload-log)                                                   | Log         | Hasil upload gambar                   |
| 32  | [Bulk Publish Variants](#32-bulk-publish-variants)                                                   | Single      | Publish/unpublish varian massal       |
| 33  | [Bulk Style Attribute Configurator Creation Log](#33-bulk-style-attribute-configurator-creation-log) | Log         | Hasil generate configurator massal    |
| 34  | [Style Attribute Configurator Log Table](#34-style-attribute-configurator-log-table)                 | Child       | Baris log di atas                     |
| 35  | [OOS Notify Subscription](#35-oos-notify-subscription)                                               | Log         | Antrean notifikasi stok kembali ada   |
| 36  | [Storefront Analytics Event](#36-storefront-analytics-event)                                         | Log         | Event funnel first-party              |

Ringkasan **semua checkbox** ada di [bagian akhir](#ringkasan-semua-checkbox-23-buah).

---

## 1. Commera Settings

**Desk → Commera Ecommerce → Commera Settings.** Single. Ini pusat konfigurasi
toko — 76 field tersebar di 9 tab.

> ⚠️ **Validasi saat simpan:** Commera menolak menyimpan kalau `COD` tidak
> dicentang **dan** tidak ada satu pun Payment Gateway Profile aktif —
> _"Enable cash on delivery or at least one Payment Gateway Profile before
> saving."_ Artinya toko tidak boleh sama sekali tanpa metode bayar.

> 💡 Sebagian field ini juga bisa diedit dari dashboard `/commera` → Settings.
> Tab **Store details / Shipping / Payment / Footer** di dashboard memakai
> field yang sama; sisanya muncul di tab **Advanced** dashboard, kecuali
> fieldtype Color, Table, Button, dan HTML yang hanya bisa diedit dari Desk.

### Tab utama — Branding

| Field                       | Tipe           |  W  | Default | Fungsi                                                                                                              |
| --------------------------- | -------------- | :-: | ------- | ------------------------------------------------------------------------------------------------------------------- |
| Store Name (`store_name`)   | Data           |     | —       | Nama toko di tab browser & judul situs; juga jadi `{store}` pada template SEO                                       |
| Company (`company`)         | Link → Company |  ✔  | —       | Company ERPNext yang membukukan semua order toko. Menentukan mata uang toko (dipakai juga oleh installer demo data) |
| Brand Logo (`brand_logo`)   | Attach Image   |     | —       | Logo di navigasi header. Dari dashboard, nilainya disimpan ke `Website Settings.banner_image`                       |
| Footer Logo (`footer_logo`) | Attach Image   |     | —       | Logo di footer                                                                                                      |
| Favicon (`favicon`)         | Attach         |     | —       | Ikon tab browser, 16×16 atau 32×32 px                                                                               |

### Tab utama — Cash on Delivery

| Field                                                       | Tipe             |  W  | Default | Fungsi                                                                                                                                                                 |
| ----------------------------------------------------------- | ---------------- | :-: | ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| COD Charge Applicable Below (`cod_charge_applicable_below`) | Currency         |     | —       | Ambang batas: biaya COD ditagih hanya kalau **total order lebih kecil** dari nilai ini. Order di atasnya bebas biaya COD                                               |
| Charge Account Head (`charge_account_head`)                 | Link → Account   |     | —       | Akun GL tempat biaya COD **dan** biaya pengiriman dibukukan di Sales Order/Invoice                                                                                     |
| COD Charge (`cod_charge`)                                   | Currency         |     | —       | Nominal biaya COD. Kosong/0 = COD tanpa biaya                                                                                                                          |
| Ecommerce Warehouse (`ecommerce_warehouse`)                 | Link → Warehouse |     | —       | **Gudang tunggal untuk semua stok & order toko.** Wajib secara praktis: fitur terima stok di dashboard menolak jalan tanpa ini. (Letaknya memang nyempil di seksi COD) |

### Tab utama — Price List

| Field                                     | Tipe              |  W  | Default | Fungsi                                                                                                          |
| ----------------------------------------- | ----------------- | :-: | ------- | --------------------------------------------------------------------------------------------------------------- |
| Default Price List (`default_price_list`) | Link → Price List |     | —       | Price List yang dibaca sebagai harga normal produk                                                              |
| Sale Price List (`sale_price_list`)       | Link → Price List |     | —       | Price List harga diskon. Kalau sebuah item punya harga di sini, storefront menampilkan harga coret + harga sale |

### Tab utama — Product Listing Page

| Field                                   | Tipe                  |  W  | Default | Fungsi                                                                                                    |
| --------------------------------------- | --------------------- | :-: | ------- | --------------------------------------------------------------------------------------------------------- |
| Products Per Page (`products_per_page`) | Select `12 / 24 / 48` |     | `24`    | Jumlah produk per halaman di listing. Pembeli tetap bisa menggantinya lewat dropdown _Show_ di storefront |

### Tab utama — Shipping & Returns

| Field                                                          | Tipe                                       |  W  | Default | Fungsi                                                                                                                        |
| -------------------------------------------------------------- | ------------------------------------------ | :-: | ------- | ----------------------------------------------------------------------------------------------------------------------------- |
| Shipping Rule (`shipping_rule`)                                | Link → Shipping Rule                       |     | —       | Aturan ongkir ERPNext yang dipakai saat checkout (mis. berbasis _Net Total_, gratis ongkir di atas nilai tertentu)            |
| Reason for Return (`reason_for_return`)                        | Table → [Return Reason](#24-return-reason) |     | —       | Daftar alasan retur yang bisa dipilih pembeli                                                                                 |
| Return Period (Days) After Invoice Generated (`return_period`) | Int (≥0)                                   |     | —       | Jumlah hari sejak invoice, selama itu tombol _Return_ muncul di halaman akun pembeli. Kosong/0 = retur mandiri tidak tersedia |
| Print Format (`print_format`)                                  | Link → Print Format                        |     | —       | Print Format untuk PDF invoice yang diunduh pembeli dari halaman order. Kosong = `Standard`                                   |

### Tab utama — Payment Mode

| Field                   | Tipe      |  W  | Default | Fungsi                                                                                                                                                                                                                                                                                     |
| ----------------------- | --------- | :-: | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **COD** (`cod_enabled`) | **Check** |     | `1`     | Centang = metode _Cash on Delivery_ muncul sebagai pilihan di checkout, dan API pembayaran menerima order COD. Tidak dicentang = COD ditolak di sisi server, bukan sekadar disembunyikan. Ingat validasi di atas: mematikannya tanpa payment gateway aktif membuat settings gagal disimpan |

> Gateway online (Razorpay, Stripe, Telr, Tabby) **tidak** diatur di sini —
> tempatnya di `bwh_payments` (Payment Gateway Profile) atau panel Payments di
> dashboard `/commera`.

### Tab: Bulk Actions / Import

| Field                                                                                                                 | Tipe                  |  W  | Default | Fungsi                                                                                                                                                                                                                                                                                   |
| --------------------------------------------------------------------------------------------------------------------- | --------------------- | :-: | ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Create variants automatically on Configurator Creation** (`create_variants_automatically_on_configurator_creation`) | **Check**             |     | `0`     | Centang = setiap kali [Style Attribute Configurator](#14-style-attribute-configurator) baru dibuat, varian langsung digenerate otomatis (`after_insert` → `generate_variants`). Tidak dicentang = harus klik tombol _Generate Variants_ manual di configurator                           |
| Based on Attribute (`based_on_attribute`)                                                                             | Link → Item Attribute |     | —       | Atribut (biasanya `Color`) yang dipakai tombol _Publish Variants for All Templates_ di bawah. Tombol menolak jalan kalau field ini kosong                                                                                                                                                |
| Attribute Name Field (`attribute_name_field`)                                                                         | Data                  |     | —       | **Nama atribut** (teks, bukan link) yang nilainya dipakai sebagai nama tampilan varian saat generate — mis. isi `Colour Name` supaya varian dinamai "Navy Blue" alih-alih kode warna. Kosong/tidak ketemu = pakai nilai atribut utama                                                    |
| Publish Variants for All Templates (`publish_variants_for_all_templates`)                                             | Button                |     | —       | Membuat Style Attribute Configurator untuk **semua Item template** (`has_variants = 1`) yang belum punya configurator, berbasis _Based on Attribute_. Jalan di background queue `long`; hasilnya tercatat di [Bulk SAC Creation Log](#33-bulk-style-attribute-configurator-creation-log) |
| View Logs (`view_logs`)                                                                                               | Button                |     | —       | Pintasan ke list [Bulk SAC Creation Log](#33-bulk-style-attribute-configurator-creation-log)                                                                                                                                                                                             |

### Tab: Search

| Field                                           | Tipe                                                     |  W  | Default | Fungsi                                                                                                                                                                                                                              |
| ----------------------------------------------- | -------------------------------------------------------- | :-: | ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Search Content Fields (`search_content_fields`) | Table → [Search Content Field](#28-search-content-field) |     | —       | Field mana saja yang teksnya digabung jadi bahan index pencarian produk. **Kosong = pakai default** (`Style Attribute Variant`: display_name, attribute_value, item_group + `Item`: brand). Maksimal 15 baris, tidak boleh duplikat |
| Search Result Fields (`search_result_fields`)   | Table → [Search Result Field](#29-search-result-field)   |     | —       | Atribut yang tampil di kartu hasil pencarian. Kosong = layout default (image, name, color, price)                                                                                                                                   |
| Rebuild Search Index (`rebuild_search_index`)   | Button                                                   |     | —       | Membangun ulang seluruh index pencarian di background (ada dialog konfirmasi). Index juga di-rebuild otomatis tiap malam lewat scheduler                                                                                            |

> ⚙️ **Otomatis:** mengubah isi _Search Content Fields_ lalu menyimpan akan
> memicu rebuild index penuh sendiri. Mengubah _Search Result Fields_ tidak —
> itu cuma tampilan, bukan isi index.

### Tab: Search — Demo Data & Testing

| Field                                              | Tipe   |  W  | Default | Fungsi                                                                                                                                                                                           |
| -------------------------------------------------- | ------ | :-: | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Install Demo Data (`install_demo_data`)            | Button |     | —       | Mengisi toko contoh "Summer": katalog, menu, footer, banner, dan settings — dalam mata uang company. Jalan di background (queue `long`, timeout 3000 detik). **Jangan dipakai di site produksi** |
| Publish All Items to Website (`publish_all_items`) | Button |     | —       | Mem-publish semua item ke website dan memperbaiki route-nya. Background, timeout 600 detik                                                                                                       |

### Tab: Search — Item Group

| Field                                                                                    | Tipe                                         |  W  | Default | Fungsi                                                                                                                                            |
| ---------------------------------------------------------------------------------------- | -------------------------------------------- | :-: | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| eCommerce Item Group Mapping (`ecommerce_item_group_mapping`)                            | Table → [Item Group Map](#20-item-group-map) |     | —       | Memetakan Item Group asli (ERPNext) ke Item Group versi toko. Varian baru yang dibuat akan otomatis memakai Item Group hasil pemetaan ini         |
| Sync Item Group Mapping to Existing Items (`sync_item_group_mapping_to_ecommerce_items`) | Button                                       |     | —       | Menerapkan pemetaan di atas ke **varian yang sudah terlanjur ada** (menulis ulang `item_group` di Style Attribute Variant). Ada dialog konfirmasi |

### Tab: Contact Information

| Field                           | Tipe         |  W  | Default | Fungsi                                            |
| ------------------------------- | ------------ | :-: | ------- | ------------------------------------------------- |
| Contact Phone (`contact_phone`) | Data         |     | —       | Nomor telepon toko yang ditampilkan di storefront |
| Contact Email (`contact_email`) | Data (Email) |     | —       | Email kontak toko yang ditampilkan di storefront  |
| Working Hours (`working_hours`) | Data         |     | —       | Teks jam operasional, mis. `Sen–Jum 09.00–17.00`  |

### Tab: Social Media

Semua Data bertipe URL, semuanya opsional. Kosongkan yang tidak dipakai —
ikon sosmed hanya muncul untuk yang terisi.

| Field                           | Fungsi                       |
| ------------------------------- | ---------------------------- |
| Facebook URL (`facebook_url`)   | Link ikon Facebook di footer |
| Twitter/X URL (`twitter_url`)   | Link ikon Twitter/X          |
| Instagram URL (`instagram_url`) | Link ikon Instagram          |
| Snapchat URL (`snapchat_url`)   | Link ikon Snapchat           |
| TikTok URL (`tiktok_url`)       | Link ikon TikTok             |

### Tab: SEO

| Field                                                           | Tipe         |  W  | Default              | Fungsi                                                                                                           |
| --------------------------------------------------------------- | ------------ | :-: | -------------------- | ---------------------------------------------------------------------------------------------------------------- |
| SEO Title Template (`seo_title_template`)                       | Data         |     | `{title} \| {store}` | Pola judul `<title>`/meta seluruh halaman. Placeholder: `{title}` (judul halaman) dan `{store}` (Store Name)     |
| Default Meta Description (`default_meta_description`)           | Small Text   |     | —                    | Meta description cadangan untuk halaman yang tidak mengisinya sendiri                                            |
| Default Share Image (`default_share_image`)                     | Attach Image |     | —                    | Gambar Open Graph/Twitter cadangan. Rekomendasi 1200×630                                                         |
| Homepage Meta Title (`homepage_meta_title`)                     | Data         |     | —                    | Judul meta khusus halaman depan                                                                                  |
| Homepage Meta Description (`homepage_meta_description`)         | Small Text   |     | —                    | Meta description halaman depan                                                                                   |
| Homepage OG Image (`homepage_og_image`)                         | Attach Image |     | —                    | Gambar share halaman depan (1200×630)                                                                            |
| Product List Meta Title (`product_list_meta_title`)             | Data         |     | —                    | Judul meta halaman listing semua produk                                                                          |
| Product List Meta Description (`product_list_meta_description`) | Small Text   |     | —                    | Meta description halaman listing                                                                                 |
| Product List OG Image (`product_list_og_image`)                 | Attach Image |     | —                    | Gambar share halaman listing (1200×630)                                                                          |
| Twitter Handle (`twitter_handle`)                               | Data         |     | —                    | Handle `@akun` untuk `twitter:site` dan `twitter:creator` — **sertakan tanda `@`**                               |
| Sitemap URLs Per Page (`sitemap_urls_per_page`)                 | Int          |     | `50000`              | Maksimum URL per file sitemap. Batas resmi sitemaps.org memang 50.000; biarkan default kecuali ada alasan khusus |
| llms.txt Content (`llms_txt`)                                   | Code         |     | —                    | Isi yang disajikan di `/llms.txt` untuk AI crawler. Kosong = pakai isi bawaan app                                |

### Tab: Footer Customization

| Field                                             | Tipe                                                         |  W  | Default | Fungsi                                                                                                        |
| ------------------------------------------------- | ------------------------------------------------------------ | :-: | ------- | ------------------------------------------------------------------------------------------------------------- |
| Newsletter Title (`newsletter_title`)             | Data                                                         |     | —       | Judul blok langganan newsletter di footer                                                                     |
| Newsletter Description (`newsletter_description`) | Text                                                         |     | —       | Teks penjelas di bawah judul newsletter                                                                       |
| Payment Methods Image (`payment_methods_image`)   | Attach Image                                                 |     | —       | Gambar deretan logo metode pembayaran di footer                                                               |
| VAT Certificate Image (`vat_certificate_image`)   | Attach Image                                                 |     | —       | Gambar sertifikat pajak/VAT di footer (umum dipakai toko GCC)                                                 |
| Copyright Text (`copyright_text`)                 | Data                                                         |     | —       | Baris hak cipta di paling bawah footer                                                                        |
| Footer Sections (`footer_sections`)               | Table → [Footer Section Mapping](#27-footer-section-mapping) |     | —       | Kolom footer mana yang dipakai toko ini dan urutannya                                                         |
| Footer Editor (`footer_editor`)                   | HTML                                                         |     | —       | Editor visual: kelola kolom & link footer di sini, tanpa bolak-balik ke Footer Section Config dan Footer Link |

### Tab: Color Scheme

Semua field di bawah bertipe **Color** dan diterjemahkan jadi CSS custom
property (`--ls-*`) yang dipakai storefront non-theme. Mengosongkan satu field
berarti memakai default di kolom paling kanan.

| Field                                             | Default   | Dipakai untuk                                                |
| ------------------------------------------------- | --------- | ------------------------------------------------------------ |
| Primary Color (`primary_color`)                   | `#b91c1c` | Warna utama (`--ls-primary`, `.bg-primary`, `.text-primary`) |
| Primary Hover Color (`primary_hover_color`)       | `#991b1b` | Warna utama saat kursor di atasnya                           |
| Link Color (`link_color`)                         | `#7f1d1d` | Warna teks link                                              |
| Link Hover Color (`link_hover_color`)             | `#991b1b` | Warna link saat hover                                        |
| Accent Color (`accent_color`)                     | `#b91c1c` | Warna aksen; juga dipakai titik indikator carousel           |
| Border Accent Color (`border_accent_color`)       | `#b91c1c` | Warna garis tepi beraksen                                    |
| Button Background Color (`button_bg_color`)       | `#b91c1c` | Latar tombol                                                 |
| Badge Background Color (`badge_bg_color`)         | `#b91c1c` | Latar badge (mis. label diskon)                              |
| Strikethrough Text Color (`strikethrough_color`)  | `#b91c1c` | Warna harga coret                                            |
| Heading Accent Color (`heading_accent_color`)     | `#991b1b` | Aksen pada judul                                             |
| Brand Text Color (`brand_text_color`)             | `#b91c1c` | Warna teks nama brand                                        |
| Secondary Accent Color (`secondary_accent_color`) | `#991b1b` | Aksen sekunder                                               |
| Form Accent Color (`form_accent_color`)           | `#b91c1c` | `accent-color` checkbox/radio di form                        |
| Focus Ring Color (`focus_ring_color`)             | `#b91c1c` | Cincin fokus saat elemen di-keyboard-focus                   |
| Footer Background Color (`footer_bg_color`)       | `#111827` | Latar footer                                                 |
| Footer Text Color (`footer_text_color`)           | `#ffffff` | Teks footer                                                  |

> 💡 Kalau toko memakai **theme** (lihat [Shop Theme Settings](#7-shop-theme-settings)),
> tampilan diatur oleh theme, dan tab warna ini hanya berlaku untuk bagian yang
> masih memakai storefront bawaan. Warna sedang bergeser ke theme; karena itu
> field Color tidak dirender di dashboard `/commera`.

### Tab: Navbar

| Field                           | Tipe |  W  | Default | Fungsi                                                                                                                                |
| ------------------------------- | ---- | :-: | ------- | ------------------------------------------------------------------------------------------------------------------------------------- |
| Navbar Editor (`navbar_editor`) | HTML |     | —       | Editor visual menu atas storefront (tab, kolom, link, brand) — menggantikan kerja manual di Ecommerce Category, Item Group, dan Brand |

### Tab: Communication

| Field                                                                   | Tipe                  |  W  | Default | Fungsi                                                                                                                                                                                         |
| ----------------------------------------------------------------------- | --------------------- | :-: | ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Order Confirmation Email Template (`order_confirmation_email_template`) | Link → Email Template |  ✔  | —       | Template email konfirmasi pesanan. App mengirim fixture `Order Confirmation` saat install                                                                                                      |
| Item In Stock Email Template (`item_in_stock_email_template`)           | Link → Email Template |  ✔  | —       | Template email "barang kembali tersedia" untuk [OOS Notify Subscription](#35-oos-notify-subscription). Fixture: `Item In Stock`                                                                |
| Order Cancellation Email Template (`order_cancellation_email_template`) | Link → Email Template |  ✔  | —       | Template email pembatalan pesanan. Fixture: `Order Cancellation`                                                                                                                               |
| Logo URL (`logo_url`)                                                   | Data (URL)            |     | —       | **URL absolut** logo yang dipasang di header email — template email bawaan membacanya lewat `frappe.db.get_single_value("Commera Settings","logo_url")`. Beda dari `brand_logo` yang untuk web |
| CC Email (`cc_email`)                                                   | Data (Email)          |     | —       | Alamat yang di-CC pada setiap email order & notifikasi stok. Kosong = tanpa CC                                                                                                                 |

> ⚠️ Tiga template email itu **wajib**. Kalau `commera` diinstal di site yang
> Setup Wizard-nya belum jalan, hook `after_install` gagal membuat fixture-nya
> dan Commera Settings jadi tidak bisa disimpan sampai ketiganya diisi manual.

---

## 2. Analytics Settings

**Desk → Commera Ecommerce → Analytics Settings.** Single. Mengatur dari mana
angka di dashboard _Analytics → Storefront_ berasal. Semua integrasi eksternal
mati sampai kredensialnya diisi.

| Field                                                   | Tipe                                                        |  W  | Default | Fungsi                                                                                                                                                                                                                                                                                                                                             |
| ------------------------------------------------------- | ----------------------------------------------------------- | :-: | ------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Enable First-Party Event Log** (`enable_first_party`) | **Check**                                                   |     | `1`     | Centang = event funnel storefront (`page_view`, `view_item`, `add_to_cart`, `begin_checkout`, `purchase`) dicatat ke database site sendiri sebagai [Storefront Analytics Event](#36-storefront-analytics-event). Ini yang menghidupkan dashboard Storefront **tanpa layanan luar**. Matikan kalau tidak mau menyimpan jejak pengunjung sama sekali |
| **Enable Facebook** (`enable_facebook`)                 | **Check**                                                   |     | `0`     | Centang = kirim event ke Meta (`PageView`, `ViewContent`, `AddToCart`, `InitiateCheckout`, `Purchase`) **dan** baca totalnya balik ke dashboard. Mencentang ini memunculkan dua field di bawah                                                                                                                                                     |
| Facebook Pixel ID (`fb_pixel_id`)                       | Data                                                        |     | —       | ID Dataset/Pixel numerik dari Meta Events Manager → Data sources. Hanya tampil saat _Enable Facebook_ dicentang                                                                                                                                                                                                                                    |
| Facebook Access Token (`fb_access_token`)               | Password                                                    |     | —       | Token Business System User dengan izin `ads_read`, `ads_management`, `business_management`, plus akses penuh ke dataset di atas. Token jenis ini tidak kedaluwarsa                                                                                                                                                                                 |
| **Enable Google Analytics 4** (`enable_ga4`)            | **Check**                                                   |     | `0`     | Centang = kirim event ke GA4 **dan** tarik Sessions/Active Users balik ke dashboard. Memunculkan tiga field di bawah                                                                                                                                                                                                                               |
| GA4 Measurement ID (`ga4_measurement_id`)               | Data                                                        |     | —       | ID web stream berformat `G-XXXXXXXXXX` (Admin → Data Streams)                                                                                                                                                                                                                                                                                      |
| GA4 Property ID (`ga4_property_id`)                     | Data                                                        |     | —       | Property ID numerik (Admin → Property Settings). Dipakai untuk membaca data, bukan mengirim                                                                                                                                                                                                                                                        |
| GA4 Service Account JSON (`ga4_service_account_json`)   | Password                                                    |     | —       | Isi file kunci service account. Aktifkan Google Analytics Data API, lalu beri email service account itu peran **Viewer** di property — tanpa itu `runReport` balas 403                                                                                                                                                                             |
| Custom Tracking Scripts (`custom_tracking_scripts`)     | Table → [Custom Tracking Script](#3-custom-tracking-script) |     | —       | Snippet tracking pihak ketiga tambahan                                                                                                                                                                                                                                                                                                             |

---

## 3. Custom Tracking Script

Child table di dalam [Analytics Settings](#2-analytics-settings).

| Field                   | Tipe      |  W  | Default | Fungsi                                                                                                                            |
| ----------------------- | --------- | :-: | ------- | --------------------------------------------------------------------------------------------------------------------------------- |
| Title (`title`)         | Data      |  ✔  | —       | Nama snippet, sekadar penanda di grid                                                                                             |
| **Enabled** (`enabled`) | **Check** |     | `1`     | Centang = snippet dipasang di setiap halaman storefront. Hilangkan centang untuk menonaktifkan sementara tanpa menghapus barisnya |
| Script (`script`)       | Code      |  ✔  | —       | Tempel snippet **persis** seperti diberikan penyedia tracking, termasuk tag `<script>`/`<noscript>`-nya sendiri                   |

> 🔐 Isi field ini dirender **tanpa sanitasi** di semua halaman storefront.
> Perlakukan sebagai hak akses penuh ke situs — jangan tempel script dari
> sumber yang tidak dipercaya.

---

## 4. Landing Page Settings

**Desk → Commera Ecommerce → Landing Page Settings.** Single. Isi halaman depan
storefront **bawaan** (`/`). Kalau toko memakai theme, halaman depan diatur oleh
settings theme-nya ([Shop Default Theme Settings](#10-shop-default-theme-settings) /
[Summer Theme Settings](#11-summer-theme-settings)), bukan di sini.

Pola field-nya berpasangan: versi biasa dan versi `_ar` untuk pembeli berbahasa
Arab. **Versi Arab bersifat opsional — kalau kosong, versi biasa yang dipakai.**

| Field                                                            | Tipe                                                            |  W  | Default | Fungsi                                                                                             |
| ---------------------------------------------------------------- | --------------------------------------------------------------- | :-: | ------- | -------------------------------------------------------------------------------------------------- |
| Hero Banner (`hero_banner`)                                      | Table → [Landing Page Hero Banner](#5-landing-page-hero-banner) |     | —       | Banner besar paling atas halaman depan                                                             |
| Hero Banner AR (`hero_banner_ar`)                                | Table                                                           |     | —       | Versi Arab dari hero banner                                                                        |
| GIF 1–4 (`gif_1` … `gif_4`)                                      | Attach                                                          |     | —       | Empat slot gambar/GIF promosi di halaman depan                                                     |
| GIF URL 1–4 (`gif_url_1` … `gif_url_4`)                          | Data (URL)                                                      |     | `/`     | Tujuan klik masing-masing GIF                                                                      |
| GIF 1–4 AR (`gif_1_ar` … `gif_4_ar`)                             | Attach                                                          |     | —       | Versi Arab keempat GIF                                                                             |
| GIF URL 1–4 AR (`gif_url_1_ar` … `gif_url_4_ar`)                 | Data (URL)                                                      |     | `/`     | Tujuan klik versi Arab                                                                             |
| New Arrivals (`new_arrivals`)                                    | Table → [Recommended Variant](#6-recommended-variant)           |     | —       | Produk yang tampil di blok _New Arrivals_. Kosong = sistem menampilkan 6 produk pilihannya sendiri |
| Best Picks (`best_picks`)                                        | Table → [Recommended Variant](#6-recommended-variant)           |     | —       | Produk di blok _Best Picks_. Kosong = 6 produk otomatis                                            |
| Banner 1 (`banner_1`)                                            | Attach Image                                                    |     | —       | Banner promosi tambahan                                                                            |
| Banner URL 1 (`banner_url_1`)                                    | Data (URL)                                                      |     | `/`     | Tujuan klik banner                                                                                 |
| Banner 1 AR / Banner URL 1 AR (`banner_1_ar`, `banner_url_1_ar`) | Attach Image / Data                                             |     | — / `/` | Versi Arab banner tambahan                                                                         |

---

## 5. Landing Page Hero Banner

Child table; dipakai oleh [Landing Page Settings](#4-landing-page-settings) dan
[Shop Default Theme Settings](#10-shop-default-theme-settings).

| Field                         | Tipe         |  W  | Default | Fungsi                    |
| ----------------------------- | ------------ | :-: | ------- | ------------------------- |
| Banner Image (`banner_image`) | Attach Image |     | —       | Gambar banner             |
| Url (`url`)                   | Data (URL)   |     | `/`     | Tujuan saat banner diklik |

---

## 6. Recommended Variant

Child table berisi satu kolom saja; dipakai di Landing Page Settings, Style
Attribute Configurator, dan settings theme untuk menyusun daftar produk pilihan
secara manual.

| Field                         | Tipe                                                          |  W  | Default | Fungsi                                                |
| ----------------------------- | ------------------------------------------------------------- | :-: | ------- | ----------------------------------------------------- |
| Item Variant (`item_variant`) | Link → [Style Attribute Variant](#15-style-attribute-variant) |  ✔  | —       | Produk yang ditampilkan. Urutan baris = urutan tampil |

---

## 7. Shop Theme Settings

**Desk → Shop Themes → Shop Theme Settings.** Single. Ini **satu-satunya**
pemilih theme untuk seluruh site.

| Field                                              | Tipe                                              |  W  | Default | Fungsi                                                                                                                                                                                                                                                                                        |
| -------------------------------------------------- | ------------------------------------------------- | :-: | ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Active Theme (`active_theme`)                      | Link → [Shop Theme](#8-shop-theme)                |     | —       | Theme yang dipakai storefront. **Kosongkan untuk merender storefront tanpa theme** (memakai halaman bawaan + Landing Page Settings)                                                                                                                                                           |
| **Enable Dynamic Pages** (`dynamic_pages_enabled`) | **Check**                                         |     | `0`     | Centang = URL yang tidak cocok dengan route mana pun tetap dicoba dicarikan filenya di theme aktif (`/en/foo/bar` → `pages/en/foo/bar.html`). Default mati: tabel route di bawah adalah cara yang didukung. Nyalakan hanya kalau kamu paham theme-nya bisa mengekspos file yang tidak sengaja |
| Themed Routes (`routes`)                           | Table → [Shop Themed Route](#9-shop-themed-route) |     | —       | Daftar route custom milik theme                                                                                                                                                                                                                                                               |

---

## 8. Shop Theme

**Desk → Shop Themes → Shop Theme.** Satu record = satu theme. Bawaan app ada
tiga: `Shop Base Theme` (induk, hanya komponen), `Shop Default Theme`, dan
`Summer Theme` — ketiganya `is_standard = 1`.

| Field                             | Tipe              |  W  | Default       | Fungsi                                                                                                                                                                   |
| --------------------------------- | ----------------- | :-: | ------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Theme Name (`theme_name`)         | Data              |  ✔  | —             | Nama theme; jadi nama folder (versi slug) tempat template & aset-nya. Hanya huruf, angka, spasi, `_`, `-`. Dua theme tidak boleh menghasilkan slug yang sama             |
| Module (`module`)                 | Link → Module Def |     | `Shop Themes` | Modul tempat JSON theme diekspor saat `developer_mode` aktif; modulnya menentukan app mana yang memuat file theme                                                        |
| **Is Standard** (`is_standard`)   | **Check**         |     | `0`           | Centang = theme bawaan app. Theme standar **tidak ikut terhapus dari disk** kalau record-nya dibuang. Jangan centang untuk theme buatan sendiri yang dibuat lewat Desk   |
| Theme Settings (`theme_settings`) | Link → DocType    |     | —             | DocType Single yang menampung konten theme ini (mis. `Summer Theme Settings`). Dibuat lewat tombol _Scaffold Theme Settings_ di form                                     |
| Parent Theme (`parent_theme`)     | Link → Shop Theme |     | —             | Warisi dari theme lain: template atau aset yang tidak ada di theme ini diambil dari induknya. Kedua theme bawaan mewarisi `Shop Base Theme`. Pewarisan melingkar ditolak |
| Config (`config`)                 | JSON              |     | —             | Sakelar tingkat engine yang dideklarasikan theme tentang dirinya, mis. `{"rtl": true}`. Teks/konten tampilan **bukan** di sini — tempatnya di Theme Settings             |

---

## 9. Shop Themed Route

Child table di [Shop Theme Settings](#7-shop-theme-settings). Satu baris = satu
URL yang dilayani theme.

| Field                               | Tipe       |  W  | Default | Fungsi                                                                                                                                               |
| ----------------------------------- | ---------- | :-: | ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| URL Pattern (`url_pattern`)         | Small Text |  ✔  | —       | **Regex** yang dicocokkan ke path request (slash depan dibuang). Named group seperti `(?P<route>[^/]+)` ikut masuk ke context render dan `form_dict` |
| Template Path (`template_path`)     | Data       |  ✔  | —       | Path relatif terhadap folder theme, mis. `pages/products/list.html`                                                                                  |
| **Requires Auth** (`requires_auth`) | **Check**  |     | `0`     | Centang = tamu (belum login) ditolak dengan permission error **sebelum** context halaman dibangun. Pakai untuk halaman akun/member-only              |

---

## 10. Shop Default Theme Settings

**Desk → Shop Themes → Shop Default Theme Settings.** Single. Konten untuk theme
`Shop Default Theme`. Semua field di sini murni teks/konten — tidak ada checkbox.

| Field                                     | Tipe                                                            |  W  | Default               | Fungsi                                                                 |
| ----------------------------------------- | --------------------------------------------------------------- | :-: | --------------------- | ---------------------------------------------------------------------- |
| Footer Note (`footer_note`)               | Data                                                            |     | —                     | Catatan di footer. Kosong = jatuh ke `Commera Settings.copyright_text` |
| Hero Banners (`hero_banners`)             | Table → [Landing Page Hero Banner](#5-landing-page-hero-banner) |     | —                     | Banner hero halaman depan theme ini                                    |
| Categories Title (`categories_title`)     | Data                                                            |     | `Shop by Category`    | Judul blok kategori                                                    |
| Shop By Category (`shop_by_category`)     | Table → Website Slideshow Item                                  |     | —                     | Kartu kategori (gambar + judul + link)                                 |
| Brand Title (`brand_title`)               | Data                                                            |     | `Shop by Brand`       | Judul blok brand                                                       |
| Shop By Brand (`shop_by_brand`)           | Table → Website Slideshow Item                                  |     | —                     | Kartu brand                                                            |
| Best Sellers Title (`best_sellers_title`) | Data                                                            |     | `Best Sellers`        | Judul blok produk terlaris                                             |
| Best Picks (`best_picks`)                 | Table → [Recommended Variant](#6-recommended-variant)           |     | —                     | Produk di blok terlaris                                                |
| New Arrivals Title (`new_arrivals_title`) | Data                                                            |     | `New Arrivals`        | Judul blok produk baru                                                 |
| New Arrivals (`new_arrivals`)             | Table → [Recommended Variant](#6-recommended-variant)           |     | —                     | Produk di blok produk baru                                             |
| Add To Cart Label (`add_to_cart_label`)   | Data                                                            |     | `Add to Cart`         | Tulisan tombol di halaman produk                                       |
| Related Heading (`related_heading`)       | Data                                                            |     | `You may also like`   | Judul blok produk terkait                                              |
| Empty Cart Heading (`empty_cart_heading`) | Data                                                            |     | `Your cart is empty`  | Judul saat keranjang kosong                                            |
| Checkout CTA Label (`checkout_cta_label`) | Data                                                            |     | `Proceed to Checkout` | Tulisan tombol lanjut ke checkout                                      |

---

## 11. Summer Theme Settings

**Desk → Shop Themes → Summer Theme Settings.** Single. Konten untuk theme
`Summer Theme` (theme yang dipasang oleh tombol _Install Demo Data_).

| Field                                             | Tipe                                                   |  W  | Default                                 | Fungsi                            |
| ------------------------------------------------- | ------------------------------------------------------ | :-: | --------------------------------------- | --------------------------------- |
| Hero Slides (`hero_slides`)                       | Table → [Summer Hero Slide](#12-summer-hero-slide)     |     | —                                       | Slide-slide hero di halaman depan |
| Hero Caption Label (`hero_caption_label`)         | Data                                                   |     | `Summer Collection`                     | Label kecil di atas judul hero    |
| Hero Caption (`hero_caption`)                     | Data                                                   |     | `Trendy and Classic for the New Season` | Kalimat utama hero                |
| Categories Title (`categories_title`)             | Data                                                   |     | `Featured Categories`                   | Judul strip kategori              |
| Categories Description (`categories_description`) | Small Text                                             |     | —                                       | Deskripsi di bawah judul kategori |
| Shop By Category (`shop_by_category`)             | Table → Website Slideshow Item                         |     | —                                       | Kartu kategori                    |
| Products Title (`products_title`)                 | Data                                                   |     | `Most popular products`                 | Judul grid produk                 |
| Best Picks (`best_picks`)                         | Table → [Recommended Variant](#6-recommended-variant)  |     | —                                       | Produk di grid utama              |
| Collection Banners (`collection_banners`)         | Table → [Summer Promo Banner](#13-summer-promo-banner) |     | —                                       | Banner koleksi                    |
| Deals Title (`deals_title`)                       | Data                                                   |     | `Blockbuster deals`                     | Judul blok promo                  |
| Deals Link Label (`deals_link_label`)             | Data                                                   |     | `See all deals`                         | Teks link "lihat semua"           |
| Deals URL (`deals_url`)                           | Data (URL)                                             |     | —                                       | Tujuan link "lihat semua"         |
| Deal Picks (`deal_picks`)                         | Table → [Recommended Variant](#6-recommended-variant)  |     | —                                       | Produk di blok promo              |
| Offers Title (`offers_title`)                     | Data                                                   |     | `Featured offer for you`                | Judul blok penawaran              |
| Offer Banners (`offer_banners`)                   | Table → [Summer Promo Banner](#13-summer-promo-banner) |     | —                                       | Banner penawaran                  |
| Featured Title (`featured_title`)                 | Data                                                   |     | `Featured now`                          | Judul blok unggulan               |
| Featured Picks (`featured_picks`)                 | Table → [Recommended Variant](#6-recommended-variant)  |     | —                                       | Produk di blok unggulan           |

---

## 12. Summer Hero Slide

Child table di [Summer Theme Settings](#11-summer-theme-settings).

| Field                               | Tipe         |  W  | Default | Fungsi                                            |
| ----------------------------------- | ------------ | :-: | ------- | ------------------------------------------------- |
| Image (`image`)                     | Attach Image |     | —       | Gambar slide                                      |
| Thumbnail Label (`thumbnail_label`) | Data         |     | —       | Teks di strip thumbnail samping slider            |
| Heading (`heading`)                 | Data         |  ✔  | —       | Judul besar di slide                              |
| Subheading (`subheading`)           | Data         |     | —       | Anak judul                                        |
| CTA Label (`cta_label`)             | Data         |     | —       | Tulisan tombol. Kosong = tombol tidak ditampilkan |
| URL (`url`)                         | Data (URL)   |     | —       | Tujuan tombol/slide                               |

---

## 13. Summer Promo Banner

Child table di [Summer Theme Settings](#11-summer-theme-settings), dipakai dua
kali: _Collection Banners_ dan _Offer Banners_.

| Field                       | Tipe         |  W  | Default | Fungsi                                   |
| --------------------------- | ------------ | :-: | ------- | ---------------------------------------- |
| Image (`image`)             | Attach Image |     | —       | Gambar banner                            |
| Badge Label (`badge_label`) | Data         |     | —       | Label kecil di pojok banner, mis. `-30%` |
| Heading (`heading`)         | Data         |  ✔  | —       | Judul banner                             |
| CTA Label (`cta_label`)     | Data         |     | —       | Tulisan tombol                           |
| URL (`url`)                 | Data (URL)   |     | —       | Tujuan klik                              |

---

## 14. Style Attribute Configurator

**Desk → Commera Ecommerce → Style Attribute Configurator.** Satu record =
"template pakaian X dipecah berdasarkan atribut Y". Dari sinilah
[Style Attribute Variant](#15-style-attribute-variant) digenerate.

Nama record dibentuk otomatis: `{item_template} {item_attribute}`.

| Field                                   | Tipe                                                  |  W  | Default | Fungsi                                                                                                                                                                   |
| --------------------------------------- | ----------------------------------------------------- | :-: | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Item Template (`item_template`)         | Link → Item                                           |  ✔  | —       | Item template ERPNext (yang `has_variants = 1`). **Unik** — satu template hanya boleh punya satu configurator                                                            |
| Item Attribute (`item_attribute`)       | Link → Item Attribute                                 |  ✔  | `Color` | Atribut yang jadi _sumbu produk_ di storefront. Satu nilai atribut (mis. satu warna) = satu produk di toko; atribut sisanya (mis. Size) jadi pilihan di dalam produk itu |
| Recommended Items (`recommended_items`) | Table → [Recommended Variant](#6-recommended-variant) |     | —       | Produk yang muncul sebagai rekomendasi/"kamu mungkin suka" di halaman produk ini                                                                                         |

**Perilaku:**

- Saat record baru disimpan, kalau _Create variants automatically on
  Configurator Creation_ di [Commera Settings](#tab-bulk-actions--import)
  dicentang, varian langsung digenerate. Kalau tidak, jalankan manual lewat
  tombol _Generate Variants_.
- Nama tampilan varian diambil dari nilai atribut yang namanya cocok dengan
  `attribute_name_field` di Commera Settings; kalau tidak ada, dipakai nilai
  atribut utama.

---

## 15. Style Attribute Variant

**Desk → Commera Ecommerce → Style Attribute Variant.** Ini **produk yang
dilihat pembeli** di storefront — bukan Item ERPNext langsung. Nama record:
`{item_style} - {attribute_value}`.

| Field                                 | Tipe                                                                    |  W  | Default | Fungsi                                                                                                                                                                                                                                                                                              |
| ------------------------------------- | ----------------------------------------------------------------------- | :-: | ------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Display Name (`display_name`)         | Data                                                                    |  ✔  | —       | Nama produk di storefront; juga judul record                                                                                                                                                                                                                                                        |
| **Is Published?** (`is_published`)    | **Check**                                                               |     | `0`     | Centang = produk tampil di storefront, masuk listing, pencarian, dan sitemap. **Tidak bisa dipublish tanpa minimal 1 gambar dan 1 ukuran** — sistem otomatis membatalkan centangnya dan memberi pesan _"Cannot publish without Images and Sizes"_. Menghilangkan centang selalu boleh, tanpa syarat |
| Route (`route`)                       | Data                                                                    |     | —       | Slug URL produk. Kosong = dibentuk otomatis dari nama record saat disimpan                                                                                                                                                                                                                          |
| Item Group (`item_group`)             | Link → Item Group                                                       |     | —       | Kategori produk. Kosong = diambil dari Item template, lalu diterjemahkan lewat [eCommerce Item Group Mapping](#tab-search--item-group) kalau ada pemetaannya                                                                                                                                        |
| Configurator (`configurator`)         | Link → [Style Attribute Configurator](#14-style-attribute-configurator) |  ✔  | —       | Configurator asal varian ini                                                                                                                                                                                                                                                                        |
| Item Style (`item_style`)             | Link → Item                                                             |  ✔  | —       | Item template ERPNext-nya                                                                                                                                                                                                                                                                           |
| Attribute Value (`attribute_value`)   | Data                                                                    |  ✔  | —       | Nilai atribut pembeda, mis. `Navy`                                                                                                                                                                                                                                                                  |
| Attribute Name (`attribute_name`)     | Data                                                                    |     | —       | Nama tampilan nilai atribut (hasil `attribute_name_field`), mis. `Navy Blue`                                                                                                                                                                                                                        |
| Images (`images`)                     | Table → Website Slideshow Item                                          |     | —       | Galeri gambar produk. **Syarat publish.** Bisa diisi massal lewat [Bulk Image Upload](#30-bulk-image-upload)                                                                                                                                                                                        |
| Sizes (`sizes`)                       | Table → [Color Size Item](#16-color-size-item)                          |     | —       | Peta ukuran → Item code ERPNext. **Syarat publish**, dan ini yang menghubungkan pilihan ukuran pembeli ke stok & harga item sebenarnya                                                                                                                                                              |
| Meta Title (`meta_title`)             | Data                                                                    |     | —       | Menimpa judul halaman. Kosong = display name + nama toko                                                                                                                                                                                                                                            |
| Meta Description (`meta_description`) | Small Text                                                              |     | —       | Meta/OG description, dipotong di 160 karakter                                                                                                                                                                                                                                                       |
| Meta Keywords (`meta_keywords`)       | Data                                                                    |     | —       | Meta keywords halaman produk                                                                                                                                                                                                                                                                        |
| OG Image (`og_image`)                 | Attach Image                                                            |     | —       | Menimpa gambar share yang digenerate otomatis                                                                                                                                                                                                                                                       |
| **No Index** (`noindex`)              | **Check**                                                               |     | `0`     | Centang = kirim `<meta name="robots" content="noindex">` **dan** keluarkan produk ini dari XML sitemap. Produk tetap bisa dibuka lewat link langsung — ini bukan cara menyembunyikan produk (untuk itu hilangkan centang _Is Published?_)                                                           |
| JSON-LD (Structured Data) (`json_ld`) | Code                                                                    |     | —       | JSON-LD schema.org Product. Kosong = digenerate otomatis dari data produk                                                                                                                                                                                                                           |

---

## 16. Color Size Item

Child table di [Style Attribute Variant](#15-style-attribute-variant). Ini
jembatan antara "ukuran yang dipilih pembeli" dan "Item ERPNext yang dijual".

| Field                   | Tipe        |  W  | Default | Fungsi                                                                          |
| ----------------------- | ----------- | :-: | ------- | ------------------------------------------------------------------------------- |
| Size (`size`)           | Data        |  ✔  | —       | Label ukuran yang dilihat pembeli, mis. `M`, `42`                               |
| Item Code (`item_code`) | Link → Item |  ✔  | —       | Item varian ERPNext yang benar-benar dipesan — sumber stok, harga, dan pajaknya |

---

## 17. Swatch

**Desk → Commera Ecommerce → Swatch.** Membuat nilai atribut tampil sebagai
kotak warna/tekstur, bukan sekadar teks. Nama record: `{attribute}-{attribute_value}`.

| Field                     | Tipe                  |  W  | Default | Fungsi                                                                                                 |
| ------------------------- | --------------------- | :-: | ------- | ------------------------------------------------------------------------------------------------------ |
| Attribute (`attribute`)   | Link → Item Attribute |  ✔  | —       | Atribut yang diberi swatch, mis. `Colour`                                                              |
| Value (`attribute_value`) | Data                  |  ✔  | —       | Nilai atributnya. **Harus sudah terdaftar** sebagai Item Attribute Value; kalau tidak, simpan ditolak  |
| Colour (`color`)          | Color                 |     | —       | Warna solid swatch. Dipakai kalau tidak ada gambar                                                     |
| Image (`image`)           | Attach Image          |     | —       | Pola/tekstur yang tidak bisa diwakili warna datar — denim, floral, marmer. **Mengalahkan** field warna |

> Simpan ditolak kalau warna **dan** gambar sama-sama kosong: _"Set a colour or
> an image — a swatch with neither has nothing to show."_

---

## 18. Ecommerce Category

**Desk → Commera Ecommerce → Ecommerce Category.** Pohon menu storefront
(nested set). Maksimal **3 level**. Bisa juga dikelola lewat _Navbar Editor_ di
Commera Settings.

| Field                                         | Tipe                                                                       |  W  | Default | Fungsi                                                                                                                                                                                                       |
| --------------------------------------------- | -------------------------------------------------------------------------- | :-: | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Category Name (`category_name`)               | Data                                                                       |  ✔  | —       | Kunci internal; **unik di seluruh pohon menu** dan jadi nama record                                                                                                                                          |
| Display Name (`display_name`)                 | Data                                                                       |  ✔  | —       | Label yang dilihat pembeli. Boleh sama di cabang berbeda. Kosong = disalin dari Category Name                                                                                                                |
| Parent Category (`parent_ecommerce_category`) | Link → Ecommerce Category                                                  |     | —       | Induk di pohon menu. Kosong = entri level atas                                                                                                                                                               |
| **Is Group** (`is_group`)                     | **Check**                                                                  |     | `0`     | Centang = entri ini boleh punya anak (jadi header/grup menu). Wajib dicentang sebelum bisa menaruh kategori lain di bawahnya                                                                                 |
| **Enabled** (`enabled`)                       | **Check**                                                                  |     | `1`     | Centang = entri tampil di menu storefront. Hilangkan centang untuk menyembunyikan sementara tanpa menghapus cabangnya                                                                                        |
| Display Order (`display_order`)               | Int                                                                        |     | `0`     | Urutan tampil di antara saudara sebaris; angka kecil di depan                                                                                                                                                |
| Route Slug (`route_slug`)                     | Data                                                                       |     | —       | Slug URL kategori, mis. `engine-parts`. **Hanya berlaku untuk entri level atas** — pada anak, isinya otomatis dikosongkan. Kosong = dibentuk dari Category Name. Bentrok slug antar entri level atas ditolak |
| Link Type (`link_type`)                       | Select: kosong / `Item Group` / `Brand` / `URL`                            |     | —       | Menu ini menunjuk ke apa. **Kosongkan untuk header yang tidak bisa diklik**                                                                                                                                  |
| Item Groups (`link_item_groups`)              | Table → [Ecommerce Category Item Group](#19-ecommerce-category-item-group) |     | —       | Muncul saat Link Type = `Item Group`. Produk dari semua grup yang terdaftar ditampilkan bersama dalam satu listing                                                                                           |
| Brand (`link_brand`)                          | Link → Brand                                                               |     | —       | Muncul saat Link Type = `Brand`                                                                                                                                                                              |
| URL (`link_url`)                              | Data                                                                       |     | —       | Muncul saat Link Type = `URL`. Divalidasi supaya URL berbahaya (mis. `javascript:`) ditolak                                                                                                                  |
| Icon (`icon`)                                 | Data                                                                       |     | —       | Nama ikon atau CSS class untuk entri menu                                                                                                                                                                    |
| Image (`image`)                               | Attach Image                                                               |     | —       | Gambar kategori (dipakai di kartu kategori)                                                                                                                                                                  |
| Meta Title (`meta_title`)                     | Data                                                                       |     | —       | Menimpa `<title>` halaman kategori                                                                                                                                                                           |
| Meta Description (`meta_description`)         | Small Text                                                                 |     | —       | Meta/OG description, dipotong 160 karakter                                                                                                                                                                   |
| OG Image (`og_image`)                         | Attach Image                                                               |     | —       | Menimpa gambar share otomatis                                                                                                                                                                                |
| **No Index** (`noindex`)                      | **Check**                                                                  |     | `0`     | Centang = minta crawler tidak mengindeks halaman kategori ini                                                                                                                                                |
| `lft`, `rgt`, `old_parent`                    | Int / Link                                                                 |     | —       | Kolom internal nested set. **Jangan diutak-atik**; tersembunyi dan read-only                                                                                                                                 |

> Field yang tidak sesuai Link Type akan dikosongkan otomatis saat simpan —
> jadi mengganti Link Type dari `URL` ke `Brand` membuang URL lamanya.

---

## 19. Ecommerce Category Item Group

Child table di [Ecommerce Category](#18-ecommerce-category).

| Field                     | Tipe              |  W  | Default | Fungsi                                                               |
| ------------------------- | ----------------- | :-: | ------- | -------------------------------------------------------------------- |
| Item Group (`item_group`) | Link → Item Group |  ✔  | —       | Satu Item Group yang produknya ikut ditampilkan saat menu ini diklik |

---

## 20. Item Group Map

Child table di [Commera Settings](#tab-search--item-group) (_eCommerce Item
Group Mapping_).

| Field                                         | Tipe              |  W  | Default | Fungsi                                       |
| --------------------------------------------- | ----------------- | :-: | ------- | -------------------------------------------- |
| Original Item Group (`original_item_group`)   | Link → Item Group |  ✔  | —       | Item Group asli yang dipakai Item di ERPNext |
| eCommerce Item Group (`ecommerce_item_group`) | Link → Item Group |  ✔  | —       | Item Group pengganti untuk keperluan toko    |

Varian baru otomatis memakai grup pengganti. Untuk varian lama, klik tombol
_Sync Item Group Mapping to Existing Items_.

---

## 21. Size Chart

**Desk → Commera Ecommerce → Size Chart.** Tabel ukuran yang tampil di halaman
produk.

| Field                               | Tipe              |  W  | Default | Fungsi                                                                                       |
| ----------------------------------- | ----------------- | :-: | ------- | -------------------------------------------------------------------------------------------- |
| Brand (`brand`)                     | Link → Brand      |  ✔  | —       | Brand yang memakai tabel ini                                                                 |
| Item Group (`item_group`)           | Link → Item Group |  ✔  | —       | Kategori produk yang memakai tabel ini                                                       |
| Size Chart (`size_chart`)           | Attach            |  ✔  | —       | File **spreadsheet** (dibaca dengan openpyxl, jadi pakai `.xlsx`). Isinya dibaca saat simpan |
| Size Chart JSON (`size_chart_json`) | JSON              |     | —       | Hasil parsing spreadsheet; read-only & tersembunyi. Ini yang dirender ke halaman produk      |
| Chart Preview (`chart_preview`)     | HTML              |     | —       | Pratinjau tabel di form                                                                      |

> Kombinasi **Brand + Item Group harus unik** — record kedua dengan pasangan
> yang sama ditolak. Ganti tabel ukuran = ganti file lampiran di record yang ada.

---

## 22. Shop Web Page

**Desk → Commera Ecommerce → Shop Web Page.** Halaman konten statis toko
(About us, Kebijakan Privasi, Syarat & Ketentuan). Nama record diminta saat
pembuatan (_prompt_).

| Field                                 | Tipe         |  W  | Default | Fungsi                                                                                                                                                            |
| ------------------------------------- | ------------ | :-: | ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Published** (`published`)           | **Check**    |     | `1`     | Centang = halaman bisa dibuka pembeli. Tidak dicentang = **404 untuk pembeli**, tapi user dengan hak tulis (System Manager) tetap bisa melihatnya untuk pratinjau |
| Route (`route`)                       | Data         |     | —       | Slug di bawah `/en/page/` dan `/ar/page/`. Kosong = dibentuk dari judul. **Unik** — route yang sudah dipakai halaman lain ditolak saat simpan                     |
| Content (`content`)                   | Text Editor  |  ✔  | —       | Isi halaman (bahasa utama)                                                                                                                                        |
| Content (Arabic) (`content_ar`)       | Text Editor  |     | —       | Isi untuk pembeli berbahasa Arab. Kosong = pakai konten utama                                                                                                     |
| Meta Title (`meta_title`)             | Data         |     | —       | Menimpa `<title>` halaman                                                                                                                                         |
| Meta Description (`meta_description`) | Small Text   |     | —       | Meta/OG description, dipotong 160 karakter                                                                                                                        |
| OG Image (`og_image`)                 | Attach Image |     | —       | Menimpa gambar share otomatis                                                                                                                                     |
| **No Index** (`noindex`)              | **Check**    |     | `0`     | Centang = minta crawler tidak mengindeks halaman ini (cocok untuk halaman kebijakan/duplikat)                                                                     |

---

## 23. OG Image Template

**Desk → Commera Ecommerce → OG Image Template.** Template gambar Open Graph
yang dirender saat ada permintaan. Satu record per DocType (nama record =
nama DocType-nya).

| Field                           | Tipe           |  W  | Default | Fungsi                                                                                                                                                                                                                               |
| ------------------------------- | -------------- | :-: | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| For DocType (`for_doctype`)     | Link → DocType |  ✔  | —       | DocType yang halamannya memakai template ini, mis. `Style Attribute Variant`. **Unik**                                                                                                                                               |
| **Enabled** (`enabled`)         | **Check**      |     | `1`     | Centang = template dipakai. Tidak dicentang = kembali ke gambar share default                                                                                                                                                        |
| Template HTML (`template_html`) | Code           |  ✔  | —       | Template Jinja untuk kartu OG; dokumen sumber tersedia sebagai `doc`. Renderer (Satori) hanya mendukung flexbox + sebagian CSS — bukan CSS penuh. Kosong saat record dibuat = diisi template bawaan `templates/og/product_card.html` |
| Preview Image (`preview_image`) | Attach Image   |     | —       | Hasil render pratinjau, diisi tombol _Generate Preview_ (butuh role System Manager). Read-only                                                                                                                                       |

> Kartu OG yang sudah dirender dibersihkan otomatis tiap hari oleh scheduler
> (`commera.og.generator.clear_old_cards`).

---

## 24. Return Reason

Child table di [Commera Settings](#tab-utama--shipping--returns) (_Reason for Return_).

| Field                         | Tipe      |  W  | Default | Fungsi                                                               |
| ----------------------------- | --------- | :-: | ------- | -------------------------------------------------------------------- |
| Display Name (`display_name`) | Data      |  ✔  | —       | Alasan retur yang dipilih pembeli, mis. `Ukuran tidak pas`. **Unik** |
| Description (`description`)   | Long Text |     | —       | Penjelasan tambahan alasan tersebut                                  |

---

## 25. Footer Section Config

**Desk → Commera Ecommerce → Footer Section Config.** Satu record = satu kolom
footer. Nama record = judul seksinya.

| Field                           | Tipe                                   |  W  | Default | Fungsi                                                                                                                                                           |
| ------------------------------- | -------------------------------------- | :-: | ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Section Title (`section_title`) | Data                                   |  ✔  | —       | Judul kolom footer, mis. `Bantuan`. **Unik**                                                                                                                     |
| Display Order (`section_order`) | Int                                    |     | `0`     | Urutan bawaan kolom ini                                                                                                                                          |
| **Enabled** (`enabled`)         | **Check**                              |     | `1`     | Centang = kolom ini boleh tampil. Sakelar tingkat definisi — masih perlu didaftarkan di [Footer Section Mapping](#27-footer-section-mapping) agar muncul di toko |
| Footer Links (`footer_links`)   | Table → [Footer Link](#26-footer-link) |     | —       | Isi link di kolom ini                                                                                                                                            |

---

## 26. Footer Link

Child table di [Footer Section Config](#25-footer-section-config).

| Field                        | Tipe      |  W  | Default | Fungsi                                                                       |
| ---------------------------- | --------- | :-: | ------- | ---------------------------------------------------------------------------- |
| Link Label (`link_label`)    | Data      |  ✔  | —       | Teks link                                                                    |
| Link URL (`link_url`)        | Data      |  ✔  | —       | Tujuan link                                                                  |
| Display Order (`link_order`) | Int       |     | `0`     | Urutan link dalam kolom                                                      |
| **Enabled** (`enabled`)      | **Check** |     | `1`     | Centang = link tampil. Hilangkan centang untuk menyembunyikan satu link saja |

---

## 27. Footer Section Mapping

Child table di [Commera Settings](#tab-footer-customization) (_Footer Sections_).
Ini yang menentukan kolom footer mana yang benar-benar dipasang di toko.

| Field                             | Tipe                                                      |  W  | Default | Fungsi                                                                                                                                 |
| --------------------------------- | --------------------------------------------------------- | :-: | ------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| Footer Section (`footer_section`) | Link → [Footer Section Config](#25-footer-section-config) |  ✔  | —       | Kolom footer yang dipakai                                                                                                              |
| Display Order (`section_order`)   | Int                                                       |     | `0`     | Urutan kolom di footer toko ini                                                                                                        |
| **Enabled** (`enabled`)           | **Check**                                                 |     | `1`     | Centang = kolom ini dipasang. Ini sakelar tingkat toko; sakelar di Footer Section Config adalah tingkat definisi. Keduanya harus aktif |

---

## 28. Search Content Field

Child table di [Commera Settings → tab Search](#tab-search). Menentukan teks apa
yang masuk ke index pencarian.

| Field                      | Tipe           |  W  | Default | Fungsi                                                                                                                                                                                                                        |
| -------------------------- | -------------- | :-: | ------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| DocType (`search_doctype`) | Link → DocType |     | —       | Sumber field. **Hanya tiga yang diterima:** `Item`, `Style Attribute Variant`, `Style Attribute Configurator`                                                                                                                 |
| Field (`field`)            | Select         |  ✔  | —       | Field yang teksnya diindeks. Pilihannya diisi otomatis setelah DocType dipilih, dan **hanya field bertipe teks** (Data, Select, Small Text, Text, Long Text, Link, Read Only) — angka, tanggal, dan tabel tidak bisa diindeks |

**Batasannya:** maksimal 15 baris, pasangan DocType+Field tidak boleh duplikat.
Tabel kosong = pakai default: `Style Attribute Variant`.display_name,
.attribute_value, .item_group, dan `Item`.brand.

---

## 29. Search Result Field

Child table di [Commera Settings → tab Search](#tab-search). Menentukan tampilan
kartu hasil pencarian.

| Field               | Tipe      |  W  | Default | Fungsi                                                                                                                                     |
| ------------------- | --------- | :-: | ------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| Attribute (`field`) | Select    |  ✔  | —       | Salah satu dari: `name`, `image`, `price`, `brand`, `color`, `item_group`, `sizes`. Tiap atribut hanya boleh muncul sekali                 |
| **Show** (`show`)   | **Check** |     | `1`     | Centang = atribut ini tampil di kartu hasil. **`name`, `image`, dan `price` wajib tetap tercentang** — mematikannya membuat simpan ditolak |

**Batasannya:** jumlah atribut yang tercentang harus antara **3 dan 8**. Tabel
kosong = layout default: image, name, color, price.

---

## 30. Bulk Image Upload

**Desk → Commera Ecommerce → Bulk Image Upload.** Upload gambar produk massal
dari satu file ZIP. DocType **submittable** — proses baru jalan saat di-_Submit_,
bukan saat disimpan.

| Field                                      | Tipe                     |  W  | Default | Fungsi                                                                                                                                                                                                                                                     |
| ------------------------------------------ | ------------------------ | :-: | ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Folder ZIP (`folder_zip`)                  | Attach                   |     | —       | File ZIP berisi gambar. **Struktur wajib:** `Folder.zip > Nama Style > Nama Warna > gambar`. Nama folder style harus sama dengan `item_style`, nama folder warna sama dengan `attribute_value` pada [Style Attribute Variant](#15-style-attribute-variant) |
| **Replace Existing?** (`replace_existing`) | **Check**                |     | `1`     | Centang = gambar lama varian **dihapus** lalu diganti isi ZIP. Hilangkan centang untuk menambahkan gambar baru di belakang gambar yang sudah ada                                                                                                           |
| Amended From (`amended_from`)              | Link → Bulk Image Upload |     | —       | Terisi otomatis kalau dokumen ini hasil _amend_ dari dokumen yang dibatalkan. Read-only                                                                                                                                                                    |

Saat submit: file wajib ada dan berekstensi `.zip`, kalau tidak prosesnya
ditolak. Hasil per varian tercatat di [Bulk Image Upload Log](#31-bulk-image-upload-log).

---

## 31. Bulk Image Upload Log

**Desk → Commera Ecommerce → Bulk Image Upload Log.** Read-only, dibuat sistem.

| Field                               | Tipe                                                          |  W  | Default | Fungsi                                               |
| ----------------------------------- | ------------------------------------------------------------- | :-: | ------- | ---------------------------------------------------- |
| Import (`import`)                   | Link → [Bulk Image Upload](#30-bulk-image-upload)             |  ✔  | —       | Dokumen upload asalnya                               |
| Variant (`variant`)                 | Link → [Style Attribute Variant](#15-style-attribute-variant) |     | —       | Varian yang gambarnya diproses                       |
| Images Uploaded (`images_uploaded`) | Int                                                           |     | `0`     | Jumlah gambar yang berhasil masuk ke varian tersebut |

---

## 32. Bulk Publish Variants

**Desk → Commera Ecommerce → Bulk Publish Variants.** Single, **tanpa tombol
Save** — isi filternya, lalu pakai tombol **Publish** (primary) atau
**Unpublish** (secondary) di kanan atas.

| Field                             | Tipe         |  W  | Default | Fungsi                                                                                                                                                                                                                                     |
| --------------------------------- | ------------ | :-: | ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Vendor Code (`vendor_code`)       | Data         |     | —       | Filter: Item template **atau** item ukuran yang `custom_vendor_code`-nya cocok. ⚠️ `custom_vendor_code` **bukan** field bawaan Commera/ERPNext — filter ini hanya bisa dipakai kalau kamu sendiri membuat Custom Field itu di DocType Item |
| Brand (`brand`)                   | Link → Brand |     | —       | Filter: brand Item template atau item ukuran                                                                                                                                                                                               |
| DCS (`dcs`)                       | Data         |     | —       | Filter: `custom_dcs` pada Item template atau item ukuran. Sama seperti Vendor Code — butuh Custom Field buatan sendiri                                                                                                                     |
| Item Code / Barcode (`item_code`) | Data         |     | —       | Filter: kode **Item template**. (Kode item ukuran tidak ikut dicocokkan)                                                                                                                                                                   |
| Season Code (`season_code`)       | Data         |     | —       | Filter: item ukuran yang punya Item Variant Attribute `Season` dengan nilai ini                                                                                                                                                            |

**Perilaku:**

- Minimal **satu** filter harus diisi, kalau tidak muncul _"Please fill at least
  one filter to continue."_
- Ada dialog konfirmasi, lalu hasilnya dilaporkan sebagai
  _"Successfully published N variants, matched M variants"_.
- **N bisa lebih kecil dari M**: saat publish, varian tanpa gambar atau tanpa
  ukuran dilewati (aturan kelengkapan yang sama dengan `is_published`). Saat
  unpublish tidak ada syarat apa pun — varian yang sudah live selalu bisa
  diturunkan.
- Varian yang statusnya berubah otomatis disinkronkan ke index pencarian.

---

## 33. Bulk Style Attribute Configurator Creation Log

**Desk → Commera Ecommerce → Bulk Style Attribute Configurator Creation Log.**
Dibuat sistem saat tombol _Publish Variants for All Templates_ ditekan.

| Field                           | Tipe                                                                                         |  W  | Default | Fungsi                                                                                                                            |
| ------------------------------- | -------------------------------------------------------------------------------------------- | :-: | ------- | --------------------------------------------------------------------------------------------------------------------------------- |
| Configurators (`configurators`) | Table → [Style Attribute Configurator Log Table](#34-style-attribute-configurator-log-table) |     | —       | Daftar configurator yang dibuat beserta jumlah variannya. Baris bertambah sambil job berjalan, jadi refresh untuk melihat progres |

---

## 34. Style Attribute Configurator Log Table

Child table di log di atas.

| Field                                                         | Tipe                                                                    |  W  | Default | Fungsi                                         |
| ------------------------------------------------------------- | ----------------------------------------------------------------------- | :-: | ------- | ---------------------------------------------- |
| Style Attribute Configurator (`style_attribute_configurator`) | Link → [Style Attribute Configurator](#14-style-attribute-configurator) |  ✔  | —       | Configurator yang dibuat                       |
| Variants Created (`variants_created`)                         | Int (≥0)                                                                |  ✔  | —       | Jumlah varian yang dihasilkan configurator itu |

---

## 35. OOS Notify Subscription

**Desk → Commera Ecommerce → OOS Notify Subscription.** Antrean pembeli yang
minta dikabari saat barang habis tersedia lagi. Record dibuat storefront, bukan
diisi manual.

| Field                     | Tipe        |  W  | Default | Fungsi                                                                                                                                                                                       |
| ------------------------- | ----------- | :-: | ------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Notified** (`notified`) | **Check**   |     | `0`     | `1` = email sudah dikirim. Baris yang sudah `1` **dihapus otomatis tiap hari** oleh scheduler (`commera.jobs.delete_notified_oos`) — jadi tabel ini hanya berisi antrean yang masih menunggu |
| Item (`item`)             | Link → Item |  ✔  | —       | Item yang ditunggu                                                                                                                                                                           |
| User (`user`)             | Link → User |  ✔  | —       | Pembeli yang akan dikabari                                                                                                                                                                   |

Email yang dikirim memakai _Item In Stock Email Template_ dan di-CC ke
_CC Email_ di [Commera Settings](#tab-communication).

---

## 36. Storefront Analytics Event

**Desk → Commera Ecommerce → Storefront Analytics Event.** Log event funnel
first-party; sumber angka dashboard _Analytics → Storefront_. Hanya terisi kalau
_Enable First-Party Event Log_ di [Analytics Settings](#2-analytics-settings)
dicentang. Nama record berupa hash, tidak ada checkbox di sini.

| Field                                                     | Tipe                                    |  W  | Default | Fungsi                                                                                |
| --------------------------------------------------------- | --------------------------------------- | :-: | ------- | ------------------------------------------------------------------------------------- |
| Event (`event`)                                           | Select                                  |  ✔  | —       | Salah satu dari `page_view`, `view_item`, `add_to_cart`, `begin_checkout`, `purchase` |
| Session ID (`session_id`)                                 | Data                                    |     | —       | Penanda sesi kunjungan                                                                |
| Visitor User (`visitor_user`)                             | Data                                    |     | —       | Pengunjung, kalau login                                                               |
| Device (`device`)                                         | Select: `Desktop` / `Mobile` / `Tablet` |     | —       | Jenis perangkat                                                                       |
| Item Code (`item_code`)                                   | Link → Item                             |     | —       | Item terkait event (untuk `view_item`, `add_to_cart`)                                 |
| Qty (`qty`)                                               | Int                                     |     | —       | Jumlah pada event                                                                     |
| Value (`value`)                                           | Currency                                |     | —       | Nilai uang event                                                                      |
| Currency (`currency`)                                     | Data                                    |     | —       | Mata uang nilai di atas                                                               |
| Order ID (`order_id`)                                     | Link → Sales Order                      |     | —       | Order terkait, untuk event `purchase`                                                 |
| Path (`path`)                                             | Data                                    |     | —       | Path halaman saat event terjadi                                                       |
| Referrer (`referrer`)                                     | Data                                    |     | —       | Halaman/asal rujukan                                                                  |
| Items JSON (`items_json`)                                 | Long Text                               |     | —       | Rincian keranjang/produk pada event, dalam JSON                                       |
| UTM Source / Medium / Campaign / Term / Content (`utm_*`) | Data                                    |     | —       | Parameter kampanye dari URL, untuk atribusi trafik                                    |

---

## Ringkasan semua checkbox (23 buah)

Jawaban cepat untuk "checkbox ini kalau dicentang jadi apa":

| DocType                                                | Checkbox                                               | Default | Dicentang artinya                                                                                                     |
| ------------------------------------------------------ | ------------------------------------------------------ | :-----: | --------------------------------------------------------------------------------------------------------------------- |
| [Commera Settings](#tab-utama--payment-mode)           | COD (`cod_enabled`)                                    |   `1`   | COD jadi pilihan bayar; server menerima order COD. Mematikannya tanpa payment gateway aktif = settings gagal disimpan |
| [Commera Settings](#tab-bulk-actions--import)          | Create variants automatically on Configurator Creation |   `0`   | Configurator baru langsung generate varian tanpa klik manual                                                          |
| [Analytics Settings](#2-analytics-settings)            | Enable First-Party Event Log                           |   `1`   | Event funnel disimpan di database sendiri; dashboard Storefront hidup tanpa layanan luar                              |
| [Analytics Settings](#2-analytics-settings)            | Enable Facebook                                        |   `0`   | Kirim + baca balik event Meta Pixel; memunculkan field Pixel ID & token                                               |
| [Analytics Settings](#2-analytics-settings)            | Enable Google Analytics 4                              |   `0`   | Kirim + baca balik data GA4; memunculkan field Measurement/Property ID & service account                              |
| [Custom Tracking Script](#3-custom-tracking-script)    | Enabled                                                |   `1`   | Snippet dipasang di semua halaman storefront (tanpa sanitasi)                                                         |
| [Shop Theme Settings](#7-shop-theme-settings)          | Enable Dynamic Pages                                   |   `0`   | URL tak dikenal ikut dicarikan file-nya di folder theme                                                               |
| [Shop Theme](#8-shop-theme)                            | Is Standard                                            |   `0`   | Theme bawaan app; file-nya tidak ikut terhapus saat record dibuang                                                    |
| [Shop Themed Route](#9-shop-themed-route)              | Requires Auth                                          |   `0`   | Tamu ditolak sebelum halaman dibangun                                                                                 |
| [Style Attribute Variant](#15-style-attribute-variant) | Is Published?                                          |   `0`   | Produk tampil di toko. Butuh minimal 1 gambar + 1 ukuran, kalau tidak centangnya dibatalkan otomatis                  |
| [Style Attribute Variant](#15-style-attribute-variant) | No Index                                               |   `0`   | `noindex` + dikeluarkan dari sitemap (produk tetap bisa dibuka lewat link)                                            |
| [Ecommerce Category](#18-ecommerce-category)           | Is Group                                               |   `0`   | Boleh punya kategori anak                                                                                             |
| [Ecommerce Category](#18-ecommerce-category)           | Enabled                                                |   `1`   | Entri tampil di menu                                                                                                  |
| [Ecommerce Category](#18-ecommerce-category)           | No Index                                               |   `0`   | Halaman kategori tidak diindeks crawler                                                                               |
| [Shop Web Page](#22-shop-web-page)                     | Published                                              |   `1`   | Halaman bisa dibuka pembeli; kalau tidak = 404 (System Manager tetap bisa pratinjau)                                  |
| [Shop Web Page](#22-shop-web-page)                     | No Index                                               |   `0`   | Halaman tidak diindeks crawler                                                                                        |
| [OG Image Template](#23-og-image-template)             | Enabled                                                |   `1`   | Template OG dipakai; kalau tidak, pakai gambar share default                                                          |
| [Footer Section Config](#25-footer-section-config)     | Enabled                                                |   `1`   | Kolom footer aktif di tingkat definisi                                                                                |
| [Footer Link](#26-footer-link)                         | Enabled                                                |   `1`   | Link footer tampil                                                                                                    |
| [Footer Section Mapping](#27-footer-section-mapping)   | Enabled                                                |   `1`   | Kolom footer dipasang di toko ini                                                                                     |
| [Search Result Field](#29-search-result-field)         | Show                                                   |   `1`   | Atribut tampil di kartu hasil pencarian (name/image/price wajib tetap aktif)                                          |
| [Bulk Image Upload](#30-bulk-image-upload)             | Replace Existing?                                      |   `1`   | Gambar lama dihapus dulu, bukan ditambah                                                                              |
| [OOS Notify Subscription](#35-oos-notify-subscription) | Notified                                               |   `0`   | Sudah dikabari; baris yang `1` dibersihkan otomatis tiap hari                                                         |

---

## Urutan pengisian yang disarankan

Untuk toko baru, isi dari atas ke bawah. Detail alurnya ada di
[OPERATIONS.md §2.1](OPERATIONS.md#21-setup-toko-sekali-di-awal).

1. **Prasyarat ERPNext** — Setup Wizard, Warehouse ecommerce, Price List,
   Shipping Rule, Item Group.
2. **[Commera Settings](#1-commera-settings) tab utama** — Company, Store Name,
   Ecommerce Warehouse, Price List, Shipping Rule, Return Period, COD.
3. **[Commera Settings](#tab-communication) tab Communication** — tiga template
   email wajib + CC Email + Logo URL.
4. **Payment & shipping provider** — dari dashboard `/commera`, bukan di sini.
5. **[Analytics Settings](#2-analytics-settings)** — biarkan first-party aktif;
   GA4/Meta hanya kalau kredensialnya siap.
6. **Tampilan** — pilih theme di [Shop Theme Settings](#7-shop-theme-settings),
   lalu isi settings theme-nya. Kalau tidak pakai theme, isi
   [Landing Page Settings](#4-landing-page-settings) + tab Color Scheme.
7. **Menu & footer** — [Ecommerce Category](#18-ecommerce-category) (atau Navbar
   Editor), [Footer Section Config](#25-footer-section-config) +
   [Footer Section Mapping](#27-footer-section-mapping).
8. **Katalog** — [Style Attribute Configurator](#14-style-attribute-configurator)
   → generate [Style Attribute Variant](#15-style-attribute-variant) → isi
   gambar & ukuran → publish.
9. **Pencarian & SEO** — sesuaikan tab Search dan tab SEO setelah katalog terisi,
   lalu _Rebuild Search Index_.

---

## Catatan sumber

Isi dokumen ini dibaca dari definisi DocType dan kode app `commera` di dalam
image yang berjalan (branch `develop`). Kalau app di-update, yang paling mungkin
berubah adalah field baru di Commera Settings dan settings theme. Cara cek ulang
cepat dari container backend:

```shell
docker exec <backend-container> bench --site <site-name> console
# lalu:
# frappe.get_meta("Commera Settings").fields
```

Atau langsung baca JSON-nya:

```shell
docker exec <backend-container> \
  cat /home/frappe/frappe-bench/apps/commera/commera/commera_ecommerce/doctype/commera_settings/commera_settings.json
```
