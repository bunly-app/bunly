import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import {
  AnalysisContractError, analysisFingerprint, readAnalysisInput,
  validateAnalysisInput, validateAnalysisOutput,
} from '../_shared/analysis-contract.mjs';

const id = '30000000-0000-0000-0000-000000000001';
const grammarId = '10000000-0000-0000-0000-000000000001';
const candidates = new Set([grammarId]);
const input = { request_id: id, text: '🌸日本へ行ったことがあります。', locale: 'vi' };
const invalid = (code) => (error) => error instanceof AnalysisContractError && error.code === code && error.message === code;
const body = (value, headers = { 'content-type': 'application/json' }) => new Request('http://localhost/analysis', {
  method: 'POST', headers, body: typeof value === 'string' ? value : JSON.stringify(value),
});

test('normalizes only CRLF and edge whitespace; preserves Japanese/internal spacing', () => {
  assert.deepEqual(validateAnalysisInput({ ...input, text: ' \r\n日本 語\r\nを  学ぶ。 \r\n' }), {
    request_id: id, text: '日本 語\nを  学ぶ。', locale: 'vi',
  });
  assert.equal(Object.isFrozen(validateAnalysisInput(input)), true);
});

test('rejects unauthorized client-controlled fields and wrong request shape', () => {
  for (const value of [null, [], 1, { ...input, user_id: 'other-user' }, { ...input, model: 'override' },
    { ...input, remaining_quota: 100 }, { text: '日本', locale: 'vi' }, { ...input, request_id: 'x' },
    { ...input, locale: 'ja' }, { ...input, text: 123 }]) {
    assert.throws(() => validateAnalysisInput(value), invalid('invalid_input'));
  }
});

test('counts code points rather than UTF-16 units and enforces the 1..1000 limit', () => {
  assert.equal(validateAnalysisInput({ ...input, text: '🌸'.repeat(1000) }).text.length, 2000);
  for (const text of ['', ' \r\n ', '日'.repeat(1001), '🌸'.repeat(1001)]) {
    assert.throws(() => validateAnalysisInput({ ...input, text }), invalid('invalid_input'));
  }
});

test('rejects unpaired high/low surrogates without silent replacement', () => {
  for (const text of ['\ud800', '\udfff', '日\ud800本', '\ud800\ud800\udc00']) {
    assert.throws(() => validateAnalysisInput({ ...input, text }), invalid('invalid_input'));
  }
});

test('reads JSON with media-type parameters and normalizes it', async () => {
  assert.deepEqual(await readAnalysisInput(body(input, { 'content-type': 'Application/JSON; charset=utf-8' })), input);
});

test('rejects malformed JSON, wrong media type, no body and invalid UTF-8', async () => {
  for (const request of [body('{'), body(input, { 'content-type': 'text/plain' }),
    new Request('http://localhost/analysis'),
    new Request('http://localhost/analysis', { method: 'POST', headers: { 'content-type': 'application/json' }, body: new Uint8Array([0xff]) })]) {
    await assert.rejects(readAnalysisInput(request), invalid('invalid_input'));
  }
});

test('limits actual streamed bytes without trusting Content-Length and cancels excess input', async () => {
  let cancelled = false;
  const request = new Request('http://localhost/analysis', {
    method: 'POST', headers: { 'content-type': 'application/json', 'content-length': '1' }, duplex: 'half',
    body: new ReadableStream({
      start(controller) { controller.enqueue(new Uint8Array(8193)); },
      cancel() { cancelled = true; },
    }),
  });
  await assert.rejects(readAnalysisInput(request), invalid('invalid_input'));
  assert.equal(cancelled, true);
});

test('valid multi-byte text can span stream chunks', async () => {
  const bytes = new TextEncoder().encode(JSON.stringify(input));
  let offset = 0;
  const request = new Request('http://localhost/analysis', {
    method: 'POST', headers: { 'content-type': 'application/json' }, duplex: 'half',
    body: new ReadableStream({ pull(controller) {
      if (offset === bytes.length) controller.close();
      else controller.enqueue(bytes.slice(offset, ++offset));
    } }),
  });
  assert.deepEqual(await readAnalysisInput(request), input);
});

