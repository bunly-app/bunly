# A05-03 — Backend local và hướng AI miễn phí

Ngày 09/11/2026, Asia/Bangkok. Người dùng trả lời trực tiếp: **A02 đã được Ánh duyệt** và **dùng miễn phí trước, nâng cấp sau**. Đây là xác nhận review A02 và ngân sách 0 cho giai đoạn hiện tại, không phải quyền bật billing, deploy hosted hoặc tự tạo tài khoản/API key. Mã mới A05-03 vẫn cần review; không tự gán Ánh/Vy đã duyệt mã hoặc nội dung mới.

HEAD `3ae5be9625edaa3a761253a4e578daa416a97322` + working tree chưa commit. Đã giải quyết marker cũ bằng chính câu trả lời của người dùng, claim lease qua CreateNew rồi thực hiện. Không sửa Flutter/Drift/pubspec/lockfiles, không commit/push/reset/worktree.

## Thay đổi đã thực hiện

- CLI pin 2.121.0 tạo `20261109094914_a05_analysis_ledger.sql`, áp bằng **migration up --local** trên volume local hiện có. Nội dung từ proposal đã bàn giao, không đặt quota mặc định cho người dùng.
- Strict lint phát hiện hai biến v_limit không được đọc. Tạo migration nối tiếp `20261109095651_a05_analysis_lock_cleanup.sql` dùng PERFORM để giữ row lock; không viết lại migration đã áp. Lượt lint cuối public + bunly_analysis_private không có lỗi/cảnh báo.
- Handler `analysis-service.mjs` xác minh user trước đọc body, lấy candidate server, reserve, gọi model, validate output và finalize. Duplicate không gọi model lại; replay dùng quota hiện tại và kiểm tra lại allowlist. DB-finalize lỗi không bị biến thành refund vì model có thể đã thành công. request_id là null nếu lỗi xảy ra trước khi parse được input.
- `supabase-analysis.mjs` dùng Auth **get user** qua HTTP, không tin JWT decode/user_metadata/user_id từ body. Catalog có allowlist UUID cấu hình phía server; default rỗng nên không tự biến 12 fixture draft thành nội dung duyệt. RPC bằng service key chỉ phía server; client anon/authenticated bị từ chối gọi trực tiếp.
- `gemini-free.mjs` dùng REST generateContent với **gemini-2.5-flash-lite**, header key (không đưa vào URL), JSON schema, 20 giây, tối đa 1024 output tokens, context/response chặn ở 64 KiB. Không tools, grounding, retry tự động hoặc fallback sang model khác. Thiếu key/không xác nhận Free Tier thì không gửi request model.
- `analyze-grammar/index.ts` là entrypoint Deno. `supabase/config.toml` bật Edge runtime **local**, verify_jwt=true. Không tắt JWT để vượt lỗi và không sửa cấu hình hosted.
- Thêm template `config/functions.env.example` và bản local **.env.functions.local** (đã xác nhận Git ignore). File local hiện key trống, free-tier confirmation=false, allowlist rỗng; không overwite nếu đã có. Không chứa secret thật trong source/example/log.

## Lựa chọn miễn phí và giới hạn chi phí

