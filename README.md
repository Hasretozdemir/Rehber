# 🏥 Hastane Rehber ve Nöbet Takip Uygulaması

Bu proje, hastane personelinin iletişim bilgilerine hızlıca ulaşılmasını, haftalık nöbet listelerinin takip edilmesini ve acil durum numaralarının yönetilmesini sağlayan kapsamlı bir **Flutter** mobil uygulamasıdır. 

Uygulama, hem son kullanıcıların (doktorlar, hemşireler, personeller) rehber ve nöbet bilgilerini kolayca görüntüleyebileceği bir arayüze, hem de yöneticilerin bu bilgileri güncelleyebileceği bir **Admin Paneline** sahiptir.

## ✨ Özellikler

* **Kullanıcı Girişi (Login):** Güvenli kullanıcı doğrulaması.
* **Kapsamlı Rehber:** Hastane personeline ait iletişim bilgilerinin listelenmesi ve aranması.
* **Nöbet Takibi:** Günlük ve haftalık nöbetçi personel listelerinin görüntülenmesi.
* **Acil Durum İletişimi:** Acil durumlarda hızlıca ulaşılabilecek önemli numaralar ve kişiler.
* **Admin Paneli:** Yöneticiler için kişi, bölüm ve nöbet ekleme/düzenleme/silme yetkileri.
* **Karanlık Tema (Dark Mode) Desteği:** Kullanıcı tercihine göre aydınlık ve karanlık tema seçenekleri.

---

## 📸 Ekran Görüntüleri

Uygulamanın arayüzünden çeşitli kesitler:

### 🔐 Giriş ve Genel Kullanım
| Giriş Ekranı | Rehber Ana Ekranı |
| :---: | :---: |
| <img src="docs/screenshots/login.png" width="250"> | <img src="docs/screenshots/rehber.png" width="250"> |

### 📅 Nöbet Takibi ve Acil Durum
| Nöbet Ekranı | Haftalık Nöbet | Acil Durum |
| :---: | :---: | :---: |
| <img src="docs/screenshots/nöbet.png" width="250"> | <img src="docs/screenshots/haftalıknöbet.png" width="250"> | <img src="docs/screenshots/acil.png" width="250"> |

### ⚙️ Admin Paneli ve Yönetim
| Admin Paneli | Admin Bölüm Yönetimi | Admin Nöbet Yönetimi |
| :---: | :---: | :---: |
| <img src="docs/screenshots/admin.png" width="250"> | <img src="docs/screenshots/adminbolum.png" width="250"> | <img src="docs/screenshots/adminnöbet.png" width="250"> |

| Kişi Düzenle | Bölüm Düzenle | Nöbet Ekle |
| :---: | :---: | :---: |
| <img src="docs/screenshots/kisidüzenle.png" width="250"> | <img src="docs/screenshots/bolumdüzenle.png" width="250"> | <img src="docs/screenshots/nöbetekle.png" width="250"> |

### 🌙 Ayarlar ve Temalar
| Ayarlar | Karanlık Tema |
| :---: | :---: |
| <img src="docs/screenshots/ayarlar.png" width="250"> | <img src="docs/screenshots/karanlıktema.png" width="250"> |

---

## 🗄️ Veritabanı ve Veri Yönetimi

Uygulama, harici bir sunucuya (API, Firebase, SQL Server vb.) ihtiyaç duymadan **tamamen çevrimdışı (offline)** çalışacak şekilde tasarlanmıştır.

* **Yerel Veritabanı:** Projede veritabanı olarak telefonun kendi dahili hafızasında barındırılan **SQLite** kullanılmıştır. Bölümler, kişiler ve nöbet bilgileri `hospital_directory.db` adlı yerel dosyada tutulur.
* **Örnek Veri Aktarımı (Seeding):** Uygulama cihaza ilk kez kurulup çalıştırıldığında, içi boş kalmaması adına kod içerisinde bulunan `mock_data.dart` dosyasındaki örnek hastane verileri (personeller, acil durum numaraları, haftalık nöbet listeleri) otomatik olarak SQLite veritabanına aktarılır.
* **Kalıcı Değişiklikler:** Admin paneli üzerinden gerçekleştirilen her türlü ekleme, silme ve düzenleme işlemi bu yerel SQLite veritabanına anında ve kalıcı olarak kaydedilir.

---

## 🛠️ Kullanılan Teknolojiler

* **Framework:** [Flutter](https://flutter.dev/)
* **Dil:** Dart
* **Veritabanı:** SQLite (`sqflite` paketi)
* **Mimari / State Management:** Provider

---

## 🚀 Kurulum ve Çalıştırma

Projeyi yerel bilgisayarınızda çalıştırmak için aşağıdaki adımları izleyebilirsiniz:

1. Depoyu bilgisayarınıza klonlayın:
   ```bash
   git clone [https://github.com/kullanici-adiniz/rehber.git](https://github.com/kullanici-adiniz/rehber.git)