test('fingerprint is stable for normalized text/retries and changes with text or prompt version', async () => {
  const first = await analysisFingerprint(input, 'bunly-v1');
  assert.match(first, /^[a-f0-9]{64}$/);
  assert.equal(await analysisFingerprint({ ...input, request_id: '30000000-0000-0000-0000-000000000002', text: ` ${input.text}\r\n` }, 'bunly-v1'), first);
  assert.notEqual(await analysisFingerprint({ ...input, text: '別の文です。' }, 'bunly-v1'), first);
  assert.notEqual(await analysisFingerprint(input, 'bunly-v2'), first);
  await assert.rejects(analysisFingerprint(input, ''), TypeError);
});

test('B0 success/no-match fixture output passes, invalid-output fixture is rejected', async () => {
  const fixture = JSON.parse(await readFile(new URL('../../../documents/development/fixtures/b0/analysis.cases.json', import.meta.url), 'utf8'));
  for (const value of fixture.cases) {
    if (value.expected_http === 200) {
      const output = { matches: value.response.matches };
      assert.deepEqual(validateAnalysisOutput(output, value.request, candidates), output);
    } else if (value.name === 'invalid_output') {
      assert.throws(() => validateAnalysisOutput(value.raw_provider_output, value.request, candidates), invalid('invalid_output'));
    } else if (value.name === 'invalid_input') {
      assert.throws(() => validateAnalysisInput(value.request), invalid('invalid_input'));
    }
  }
});

test('rejects fabricated IDs and extra output fields instead of trusting model quota/confidence', () => {
  for (const output of [null, [], { matches: [], remaining_quota: 99 }, { matches: {} },
    { matches: [{ grammar_id: 'ffffffff-ffff-ffff-ffff-ffffffffffff' }] },
    { matches: [{ grammar_id: grammarId, confidence: 1 }] }, { matches: [{ grammar_id: grammarId, span: null }] }]) {
    assert.throws(() => validateAnalysisOutput(output, input, candidates), invalid('invalid_output'));
  }
});

test('UTF-16 spans must match and may not split an emoji surrogate pair', () => {
  for (const span of [
    { start_utf16: 0, end_utf16: 1, text: input.text.slice(0, 1) },
    { start_utf16: 1, end_utf16: 2, text: input.text.slice(1, 2) },
    { start_utf16: 5, end_utf16: 15, text: 'wrong' },
    { start_utf16: -1, end_utf16: 2, text: '🌸' },
    { start_utf16: 0, end_utf16: 100, text: input.text },
    { start_utf16: 0, end_utf16: 0, text: '' },
    { start_utf16: 0.5, end_utf16: 2, text: '🌸' },
  ]) {
    assert.throws(() => validateAnalysisOutput({ matches: [{ grammar_id: grammarId, span }] }, input, candidates), invalid('invalid_output'));
  }
  const result = validateAnalysisOutput({ matches: [{ grammar_id: grammarId, span: { start_utf16: 0, end_utf16: 2, text: '🌸' } }] }, input, candidates);
  assert.equal(result.matches[0].span.text, '🌸');
  assert.equal(Object.isFrozen(result.matches[0].span), true);
});

test('returns detached immutable matches so provider mutation cannot change validated data', () => {
  const output = { matches: [{ grammar_id: grammarId }] };
  const clean = validateAnalysisOutput(output, input, candidates);
  output.matches[0].grammar_id = 'changed';
  assert.equal(clean.matches[0].grammar_id, grammarId);
  assert.equal(Object.isFrozen(clean.matches), true);
  assert.equal(Object.isFrozen(clean.matches[0]), true);
});

test('empty candidate catalog allows no-match only and invalid server IDs fail closed', () => {
  assert.deepEqual(validateAnalysisOutput({ matches: [] }, input, new Set()), { matches: [] });
  assert.throws(() => validateAnalysisOutput({ matches: [{ grammar_id: grammarId }] }, input, new Set()), invalid('invalid_output'));
  assert.throws(() => validateAnalysisOutput({ matches: [] }, input, new Set(['bad-id'])), TypeError);
});
