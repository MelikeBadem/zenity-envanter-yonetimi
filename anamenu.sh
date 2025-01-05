#!/bin/bash

# Başlangıç dosyaları kontrolü
if [[ ! -d "csv" ]]; then
    mkdir csv
fi

if [[ ! -f "csv/kullanici.csv" ]]; then
    echo "Kullanıcı Adı,Adı,Soyadı,Rol,Şifre" > csv/kullanici.csv
fi

if [[ ! -f "csv/depo.csv" ]]; then
    echo "ID,Ürün Adı,Stok Miktarı,Birim Fiyatı,Kategori" > csv/depo.csv
fi
if [[ ! -f "csv/log.csv" ]]; then
    
fi

# Yönetici ekleme (kayıt)
function yonetici_ekle() {
    while true; do
        anahtar=$(zenity --password --title="Yönetici Anahtarı" --text="Yönetici anahtarını girin:")
        if [[ "$anahtar" != "linuxodev" ]]; then
            zenity --error --text="Geçersiz anahtar. Yönetici eklenemedi."
            continue
        fi

        bilgiler=$(zenity --forms --title="Yönetici Ekle" \
            --text="Yönetici bilgilerini girin:" \
            --add-entry="Kullanıcı Adı" \
            --add-entry="Adı" \
            --add-entry="Soyadı" \
            --add-password="Şifre")
        if [[ -z "$bilgiler" ]]; then
            zenity --error --text="Bilgiler boş olamaz!"
            continue
        fi

        IFS="|" read -r kullanici adi soyadi sifre <<< "$bilgiler"
        hashed_sifre=$(echo -n "$sifre" | md5sum | awk '{print $1}')
        echo "$kullanici,$adi,$soyadi,Yönetici,$hashed_sifre" >> csv/kullanici.csv
        zenity --info --text="Yönetici başarıyla eklendi!"
        break
    done
}

# Giriş ekranı (Yönetici giriş)
function yonetici_giris() {
    while true; do
        giris_bilgileri=$(zenity --forms --title="Yönetici Giriş Yap" \
            --text="Yönetici kullanıcı bilgilerini girin:" \
            --add-entry="Kullanıcı Adı" \
            --add-password="Şifre")
        if [[ -z "$giris_bilgileri" ]]; then
            zenity --error --text="Bilgiler boş olamaz!"
            continue
        fi

        IFS="|" read -r kullanici sifre <<< "$giris_bilgileri"
        hashed_sifre=$(echo -n "$sifre" | md5sum | awk '{print $1}')
        kullanici_satiri=$(grep -w "$kullanici" csv/kullanici.csv | grep -w "$hashed_sifre")

        if [[ -z "$kullanici_satiri" ]]; then
            zenity --error --text="Geçersiz kullanıcı adı veya şifre!"
            continue
        fi

        rol=$(echo "$kullanici_satiri" | awk -F',' '{print $4}')
        zenity --info --text="Giriş başarılı! Rol: $rol"
        
        echo "$rol"
        break
    yonetici_menusu
    done
    
}

# Program Yönetimi
function program_yonetimi() {
    while true; do
        secim=$(zenity --list --title="Program Yönetimi" \
            --column="ID" --column="İşlem" \
            1 "Diskte Kapladığı Alanı Göster" \
            2 "Diske Yedek Al" \
            3 "Hata Kayıtlarını Görüntüle" \
            4 "Geri Dön")

        case $secim in
            1)
                disk_alan_goster ;;
            2)
                diske_yedek_al ;;
            3)
                hata_kayitlarini_gor ;;
            4)
                break ;;
            *)
                zenity --error --text="Geçersiz seçim yaptınız!" ;;
        esac
    done
}

# Diskte Kapladığı Alanı Göster
function disk_alan_goster() {
    alan=$(du -sh csv/ 2>/dev/null | awk '{print $1}')
    if [[ -z "$alan" ]]; then
        zenity --error --text="CSV dizini bulunamadı!"
    else
        zenity --info --text="CSV klasörü toplamda $alan yer kaplıyor."
    fi
}

