# CookConnect - Hướng Dẫn Dành Cho AI Agent & Nhà Phát Triển

Tài liệu này cung cấp các hướng dẫn quan trọng cho AI Agent và các lập trình viên khi làm việc với dự án **CookConnect Monorepo** (gồm ứng dụng Flutter `apps/customer`, `apps/supplier`, và các packages dùng chung `packages/shared_cores`, `packages/shared_widgets`).

---

## 1. Swagger & API Documentation

Hệ thống Backend của CookConnect cung cấp tài liệu API chuẩn OpenAPI/Swagger UI giúp tra cứu các endpoint, cấu trúc request/response (DTO), và thử nghiệm API trực tiếp.

### 📍 Đường dẫn truy cập Swagger UI
- **URL xem Swagger chính thức:**
  ```text
  http://localhost:8080/docs
  ```
- **Khi chạy trên mạng LAN hoặc thiết bị thật:**
  ```text
  http://<YOUR_LAN_IP>:8080/docs
  # Ví dụ: http://192.168.1.162:8080/docs
  ```
- **Prefix phiên bản API:** `/api/v1`

---

## 2. Hướng Dẫn Sử Dụng Swagger UI

Khi phát triển hoặc kiểm thử API, hãy sử dụng giao diện Swagger UI theo các bước sau:

### 2.1. Khám phá Endpoints & Cấu trúc Dữ liệu
- **Nhóm chức năng (Tags):** Các API được chia theo từng module cụ thể:
  - `Auth`: Xác thực tài khoản, gửi OTP, đăng nhập, làm mới token (`/api/v1/auth/*`).
  - `Users`: Thông tin hồ sơ, avatar, bio, mạng xã hội (`/api/v1/users/*`).
  - `Suppliers / Commerce / Products`: Quản lý danh mục hàng hóa, nhà cung cấp, biến thể sản phẩm (`/api/v1/products/*`, `/api/v1/suppliers/*`).
  - `Orders`: Quản lý đơn đặt hàng và trạng thái đơn (`/api/v1/supplier/orders/*`).
- **Chi tiết Request / Response:**
  - Nhấp vào từng endpoint để xem thông tin chi tiết: HTTP Method (`GET`, `POST`, `PUT`, `DELETE`, `PATCH`).
  - Mở tab **Schema** để kiểm tra kiểu dữ liệu, các trường bắt buộc (`required`), trường tùy chọn (`optional`), và kiểu dữ liệu chuẩn (`string`, `integer`, `boolean`, `array`, `object`).

### 2.2. Kiểm thử API trực tiếp (Try it out)
1. Chọn endpoint cần kiểm tra.
2. Bấm vào nút **`Try it out`** ở góc phải của endpoint.
3. Điền các giá trị vào mục **Parameters** (Query param, Path param) hoặc sửa JSON trong mục **Request body**.
4. Bấm nút **`Execute`**.
5. Kiểm tra kết quả trả về:
   - **Curl Command:** Lệnh cURL mẫu tương ứng.
   - **Response Body:** Dữ liệu JSON trả về từ backend.
   - **Response Code:** Mã trạng thái HTTP (`200 OK`, `201 Created`, `400 Bad Request`, `401 Unauthorized`, `404 Not Found`,...).

### 2.3. Xác thực Bearer Token (Authorize)
Đối với các endpoint yêu cầu bảo mật (có biểu tượng ổ khóa 🔒):
1. Gọi API đăng nhập `/api/v1/auth/login` (hoặc `/api/v1/auth/register`) để lấy access token từ response:
   ```json
   {
     "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6..."
   }
   ```
2. Cuộn lên đầu trang Swagger UI, bấm vào nút **`Authorize`** (nằm ở góc trên bên phải).
3. Nhập token vào ô **Value**:
   - Nếu dạng Bearer: nhập `Bearer <access_token>` hoặc `<access_token>` (tùy cấu hình scheme).
4. Bấm **`Authorize`** và nhấn **`Close`**.
5. Lúc này biểu tượng ổ khóa sẽ đóng lại. Tất cả các request sau đó sẽ tự động gửi kèm header:
   ```text
   Authorization: Bearer <access_token>
   ```

---

## 3. Quy Tắc Dành Cho AI Agent & Lập Trình Viên

1. **Đối chiếu API Contract trước khi tạo DTO:**
   - Trước khi tạo mới hoặc sửa bất kỳ model DTO / Service nào trong `apps/customer/lib` hoặc `apps/supplier/lib`, hãy tham chiếu schema trên Swagger tại `http://localhost:8080/docs`.
   - Tên biến trong code Dart cần serialize/deserialize (`fromJson`, `toJson`) chính xác với tên field trong Swagger schema.

2. **Cập nhật ApiConfig tập trung:**
   - Khi backend bổ sung endpoint mới, thêm path và URL tương ứng vào:
     - `apps/customer/lib/core/config/api_config.dart`
     - `apps/supplier/lib/core/config/api_config.dart`
   - Tuyệt đối không hardcode URL rải rác trong các file UI hoặc repository.

3. **Cấu hình môi trường mạng:**
   - Khi chạy giả lập iOS Simulator / macOS desktop / Chrome: dùng `http://localhost:8080`.
   - Khi chạy trên Android Emulator: dùng `http://10.0.2.2:8080`.
   - Khi chạy trên thiết bị di động thật: cấu hình địa chỉ IP LAN của máy tính chạy server vào file `.env` hoặc truyền qua `--dart-define=API_BASE_URL=http://<LAN_IP>:8080`.
