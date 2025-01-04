# **Zenity ile Basit Envanter Yönetim Sistemi**

Bu proje, bir stok ve kullanıcı yönetimi uygulamasıdır. Kullanıcılar ve yöneticiler için farklı işlemler sunan ve dosya tabanlı bir sistemle çalışan bu uygulama, ürün ekleme, güncelleme, silme işlemleri ile kullanıcı yönetimi, yedekleme ve raporlama gibi işlemleri gerçekleştirebilmektedir.

---

## **Projenin İçeriği**

Proje kapsamında kullanılan ana fonksiyonlar `anamenu.sh` dosyasında bulunur. Sistemin çalışması için gerekli kayıtlar `csv` klasörü altında yer alan aşağıdaki dosyalarda tutulmaktadır:


- **kullanici.csv**: Kullanıcı bilgileri
- **log.csv**: Hata ve işlem kayıtları
- **depo.csv**: Stok bilgileri

---

## **Ana Menü**

Proje ana dizininde bulunan `anamenu.sh` scripti çalıştırıldığında aşağıdaki gibi bir ekran görüntülenir. Kullanıcı, aşağıdaki seçeneklerden birini seçebilir:

1. **Kullanıcı olarak giriş yap**  
2. **Yönetici olarak giriş yap**  
3. **Çıkış**  

![image](https://github.com/user-attachments/assets/3bac9001-3841-4ac1-8c9f-cde6e56f4721)


---

## **Yönetici İşlemleri**

### **Giriş ve Kayıt**
- Yönetici olarak giriş yapmak için "Giriş Yap" seçeneği kullanılabilir. Eğer bir yönetici kaydı yoksa "Kayıt Ol" seçeneği tercih edilmelidir.  
- Yönetici kaydı için bir **Yönetici Anahtarı** gereklidir. Bu anahtar, kullanıcıları yöneticilerden ayıran bir güvenlik mekanizmasıdır. Proje için yönetici anahtarı: **linuxodev**

- Kayıt işlemi tamamlandıktan sonra yönetici giriş bilgileri (kullanıcı adı ve şifre) belirlenmelidir.

![image](https://github.com/user-attachments/assets/f8cb4673-0f5f-4b2f-8a36-ddc5b10bd5f6)

---

### **Yönetici Menüsü**
Başarılı bir girişin ardından yönetici menüsü aşağıdaki gibi görünür:

![image](https://github.com/user-attachments/assets/51da0e47-5037-441f-b1d7-22f6d72eee28)

#### Yönetici Menü Seçenekleri:

1. **Ürün Ekle**  
   Yeni bir ürün eklenirken aşağıdaki kurallar geçerlidir:  
   - "Birim Fiyatı" ve "Stok Miktarı" yalnızca 0 veya pozitif sayı olabilir.  
   - "Ürün Adı" ve "Kategori" bilgilerinde boşluk kullanılmamalıdır.  

   ![image](https://github.com/user-attachments/assets/96b3de31-5ca9-4074-9eea-51fb4421fcc2)

2. **Ürün Sil ve Ürün Güncelle**  
   Stoktan bir ürünü silebilir veya bilgilerini güncelleyebilirsiniz.

3. **Kullanıcı Yönetimi**  
   Sisteme kayıtlı kullanıcı ve yöneticilerin listesini görüntüleyebilirsiniz.

   ![image](https://github.com/user-attachments/assets/7f08c887-0fe4-41c5-8806-423cfdb3be51)

4. **Şifre Değiştir**  
   Yönetici şifresini değiştirme imkanı sunar.

5. **Program Yönetimi**  
   - Projenin diskte kapladığı alanı görüntüleyebilir.  
   - `depo.csv` ve `kullanici.csv` dosyalarını yedekleyebilir.  
   - `log.csv` dosyasında kayıtlı hata kayıtlarını inceleyebilirsiniz.

   ![image](https://github.com/user-attachments/assets/36c539f1-3831-4dda-b362-97cbb677e0f0)

6. **Çıkış**  
   Ana menüye döner.

---

## **Kullanıcı İşlemleri**

### **Giriş ve Kayıt**
- Kullanıcı olarak giriş yapmak için "Giriş Yap" seçeneği kullanılabilir. Eğer bir kullanıcı kaydı yoksa "Kayıt Ol" seçeneği kullanılmalıdır.  
- Kayıt işlemi sırasında "Kullanıcı Adı", "Ad", "Soyad" ve "Şifre" bilgileri istenir.

---

### **Kullanıcı Menüsü**
Başarılı bir girişin ardından kullanıcı menüsü aşağıdaki gibidir:

![image](https://github.com/user-attachments/assets/6112858d-67c5-4113-a03f-dc3757296ff7)

#### Kullanıcı Menü Seçenekleri:

1. **Ürünleri Görüntüle**  
   Stoktaki tüm ürünleri görüntüleyebilirsiniz.

   ![image](https://github.com/user-attachments/assets/e51c10f5-5d87-4ea8-b7cc-012d200b9489)

2. **Rapor Al**  
   İki farklı raporlama seçeneği bulunmaktadır:
   - **Stokta Azalan Ürünler**: Belirli bir eşik değerinin altındaki stokları listeler.  
     
     ![image](https://github.com/user-attachments/assets/58a27e44-1a73-4b07-84e6-0276e5274878)
   - **En Yüksek Stok Miktarı**: Stoktaki en yüksek miktara sahip ürünü listeler.  
     
     ![image](https://github.com/user-attachments/assets/8dd7ee3f-5f70-4ea2-8346-4148f105df01)

---

## Projenin Videosu

---
* Bu proje, **Zenity** aracılığıyla kullanıcı dostu bir arayüz sağlayarak basit bir envanter yönetim sistemi oluşturmayı amaçlamaktadır. 😊