# Diske Yedek Al
function diske_yedek_al() {
    backup_file="yedek_$(date +'%Y%m%d_%H%M%S').tar.gz"
    tar -czf "$backup_file" csv/ 2>/dev/null

    if [[ $? -eq 0 ]]; then
        zenity --info --text="Yedekleme işlemi başarıyla tamamlandı.\nOluşturulan yedek dosyası: $backup_file"
    else
        zenity --error --text="Yedekleme işlemi sırasında bir hata oluştu!"
    fi
}

# Hata Kayıtlarını Görüntüle
function hata_kayitlarini_gor() {
    if [[ -f "csv/log.csv" ]]; then
        zenity --text-info --title="Hata Kayıtları" --filename="csv/log.csv" --width=600 --height=400
    else
        zenity --error --text="Hata kayıtları bulunamadı!"
    fi
}

# Yönetici menüsü içine "Program Yönetimi" seçeneği ekleniyor
function yonetici_menusu() {
    while true; do
        secim=$(zenity --list --title="Yönetici Menüsü" \
            --column="ID" --column="İşlem" \
            1 "Ürün Ekle" \
            2 "Ürün Sil" \
            3 "Ürün Güncelle" \
            4 "Kullanıcı Yönetimi" \
            5 "Şifre Değiştir" \
            6 "Program Yönetimi" \
            7 "Çıkış")
        case $secim in
            1) urun_ekle ;;
            2) urun_sil ;;
            3) urun_guncelle ;;
            4) listele_kullanicilar ;;
            5) sifre_degistir ;;
            6) program_yonetimi ;;  # Program Yönetimi fonksiyonu
            7) break ;;
            *) zenity --error --text="Geçersiz seçim yaptınız!" ;;
        esac
    done
}
listele_kullanicilar() {
    local CSV_FILE="csv/kullanici.csv"

    if [[ -f $CSV_FILE ]]; then
        # Başlık ve kullanıcı verilerini Zenity formatında oluştur
        kullanici_listesi=$(awk -F',' '
            NR > 1 { printf "%s|%s|%s|%s\n", $1, $2, $3, $4 }
        ' "$CSV_FILE")

        # Zenity ile kullanıcı listesini göster
        zenity --list \
            --title="Kullanıcı Listesi" \
            --text="Sisteme kayıtlı kullanıcılar:" \
            --column="Kullanıcı Adı" --column="İsim" --column="Soyisim" --column="Rol" \
            $(echo "$kullanici_listesi") \
            --width=600 --height=400
    else
        zenity --error \
            --title="Hata" \
            --text="csv/kullanici.csv dosyası bulunamadı."
    fi
}
#Yönetici şifresi değiştirilir.
function sifre_degistir() {
    local dosya="csv/kullanici.csv"

    # Eski şifreyi sor
    eski_sifre=$(zenity --password --title="Eski Şifre")
    if [[ -z "$eski_sifre" ]]; then
        zenity --error --text="Eski şifre boş bırakılamaz!"
        return
    fi

    # Eski şifreyi MD5 hash'e çevir
    eski_sifre_md5=$(echo -n "$eski_sifre" | md5sum | awk '{print $1}')

    # Şifre doğrulama
    if ! grep -Eiq "^$yonetici_kullanici,.,.,Yönetici,$eski_sifre_md5$" "$dosya"; then
        zenity --error --text="Eski şifre hatalı!"
        return
    fi

    # Yeni şifreyi sor
    yeni_sifre=$(zenity --password --title="Yeni Şifre")
    if [[ -z "$yeni_sifre" ]]; then
        zenity --error --text="Yeni şifre boş bırakılamaz!"
        return
    fi

    # Yeni şifreyi tekrar sor
    yeni_sifre_tekrar=$(zenity --password --title="Yeni Şifre Tekrar")
    if [[ "$yeni_sifre" != "$yeni_sifre_tekrar" ]]; then
        zenity --error --text="Yeni şifreler uyuşmuyor!"
        return
    fi

    # Yeni şifreyi MD5 hash'e çevir
    yeni_sifre_md5=$(echo -n "$yeni_sifre" | md5sum | awk '{print $1}')

    # Şifreyi güncelle
    sed -i "s/^$yonetici_kullanici,\(.*\),Yönetici,$eski_sifre_md5\$/$yonetici_kullanici,\1,Yönetici,$yeni_sifre_md5/" "$dosya"
    if [[ $? -eq 0 ]]; then
        zenity --info --text="Şifre başarıyla değiştirildi!"
    else
        zenity --error --text="Şifre güncellenirken bir hata oluştu!"
    fi
}

#Urun ekleme
function urun_ekle(){
	log_file="csv/log.csv"
	csv_file="csv/depo.csv"

	# Log dosyasını oluşturma
	mkdir -p csv
	if [[ ! -f "$log_file" ]]; then
            echo "Tarih,Saat,Hata Mesajı" > "$log_file"
	fi

	# CSV dosyasını oluşturma ve başlık ekleme
	if [[ ! -f "$csv_file" ]]; then
	    echo "ID,Ürün Adı,Stok Miktarı,Birim Fiyatı,Kategori" > "$csv_file"
	fi
while true; do
	# Ürün bilgilerini al
bilgiler=$(zenity --forms --title="Ürün Ekle" \
        --text="Ürün bilgilerini girin:" \
        --add-entry="Ürün Adı" \
        --add-entry="Stok Miktarı" \
        --add-entry="Birim Fiyatı" \
        --add-entry="Kategori")

# Eğer bilgiler boşsa tekrar iste
    if [[ -z "$bilgiler" ]]; then
        zenity --error --text="Bilgiler boş olamaz!"
        echo "$(date +'%Y-%m-%d'),$(date +'%H:%M:%S'),Bilgiler boş girildi" >> "$log_file"
        continue
    fi

    # Bilgileri al
    IFS="|" read -r ad stok fiyat kategori <<< "$bilgiler"

    # Veri doğrulama
    if [[ ! "$stok" =~ ^[0-9]+$ ]] || [[ ! "$fiyat" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        zenity --error --text="Stok miktarı ve birim fiyatı yalnızca pozitif sayı olmalıdır!"
        echo "$(date +'%Y-%m-%d'),$(date +'%H:%M:%S'),Geçersiz stok veya fiyat girdisi" >> "$log_file"
        continue
    fi

    if [[ "$ad" =~ \  ]] || [[ "$kategori" =~ \  ]]; then
        zenity --error --text="Ürün adı ve kategori boşluk içeremez!"
        echo "$(date +'%Y-%m-%d'),$(date +'%H:%M:%S'),Ürün adı veya kategori boşluk içeriyor" >> "$log_file"
        continue
    fi

    # Aynı isimde ürün kontrolü
    if grep -qi ",$ad," "$csv_file"; then
        zenity --error --text="Bu ürün adıyla başka bir kayıt bulunmaktadır. Lütfen farklı bir ad giriniz."
        echo "$(date +'%Y-%m-%d'),$(date +'%H:%M:%S'),Aynı isimde ürün eklendi" >> "$log_file"
        continue
    fi
	break
done
# ID otomatik artış
id=$(($(tail -n +2 "$csv_file" | wc -l) + 1))

# İşlem ilerleme çubuğu
(
    echo "50"; sleep 1
    echo "# Ürün ekleniyor..."; sleep 1
    echo "100"; sleep 1
) | zenity --progress --title="İşlem Devam Ediyor" --text="Ürün ekleniyor..." --width=400 --no-cancel

# Dosyaya yaz
echo "$id,$ad,$stok,$fiyat,$kategori" >> "$csv_file"

# İşlem başarılı mesajı
zenity --info --text="Ürün başarıyla eklendi!"
}
# Ürün silme
function urun_sil() {
    urun_silme=$(zenity --entry --title="Ürün Sil" --text="Silmek istediğiniz ürün adını girin:")
    if [[ -z "$urun_silme" ]]; then
        zenity --error --text="Ürün adı boş olamaz!"
        return
    fi

    grep -v "$urun_silme" csv/depo.csv > temp.csv && mv temp.csv csv/depo.csv
    zenity --info --text="Ürün başarıyla silindi!"
}

# Ürün güncelleme
function urun_guncelle() {
    urun_adı=$(zenity --entry --title="Ürün Güncelle" --text="Güncellemek istediğiniz ürün adını girin:")
    if [[ -z "$urun_adı" ]]; then
        zenity --error --text="Ürün adı boş olamaz!"
        return
    fi

    satir=$(grep "$urun_adı" csv/depo.csv)
    if [[ -z "$satir" ]]; then
        zenity --error --text="Ürün bulunamadı!"
        return
    fi

    bilgiler=$(zenity --forms --title="Ürün Güncelle" \
        --text="Yeni ürün bilgilerini girin:" \
        --add-entry="Yeni Ürün Adı" \
        --add-entry="Yeni Stok Miktarı" \
        --add-entry="Yeni Birim Fiyatı" \
        --add-entry="Yeni Kategori")
    
    if [[ -z "$bilgiler" ]]; then
        zenity --error --text="Bilgiler boş olamaz!"
        return
    fi

    IFS="|" read -r yeni_urun_adı yeni_stok_miktarı yeni_birim_fiyat yeni_kategori <<< "$bilgiler"
    sed -i "s/$urun_adı/$yeni_urun_adı,$yeni_stok_miktarı,$yeni_birim_fiyat,$yeni_kategori/" csv/depo.csv
    zenity --info --text="Ürün başarıyla güncellendi!"
}
function urun_listele() {
  
# Ürün Listeleme
if [[ -f "csv/depo.csv" ]]; then
    zenity --text-info --title="Ürün Listesi" --filename="csv/depo.csv" --width=600 --height=400
else
    zenity --error --text="Depo dosyası bulunamadı!"
fi
}

# Kullanıcı ekleme (kayıt)
function kullanici_ekle() {
    while true; do
        bilgiler=$(zenity --forms --title="Kullanıcı Kayıt Ol" \
            --text="Kullanıcı bilgilerini girin:" \
            --add-entry="Kullanıcı Adı" \
            --add-entry="Adı" \
            --add-entry="Soyadı" \
            --add-password="Şifre")
        if [[ -z "$bilgiler" ]]; then
            zenity --error --text="Bilgiler boş olamaz!"
            continue
        fi

        IFS="|" read -r kullanici adi soyadi sifre <<< "$bilgiler"
        hashed_sifre=$(echo -n "$sifre" | md5sum | awk '{print $1}')
        echo "$kullanici,$adi,$soyadi,Kullanıcı,$hashed_sifre" >> csv/kullanici.csv
        zenity --info --text="Kullanıcı başarıyla kaydedildi!"
        break
    done
}

# Kullanıcı giriş
function kullanici_giris() {
    while true; do
        giris_bilgileri=$(zenity --forms --title="Kullanıcı Giriş Yap" \
            --text="Kullanıcı bilgilerini girin:" \
            --add-entry="Kullanıcı Adı" \
            --add-password="Şifre")
        if [[ -z "$giris_bilgileri" ]]; then
            zenity --error --text="Bilgiler boş olamaz!"
            continue
        fi

        IFS="|" read -r kullanici sifre <<< "$giris_bilgileri"
        hashed_sifre=$(echo -n "$sifre" | md5sum | awk '{print $1}')
        kullanici_satiri=$(grep -w "$kullanici" csv/kullanici.csv | grep -w "$hashed_sifre")

        if [[ -z "$kullanici_satiri" ]]; then
            zenity --error --text="Geçersiz kullanıcı adı veya şifre!"
            continue
        fi

        rol=$(echo "$kullanici_satiri" | awk -F',' '{print $4}')
        zenity --info --text="Giriş başarılı! Rol: $rol"
        echo "$rol"
        break
    done
}
# Stokta Azalan Ürünler
function stokta_azalan_urunler() {
    esik_deger=$(zenity --entry --title="Eşik Değer Girin" --text="Lütfen stok eşik değerini girin:")

    if [[ -z "$esik_deger" || ! "$esik_deger" =~ ^[0-9]+$ ]]; then
        zenity --error --text="Geçerli bir sayı girmelisiniz!"
        return
    fi

    # csv/depo.csv dosyasından eşik değerin altındaki ürünleri filtreleme
    sonuc=$(awk -F',' -v esik="$esik_deger" '$3 < esik {print "Ürün: "$2", Stok: "$3}' csv/depo.csv)

    if [[ -z "$sonuc" ]]; then
        zenity --info --text="Eşik değerin altındaki ürün bulunamadı!"
    else
        zenity --info --title="Stokta Azalan Ürünler" --text="$sonuc"
    fi
}

# En Yüksek Stok Miktarı
function en_yuksek_stok() {
    # csv/depo.csv dosyasından en yüksek stoklu ürünü bulma
    sonuc=$(awk -F',' 'NR==1 {next} {if($3 > max) {max=$3; urun=$2;}} END {print "Ürün: " urun ", Stok: " max}' csv/depo.csv)

    if [[ -z "$sonuc" ]]; then
        zenity --error --text="Ürün listesi boş ya da dosya bulunamadı!"
    else
        zenity --info --title="En Yüksek Stoklu Ürün" --text="$sonuc"
    fi
}
# Rapor Al Menüsü
function rapor_al() {
    secim=$(zenity --list --title="Rapor Al" --text="Lütfen bir işlem seçin:" \
        --column="ID" --column="İşlem" \
        1 "Stokta Azalan Ürünler" \
        2 "En Yüksek Stok Miktarı" \
        --height=250 --width=400)

    case $secim in
        1)
            stokta_azalan_urunler
            ;;
        2)
            en_yuksek_stok
            ;;
        *)
            zenity --info --text="Geçersiz seçim yaptınız veya iptal ettiniz!"
            ;;
    esac
}
# Kullanıcı işlemleri
function kullanici_menusu() {
    while true; do
        secim=$(zenity --list --title="Kullanıcı Menüsü" \
            --column="ID" --column="İşlem" \
            1 "Ürünleri Görüntüle" \
            2 "Rapor Al" \
            3 "Çıkış")
        case $secim in
            1) urun_listele ;;
            2) rapor_al ;;
            3) break ;;
            *) zenity --error --text="Geçersiz seçim yaptınız!" ;;
        esac
    done
}

