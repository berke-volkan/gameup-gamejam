# Yeşil Sızıntı: Eco-Breach

Godot 4.7 / GDScript / Compatibility renderer ile hazırlanmış, yatay mobil oynanabilir COP31 oyun demosu. Oyuncu, Antalya zirvesi öncesi emisyon verilerini saklayan EcoCorp tesisine sızan bir iklim dedektifidir.

## Oynanış

- Labirentte WASD, ok tuşları, dokunma veya ekrandaki yön tuşlarıyla ilerle.
- Güvenlik dronlarından kaç; üstteki **+1,5°C Devrilme Noktası** sayacı 100'e ulaşmadan görevleri tamamla.
- Üç terminali hackle: temiz enerji dönüşümü, sıfır atık üretim bandı ve ana sunucu/rapor ifşası.
- Her başarılı hack sıcaklığı düşürür ve koridorların rengini gri-güvenden yeşil umuda dönüştürür.
- Üç terminalden sonra X çıkışına ulaş ve gerçek emisyon verisini COP31'e sızdır.

## UI ve varlıklar

Paneller ve butonlar Godot `StyleBoxFlat` ile çizilir. Menüde Kenney UI Pack'ten CC0 lisanslı referans görseli kullanılır; kaynak `ASSET_CREDITS.md` içindedir.

## Çalıştırma

Godot 4.7+ ile `project.godot` dosyasını açıp **Play Project** seçin. Referans viewport 1280×720, mobil yön yataydır.

## APK export

Hazır release APK: `build/eco-breach-release.apk`

Tekrar üretmek için Android SDK/JDK ve Godot export templates kurulu olmalıdır:

```bash
godot --path . --headless --export-release "Android" build/eco-breach-release.apk
```

Release imzası için Project > Export > Android > Keystore alanlarını doldurun.
[?2004l