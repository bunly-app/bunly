# A05-02 — Bản nháp ledger/quota, kiểm thử PostgreSQL riêng

Ngày 09/11/2026. Scope backend LOCAL theo runbook. HEAD `3ae5be9625edaa3a761253a4e578daa416a97322` + working tree chưa commit; không phải CI hoặc schema đã được triển khai. Đây là **bản nháp để review**, chưa được Ánh/Hoàng/Vy phê duyệt và chưa nghiệm thu A05.

## Đầu ra có thể review

- `supabase/proposals/a05-analysis-ledger.sql`: tách khỏi thư mục migrations để không tự áp khi local stack khởi động hoặc khi người khác chạy migration. Không sửa core migration hoặc config Supabase.
- `scripts/verify-a05-ledger.py`: tạo database tên ngẫu nhiên `bunly_a05_review_<12 hex>` bên trong container local `supabase_db_bunly`, kiểm thử rồi chỉ drop đúng database do lần gọi đó tạo. Không reset, copy hoặc sửa DB ứng dụng `postgres`; không đọc key/status/credentials. Script yêu cầu marker không chờ người dùng và lease môi trường còn hạn.
- Chạy từ gốc checkout: `python scripts/verify-a05-ledger.py`. Cần Docker/stack local hiện có, Python và role service_role/anon/authenticated của cluster local. Không kết nối hosted. Khi áp bản chính thức sau review, tạo migration mới bằng CLI pin; **không chạy proposal lên DB ứng dụng ngay**.

## Thiết kế được kiểm thử

Schema private có entitlement do server quản trị, usage theo user/ngày UTC và request ledger theo `(user_id, request_id)`. Không lưu text request hoặc private provider key; fingerprint SHA256 tới từ module A05-01. Result chỉ lưu sau validate của server. Không tự chọn Free 5/Pro 20: mức thử 1/2/3 trong scratch chỉ là fixture; user thiếu entitlement nhận unavailable.

Hai RPC public nhưng chỉ service_role có EXECUTE, SECURITY INVOKER và search_path rỗng; anon/authenticated không có quyền đọc ledger hoặc tự sửa hạn mức. Cả ba bảng private bật RLS, không mở policy cho client; không thêm schema private vào Data API. Service role là boundary tin cậy phía server, **không phải** credential client hoặc bằng chứng cách ly Auth. Handler tương lai bắt buộc xác minh user trước khi truyền owner vào RPC; caller không được tự chọn user_id.

Mỗi transition khóa entitlement → request → usage cùng thứ tự, transaction ngắn. Reserve nguyên tử, không giữ transaction chờ model. Success/no-match tiêu một lượt; timeout/unavailable/invalid_output hoàn reservation một lần. Duplicate trả trạng thái/kết quả đã commit với quota **hiện tại**, không snapshot quota cũ. Retry lỗi retryable tăng generation; callback của generation cũ không được finalize reservation mới. Finalize lỗi DB rollback toàn bộ và có thể retry cùng generation mà không gọi lại provider.

**Giới hạn quan trọng:** request processing không tự reclaim chỉ vì cũ; điều này ngăn worker còn sống gọi trùng provider, nhưng request bị crash có thể bị kẹt. Cần chốt provider/idempotency/status và quy trình reconciliation/worker liveness trước endpoint thật. Chưa có cơ chế tự khôi phục crash, heartbeat, audit chi phí provider hoặc entitlement admin tool. Không coi draft này là toàn bộ yêu cầu lease/generation A05 đã hoàn tất.

## Bằng chứng mới

`python scripts/verify-a05-ledger.py`: **32/32 checks đạt, exit 0** trên PostgreSQL **17.11** local. Log cuối `build/a01-build-evidence-2026-11-09/a05-ledger-tests-final.log`, bị Git ignore; chưa upload. Bản đầu 26 checks đạt; thêm lỗi finalize và cạnh tranh cùng UUID trước lượt cuối 32 checks.

Các case thực: hai connection tranh lượt cuối chỉ một claim; hai connection cùng UUID chỉ một worker; finalize đồng thời chỉ tính một success; conflict fingerprint; processing duplicate; no-match; refund lặp; replay theo quota/entitlement mới; retry generation; callback cũ; user scope của UUID; qua ngày UTC; không có entitlement; lỗi DB sau finalize rollback và retry cùng generation. Test anon/authenticated bị từ chối RPC/đọc ledger/tự nâng quota. Hai RPC qua `plpgsql_check_function_tb` trong scratch không có error/warning. Mọi scratch DB do hai lượt tạo đã được dọn.

Scratch chỉ có bảng `auth.users(id)` tối thiểu cho FK, **không có Auth server giả được tính là Auth thật**. Bằng chứng Auth/API thật thuộc suite connected SDK trong báo cáo A01 tiếp tục, tách khỏi 32 checks này. Chưa chạy REST RPC qua PostgREST, Deno/Edge runtime, provider/model thật hoặc hosted RLS. SQL checks không thay cho kiểm chứng API endpoint và A/B session thật của Function.

## Bước cần quyết định trước tích hợp

Theo `BASELINE-DELIVERY-OWNERSHIP.md`, A02 cần Ánh review trước thay schema/contract. Proposal và test đã sẵn để review; schema app vẫn nguyên. Cần xác nhận trạng thái review trước chuyển proposal thành migration/apply local.

Chưa có provider/model/ngân sách/quota được chủ sản phẩm chốt. Adapter model thật và xử lý request bị treo phụ thuộc giao thức/idempotency của provider; không tự chọn tài khoản hoặc phát sinh chi phí. Không đề nghị gửi API key trong chat; sau khi chọn sẽ hướng dẫn cấu hình secret local ngoài Git.
