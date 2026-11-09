import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/grammar_analysis.dart';

bool _isNetworkError(Object error) =>
    error is SocketException ||
    error.runtimeType.toString().contains('ClientException');

class SupabaseGrammarAnalysisRepository implements GrammarAnalysisRepository {
  SupabaseGrammarAnalysisRepository(
    this.client, {
    this.timeout = const Duration(seconds: 30),
  });

  final SupabaseClient client;
  final Duration timeout;

  @override
  Future<AnalysisQuotaStatus> loadQuota() async {
    final session = client.auth.currentSession;
    if (session == null) {
      throw const AnalysisException(
        AnalysisFailureKind.unauthenticated,
        message: 'Cần đăng nhập để kiểm tra lượt phân tích AI.',
      );
    }
    try {
      final raw = await client.rpc('bunly_my_analysis_quota').timeout(timeout);
      if (raw is! Map) {
        throw const AnalysisException(
          AnalysisFailureKind.invalidOutput,
          message: 'Dữ liệu hạn mức không hợp lệ.',
        );
      }
      final data = Map<String, dynamic>.from(raw);
      return AnalysisQuotaStatus(
        hasEntitlement: data['has_entitlement'] as bool? ?? false,
        dailyLimit: (data['daily_limit'] as num?)?.toInt() ?? 0,
        usedToday: (data['used_today'] as num?)?.toInt() ?? 0,
        reservedToday: (data['reserved_today'] as num?)?.toInt() ?? 0,
        remainingQuota: (data['remaining_quota'] as num?)?.toInt() ?? 0,
        resetAtUtc: DateTime.parse(data['reset_at_utc'] as String).toUtc(),
      );
    } on AnalysisException {
      rethrow;
    } on TimeoutException {
      throw const AnalysisException(
        AnalysisFailureKind.timeout,
        retryable: true,
        message: 'Kiểm tra lượt phân tích mất quá nhiều thời gian.',
      );
    } on PostgrestException catch (e) {
      if (e.code == '42501') {
        throw const AnalysisException(
          AnalysisFailureKind.unauthenticated,
          message: 'Phiên đăng nhập đã hết hạn. Hãy đăng nhập lại.',
        );
      }
      throw const AnalysisException(
        AnalysisFailureKind.unavailable,
        retryable: true,
        message: 'Chưa đọc được hạn mức phân tích lúc này.',
      );
    } catch (e) {
      if (_isNetworkError(e)) {
        throw const AnalysisException(
          AnalysisFailureKind.offline,
          retryable: true,
          message: 'Chưa có kết nối mạng hoặc không thể kết nối máy chủ.',
        );
      }
      throw const AnalysisException(
        AnalysisFailureKind.unavailable,
        retryable: true,
        message: 'Chưa đọc được hạn mức phân tích lúc này.',
      );
    }
  }

  @override
  Future<GrammarAnalysisResult> analyze({
    required String requestId,
    required String normalizedText,
    String locale = 'vi',
  }) async {
    final session = client.auth.currentSession;
    if (session == null) {
      throw AnalysisException(
        AnalysisFailureKind.unauthenticated,
        requestId: requestId,
        message: 'Bạn cần đăng nhập trước khi gọi phân tích AI.',
      );
    }
    try {
      final response = await client.functions
          .invoke(
            'analyze-grammar',
            body: {
              'request_id': requestId,
              'text': normalizedText,
              'locale': locale,
            },
          )
          .timeout(timeout);

      final map = _decodeObject(response.data);
      if (response.status == 202 || map['status'] == 'processing') {
        throw AnalysisException(
          AnalysisFailureKind.processing,
          requestId: map['request_id'] as String? ?? requestId,
          retryAfterMs: (map['retry_after_ms'] as num?)?.toInt() ?? 1000,
          retryable: true,
          message: 'Yêu cầu phân tích trước đó vẫn đang được xử lý.',
        );
      }

      final respId = map['request_id'];
      final rawMatches = map['matches'];
      final remainingQuota = (map['remaining_quota'] as num?)?.toInt();
      if (respId is! String || rawMatches is! List) {
        throw AnalysisException(
          AnalysisFailureKind.invalidOutput,
          requestId: requestId,
          message: 'Phản hồi phân tích không đúng định dạng.',
        );
      }

      final matches = <GrammarAnalysisMatch>[];
      for (final item in rawMatches) {
        if (item is! Map) {
          throw AnalysisException(
            AnalysisFailureKind.invalidOutput,
            requestId: respId,
            message: 'Dữ liệu mẫu ngữ pháp trả về không hợp lệ.',
          );
        }
        final entry = Map<String, dynamic>.from(item);
        final grammarId = entry['grammar_id'];
        if (grammarId is! String) {
          throw AnalysisException(
            AnalysisFailureKind.invalidOutput,
            requestId: respId,
            message: 'Thiếu mã mẫu ngữ pháp trong phản hồi.',
          );
        }
        AnalysisUtf16Span? span;
        if (entry.containsKey('span') && entry['span'] != null) {
          if (entry['span'] is! Map) {
            throw AnalysisException(
              AnalysisFailureKind.invalidOutput,
              requestId: respId,
              message: 'Thông tin vị trí ngữ pháp không hợp lệ.',
            );
          }
          final rawSpan = Map<String, dynamic>.from(entry['span'] as Map);
          final start = rawSpan['start_utf16'];
          final end = rawSpan['end_utf16'];
          final spanText = rawSpan['text'];
          if (start is! int || end is! int || spanText is! String) {
            throw AnalysisException(
              AnalysisFailureKind.invalidOutput,
              requestId: respId,
              message: 'Vị trí trích dẫn ngữ pháp không đúng kiểu dữ liệu.',
            );
          }
          span = AnalysisUtf16Span(
            startUtf16: start,
            endUtf16: end,
            text: spanText,
          );
        }
        matches.add(GrammarAnalysisMatch(grammarId: grammarId, span: span));
      }

      return GrammarAnalysisResult(
        requestId: respId,
        text: normalizedText,
        matches: matches,
        remainingQuota: remainingQuota,
        isLiveAi: true,
      );
    } on AnalysisException {
      rethrow;
    } on FunctionException catch (e) {
      throw _mapFunctionException(e, requestId);
    } on TimeoutException {
      throw AnalysisException(
        AnalysisFailureKind.timeout,
        requestId: requestId,
        retryable: true,
        message:
            'Hết thời gian chờ (30s). Có thể máy chủ vẫn đang xử lý yêu cầu này — hãy bấm thử lại để kiểm tra.',
      );
    } catch (e) {
      if (_isNetworkError(e)) {
        throw AnalysisException(
          AnalysisFailureKind.offline,
          requestId: requestId,
          retryable: true,
          message:
              'Không có kết nối mạng hoặc không kết nối được máy chủ. Bản nháp câu vẫn được giữ trên máy.',
        );
      }
      throw AnalysisException(
        AnalysisFailureKind.unavailable,
        requestId: requestId,
        retryable: true,
        message: 'Dịch vụ phân tích hiện chưa sẵn sàng.',
      );
    }
  }

