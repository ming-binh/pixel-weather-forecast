# Pixel Weather

Ứng dụng dự báo thời tiết phong cách pixel-art, viết bằng Flutter. Toàn bộ
sprite (icon thời tiết, mèo mascot, nền trời) được vẽ thủ tục — không dùng
ảnh — và dữ liệu thời tiết lấy trực tiếp từ [Open-Meteo](https://open-meteo.com/)
(miễn phí, không cần API key).

## Tính năng

- Trang chủ: nhiệt độ hiện tại, cảm giác như, dự báo 12 giờ tới và 7 ngày tới,
  độ ẩm/UV/gió, lời khuyên theo thời tiết từ mèo mascot.
- Đổi địa điểm giữa 6 thành phố đã lưu, mỗi thành phố hiện nhiệt độ thật riêng.
- Nền trời và bảng màu đổi theo giờ trong ngày (bình minh/ban ngày/hoàng
  hôn/ban đêm) và điều kiện thời tiết.
- Đổi đơn vị °C/°F, xem lại toàn bộ bảng màu và sprite trong màn Style Guide.
- Tự động thử lại khi gọi API lỗi (mất mạng, timeout).

## Cấu trúc

```
lib/
  data/            Toạ độ thành phố, bảng màu theo giờ/thời tiết, service gọi Open-Meteo
  logic/            Hàm suy ra icon/mascot/đơn vị nhiệt độ từ state
  pixel/            Bộ vẽ pixel-art thủ tục (grid, sprite, mascot)
  screens/           Splash, Home, Locations, Settings, Style Guide, Day sheet
  theme/             Màu sắc, font chữ (Pixelify Sans, Be Vietnam Pro)
  widgets/           Các thành phần UI dùng chung (panel, nav, nền trời...)
```

## Chạy dự án

Yêu cầu [Flutter SDK](https://docs.flutter.dev/get-started/install) đã cài đặt.

```bash
flutter pub get
flutter run
```

Không cần cấu hình API key — Open-Meteo là API công khai, miễn phí.

## Kiểm tra

```bash
flutter analyze
flutter test
```
