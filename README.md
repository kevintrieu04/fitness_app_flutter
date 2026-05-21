# Fitness Tracker - Ứng dụng theo dõi tiến độ và cá nhân hóa các bài tập thể dục

Fitness Tracker là ứng dụng hỗ trợ tập các bài tập thể dục sử dụng mô hình AI on-device, và tích hợp Firebase để lưu và theo dõi tiến độ

## 1. Yêu cầu hệ thống
Thiết bị di động hoặc giả lập có hệ điều hành Android 10+ hoặc iOS 14+.  
Android Studio hoặc VS Code có Plugin Dart và Flutter.
Flutter và Dart SDK phiên bản mới nhất.

## 2. Hướng dẫn Cài đặt

### Bước 1: Clone dự án
```bash
git clone [https://github.com/kevintrieu04/fitness_app_flutter.git](https://github.com/kevintrieu04/fitness_app_flutter.git)
cd src
```

### Bước 2: Cài đặt phụ thuộc
```bash
flutter pub get
```

### Bước 3: Cấu hình Firebase

- Tại Firebase Console, tạo một dự án mới.
- Kết nối tới dự án này theo hướng dẫn trên trang: Android: google-services.json đặt vào src/android/app/, iOS: GoogleService-Info.plist đặt vào src
- Bật các dịch vụ trong Firebase Console: Email/Password Authentication và Firestore

## 3. Chạy thử phần mềm
- Kết nối máy tính với điện thoại hoặc trình giả lập,
- Chạy lệnh:

```bash
flutter run
```