[Bảng giá Google](https://ai.google.dev/gemini-api/docs/pricing) kiểm tra ngày 09/11/2026 liệt kê input/output Standard của Gemini 2.5 Flash-Lite có Free Tier. Adapter chọn đúng model này; chưa chạy evaluation chất lượng hoặc kết nối model thật. Nguồn REST/schema: [Generate content](https://ai.google.dev/api/generate-content).

**Code không thể xác định billing tier từ API key.** Cần người dùng tạo/chọn project Gemini Free Tier **không bật billing**, rồi mới xác nhận GEMINI_FREE_TIER_CONFIRMED=true. Cùng model trên project trả phí vẫn có thể phát sinh phí; allowlist model không tự bảo đảm miễn phí. Không bật billing hoặc tạo paid fallback trong giai đoạn này. Google ghi dữ liệu Free Tier được dùng để cải thiện sản phẩm; lượt thử đầu sẽ chỉ dùng câu mẫu công khai/tổng hợp, không lấy câu riêng tư của người dùng. Không có request nào từ lượt này gửi tới Google.

Quota thành công/ngày UTC cho tài khoản Bunly vẫn chưa được người dùng chốt (Free 5/Pro 20 trước đây là đề xuất). Entitlement không tồn tại → unavailable; không tự cấp Pro hoặc áp limit thật. Các limit 1/2 trong tests chỉ thuộc tài khoản dùng một lần và đã dọn. Cần hạn mức cụ thể trước bật AI cho app user.

## Kiểm chứng thực tế

Evidence local bị Git ignore: `build/a05-03-evidence-2026-11-09/`, chưa upload. Không chứa bản status/key thô; runner truyền status vào Node qua stdin trong bộ nhớ.

| Kiểm tra | Kết quả cuối |
|---|---|
| Hai migration local | PASS, không reset; migration-up.log và migration-cleanup-up.log |
| Node contract/handler/Gemini transport | **29/29 đạt**, node-tests-final.log; transport giả, không phải model thật |
| Database lint --local --schema public,bunly_analysis_private --level warning --fail-on warning | **PASS**, No schema errors found; db-lint-final.log |
| Supabase test db --local | **56 pgTAP tests đạt**: 39 core + 17 analysis; transaction/rollback, db-tests-final.log |
| python scripts/verify-a05-ledger.py --current-migrations | **32/32 đạt** trong DB tạm do runner tạo/dọn, dùng đúng cả hai migration hiện tại; hai connection tranh quota/cùng UUID, stale generation, finalize lỗi/rollback và lint bao gồm warning extra; ledger-current-migrations.log |
| scripts/verify-a05-api-local.py | **1 integration scenario đạt**, Auth và PostgREST/SQL thật, model stub tách rõ. Signup test admin-confirmed → login A/B, reserve/success/replay/conflict/quota, client không gọi server RPC, B có ledger độc lập. Chỉ xóa các test identities do chính lượt đó tạo |
| Edge runtime thật | CLI lấy image v1.77.4 (Deno 2.1.4); gateway không JWT trả 401; JWT hợp lệ vào handler Deno trả đúng JSON 503/unavailable khi chưa cấu hình model. **Không** chứng minh phân tích AI thành công |

Lượt integration đầu dùng node --test làm worker không nhận stdin của runner nên bị chờ. Đã dừng đúng worker riêng chưa chạy setup, đổi runner sang node trực tiếp (node:test vẫn thực thi). Một lượt sau nhận Auth 503 trong giai đoạn runtime đang reload file; chưa kết luận nguyên nhân gốc. Sau runtime ổn định chạy lại đạt; lưu log lỗi và log cuối api-edge-retry.log, không đổi kết quả lỗi thành skip. Production handler vẫn ánh xạ Auth outage thành unavailable an toàn.

Đã dừng command/container Edge do lượt này mở trước khi thả lease. Docker/DB/Auth/REST local vẫn chạy; không dọn/reset dữ liệu cũ. Khi tiếp tục cần nhận lease rồi chạy functions serve; không để watcher giữ checkout lúc luồng khác làm việc.

## Bàn giao cho luồng Flutter và cách dùng sau cấu hình

Local endpoint: POST `http://127.0.0.1:54321/functions/v1/analyze-grammar`, client gửi JWT bằng Supabase Function invoke, body đúng request_id/text/locale=vi theo A02. Backend trả matches + remaining_quota, processing 202, errors theo contract. Native Android dùng địa chỉ local phù hợp emulator/USB như GETTING_STARTED; chưa có Cloud endpoint đã deploy hoặc CORS cho web được nghiệm thu.

Luồng Flutter chưa được sửa để gọi endpoint này. Cần giữ draft theo owner, xử lý request_id=null ở lỗi trước parse, reuse request UUID khi retry, no-match/manual lookup, không đưa GEMINI_API_KEY/service key vào dart-defines.

Sau khi người dùng cấu hình key Free Tier ngoài Git và xác nhận hạn mức/candidate đã duyệt:

```powershell
# Chỉ khi có lease và waiting marker đã được giải quyết.
./node_modules/.bin/supabase.cmd functions serve analyze-grammar --env-file .env.functions.local
```

File local có GEMINI_API_KEY, GEMINI_FREE_TIER_CONFIRMED=true sau khi kiểm tra billing, BUNLY_APPROVED_GRAMMAR_IDS là JSON UUID array nội dung đã duyệt. Không tự nhập fixture draft vào allowlist. Key chỉ phía server, không gửi vào chat hoặc commit. Tạo key theo [hướng dẫn Google AI Studio](https://ai.google.dev/gemini-api/docs/api-key); người dùng tự đăng nhập/xử lý điều khoản.

Để chạy integration local với provider stub: `python scripts/verify-a05-api-local.py`. Nếu cần kiểm tra Edge fail-closed, khởi động runtime **không cấu hình key**, đặt BUNLY_CHECK_EDGE_RUNTIME=1 cho riêng tiến trình runner. Không dùng case fail-closed với một runtime đã được bật AI thật.

## Còn chặn / chưa nghiệm thu

Key/project Free Tier cần người dùng tự cấu hình; quota Bunly và allowlist nội dung cần xác nhận. Chưa gọi model thật hoặc đo độ đúng/latency, chưa có crash/liveness reconciliation cho request processing bị treo (không tự reclaim bằng TTL), chưa có admin entitlement UI/tool, chưa có Cloud deployment hoặc Flutter integration. Không gọi A05, B0/B1 hay sản phẩm đầy đủ đã hoàn tất.