function ana_ekran() {
    while true; do
        secim=$(zenity --list --title="Ana Menü" \
            --column="ID" --column="Seçenek" \
            1 "Yönetici" \
            2 "Kullanıcı" \
            3 "Çıkış")
        case $secim in
            1)
                yonetici_secim=$(zenity --list --title="Yönetici Seçenekleri" \
                    --column="ID" --column="Seçenek" \
                    1 "Giriş Yap" \
                    2 "Kayıt Ol" \
                    3 "Geri Dön")
                case $yonetici_secim in
                    1) 
                        yonetici_giris
                        if [[ "$rol" == "Yönetici" ]]; then
                            yonetici_menusu
                        else
                            zenity --error --text="Yalnızca yönetici girişi yapılabilir!"
                        fi
                        ;;
                    2) yonetici_ekle ;;
                    3) continue ;;
                    *) zenity --error --text="Geçersiz seçim!" ;;
                esac
                ;;
            2)
                kullanici_secim=$(zenity --list --title="Kullanıcı Seçenekleri" \
                    --column="ID" --column="Seçenek" \
                    1 "Giriş Yap" \
                    2 "Kayıt Ol" \
                    3 "Geri Dön")
                case $kullanici_secim in
                    1) 
                        kullanici_giris
                        [[ "$rol" == "Kullanıcı" ]] && kullanici_menusu
                        ;;
                    2) kullanici_ekle ;;
                    3) continue ;;
                    *) zenity --error --text="Geçersiz seçim!" ;;
                esac
                ;;
            3) # Çıkış işlemi için onay penceresi
                zenity --question --title="Çıkış" --text="Sistemi kapatmak istediğinizden emin misiniz?"
                if [[ $? -eq 0 ]]; then
                    zenity --info --text="Sistemden çıkılıyor..."
                    exit 0
                else
                    zenity --info --text="Çıkış iptal edildi. İşlem devam ediyor..."
                fi
                ;;
            *) zenity --error --text="Geçersiz seçim!" ;;
        esac
    done
}

# Program başlatılıyor
ana_ekran  # Ana ekranı başlat