  Map<String, dynamic> _decodeObject(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String && data.trim().isNotEmpty) {
      final decoded = jsonDecode(data);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    throw const AnalysisException(
      AnalysisFailureKind.invalidOutput,
      message: 'Phản hồi máy chủ không đúng định dạng JSON.',
    );
  }

  AnalysisException _mapFunctionException(
    FunctionException e,
    String requestId,
  ) {
    Map<String, dynamic>? body;
    final details = e.details;
    if (details is Map) {
      body = Map<String, dynamic>.from(details);
    } else if (details is String && details.trim().startsWith('{')) {
      try {
        final decoded = jsonDecode(details);
        if (decoded is Map) body = Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }

    final reqId = body?['request_id'] as String? ?? requestId;
    final errorObj = body?['error'] is Map
        ? Map<String, dynamic>.from(body!['error'] as Map)
        : null;
    final code = errorObj?['code'] as String?;
    final retryable = errorObj?['retryable'] as bool? ?? false;

    return switch (code) {
      'invalid_input' => AnalysisException(
        AnalysisFailureKind.invalidInput,
        requestId: reqId,
        retryable: false,
        message: 'Câu nhập chưa hợp lệ (1–1000 ký tự, tối đa 8 KiB UTF-8).',
      ),
      'unauthenticated' => AnalysisException(
        AnalysisFailureKind.unauthenticated,
        requestId: reqId,
        retryable: false,
        message: 'Cần đăng nhập lại để sử dụng phân tích AI.',
      ),
      'request_conflict' => AnalysisException(
        AnalysisFailureKind.requestConflict,
        requestId: reqId,
        retryable: false,
        message:
            'Nội dung đã thay đổi so với yêu cầu trước. Hãy gửi yêu cầu mới.',
      ),
      'quota_exceeded' => AnalysisException(
        AnalysisFailureKind.quotaExceeded,
        requestId: reqId,
        retryable: false,
        message: 'Đã hết lượt phân tích AI hôm nay (tính theo ngày UTC).',
      ),
      'invalid_output' => AnalysisException(
        AnalysisFailureKind.invalidOutput,
        requestId: reqId,
        retryable: false,
        message:
            'Kết quả AI không khớp kho ngữ pháp chuẩn. Bạn có thể tìm thủ công hoặc thử phân tích lại.',
      ),
      'timeout' => AnalysisException(
        AnalysisFailureKind.timeout,
        requestId: reqId,
        retryable: true,
        message:
            'Mô hình AI phản hồi quá lâu. Bạn có thể thử lại cùng câu này.',
      ),
      'unavailable' => AnalysisException(
        AnalysisFailureKind.unavailable,
        requestId: reqId,
        retryable: true,
        message:
            'Dịch vụ phân tích AI hiện tạm chưa sẵn sàng (chưa cấu hình hoặc đang bảo trì).',
      ),
      _ => _mapByStatus(e.status, reqId, retryable),
    };
  }

  AnalysisException _mapByStatus(int status, String requestId, bool retryable) {
    return switch (status) {
      400 => AnalysisException(
        AnalysisFailureKind.invalidInput,
        requestId: requestId,
        message: 'Dữ liệu câu gửi lên chưa hợp lệ.',
      ),
      401 || 403 => AnalysisException(
        AnalysisFailureKind.unauthenticated,
        requestId: requestId,
        message: 'Phiên đăng nhập không hợp lệ hoặc đã hết hạn.',
      ),
      409 => AnalysisException(
        AnalysisFailureKind.requestConflict,
        requestId: requestId,
        message: 'Trùng mã yêu cầu với câu khác.',
      ),
      429 => AnalysisException(
        AnalysisFailureKind.quotaExceeded,
        requestId: requestId,
        message: 'Bạn đã dùng hết lượt phân tích hôm nay.',
      ),
      502 => AnalysisException(
        AnalysisFailureKind.invalidOutput,
        requestId: requestId,
        message: 'Phản hồi phân tích không hợp lệ.',
      ),
      504 => AnalysisException(
        AnalysisFailureKind.timeout,
        requestId: requestId,
        retryable: true,
        message: 'Hết thời gian xử lý phân tích.',
      ),
      _ => AnalysisException(
        AnalysisFailureKind.unavailable,
        requestId: requestId,
        retryable: retryable || status >= 500,
        message: 'Không thể kết nối dịch vụ phân tích lúc này.',
      ),
    };
  }
}
