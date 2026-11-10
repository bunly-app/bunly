// Pure contract boundary. No auth, database access, provider calls or quota decisions.
export const MAX_TEXT_CODEPOINTS = 1000;
export const MAX_REQUEST_BYTES = 8192;

const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const encoder = new TextEncoder();

export class AnalysisContractError extends Error {
  constructor(code) {
    super(code);
    this.name = 'AnalysisContractError';
    this.code = code;
  }
}

function reject(code) {
  throw new AnalysisContractError(code);
}

function record(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value)
    && (Object.getPrototypeOf(value) === Object.prototype || Object.getPrototypeOf(value) === null);
}

function keysAre(value, required, optional = []) {
  return record(value) && required.every((key) => Object.hasOwn(value, key))
    && Object.keys(value).every((key) => required.includes(key) || optional.includes(key));
}

function validUnicode(text) {
  // Reject unpaired surrogates instead of silently replacing them during UTF-8 encoding.
  for (let i = 0; i < text.length; i++) {
    const unit = text.charCodeAt(i);
    if (unit >= 0xd800 && unit <= 0xdbff) {
      const next = text.charCodeAt(++i);
      if (!(next >= 0xdc00 && next <= 0xdfff)) return false;
    } else if (unit >= 0xdc00 && unit <= 0xdfff) return false;
  }
  return true;
}

export function validateAnalysisInput(payload) {
  if (!keysAre(payload, ['request_id', 'text', 'locale'], ['candidate_ids'])
    || typeof payload.request_id !== 'string' || !uuid.test(payload.request_id)
    || payload.locale !== 'vi' || typeof payload.text !== 'string'
    || !validUnicode(payload.text)) reject('invalid_input');

  let candidateIds;
  if (Object.hasOwn(payload, 'candidate_ids') && payload.candidate_ids !== undefined && payload.candidate_ids !== null) {
    if (!Array.isArray(payload.candidate_ids) || payload.candidate_ids.length > 50
      || payload.candidate_ids.some((id) => typeof id !== 'string' || !uuid.test(id))) {
      reject('invalid_input');
    }
    candidateIds = Object.freeze([...new Set(payload.candidate_ids.map((id) => id.toLowerCase()))]);
  }

  const text = payload.text.replaceAll('\r\n', '\n').trim();
  const size = [...text].length;
  if (size < 1 || size > MAX_TEXT_CODEPOINTS || encoder.encode(text).byteLength > MAX_REQUEST_BYTES) {
    reject('invalid_input');
  }
  return Object.freeze(
    candidateIds
      ? { request_id: payload.request_id.toLowerCase(), text, locale: 'vi', candidate_ids: candidateIds }
      : { request_id: payload.request_id.toLowerCase(), text, locale: 'vi' },
  );
}

// Apply only after authentication in a real endpoint. Bounds memory even without Content-Length.
export async function readAnalysisInput(request) {
  const mediaType = request.headers.get('content-type')?.split(';', 1)[0].trim().toLowerCase();
  if (mediaType !== 'application/json' || !request.body) reject('invalid_input');
  const reader = request.body.getReader();
  const decoder = new TextDecoder('utf-8', { fatal: true });
  let bytes = 0;
  let json = '';
  try {
    while (true) {
      const chunk = await reader.read();
      if (chunk.done) break;
      bytes += chunk.value.byteLength;
      if (bytes > MAX_REQUEST_BYTES) reject('invalid_input');
      json += decoder.decode(chunk.value, { stream: true });
    }
    json += decoder.decode();
    return validateAnalysisInput(JSON.parse(json));
  } catch {
    try { await reader.cancel(); } catch { /* Preserve the sanitized contract error. */ }
    reject('invalid_input');
  } finally {
    reader.releaseLock();
  }
}

export async function analysisFingerprint(input, promptVersion) {
  const normalized = validateAnalysisInput(input);
  if (typeof promptVersion !== 'string' || promptVersion.length === 0) throw new TypeError('promptVersion required');
  const bytes = encoder.encode(JSON.stringify([normalized.text, normalized.locale, promptVersion]));
  const digest = await crypto.subtle.digest('SHA-256', bytes);
  return [...new Uint8Array(digest)].map((byte) => byte.toString(16).padStart(2, '0')).join('');
}

function boundary(text, offset) {
  if (offset <= 0 || offset >= text.length) return true;
  const before = text.charCodeAt(offset - 1);
  const after = text.charCodeAt(offset);
  return !(before >= 0xd800 && before <= 0xdbff && after >= 0xdc00 && after <= 0xdfff);
}

export function validateAnalysisOutput(output, input, candidateIds) {
  const { text } = validateAnalysisInput(input);
  // candidateIds must come from server-curated content, never the caller or the model.
  if (!(candidateIds instanceof Set) || [...candidateIds].some((id) => typeof id !== 'string' || !uuid.test(id))) {
    throw new TypeError('A server candidate UUID set is required');
  }
  const candidates = new Set([...candidateIds].map((id) => id.toLowerCase()));
  if (!keysAre(output, ['matches']) || !Array.isArray(output.matches)) reject('invalid_output');
  const matches = output.matches.map((match) => {
    if (!keysAre(match, ['grammar_id'], ['span']) || typeof match.grammar_id !== 'string'
      || !candidates.has(match.grammar_id.toLowerCase())) reject('invalid_output');
    const clean = { grammar_id: match.grammar_id.toLowerCase() };
    if (Object.hasOwn(match, 'span')) {
      const span = match.span;
      if (!keysAre(span, ['start_utf16', 'end_utf16', 'text'])
        || !Number.isSafeInteger(span.start_utf16) || !Number.isSafeInteger(span.end_utf16)
        || span.start_utf16 < 0 || span.end_utf16 > text.length || span.start_utf16 >= span.end_utf16
        || !boundary(text, span.start_utf16) || !boundary(text, span.end_utf16)
        || typeof span.text !== 'string' || text.slice(span.start_utf16, span.end_utf16) !== span.text) {
        reject('invalid_output');
      }
      clean.span = Object.freeze({ start_utf16: span.start_utf16, end_utf16: span.end_utf16, text: span.text });
    }
    return Object.freeze(clean);
  });
  return Object.freeze({ matches: Object.freeze(matches) });
}
