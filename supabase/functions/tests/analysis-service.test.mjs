import { test } from 'node:test';
import assert from 'node:assert/strict';
import { createAnalysisHandler } from '../_shared/analysis-service.mjs';
import { createGeminiFreeProvider, GEMINI_MODEL } from '../_shared/gemini-free.mjs';
import { AnalysisContractError } from '../_shared/analysis-contract.mjs';

const id = '30000000-0000-0000-0000-000000000001';
const grammar = '10000000-0000-0000-0000-000000000001';
const input = { request_id: id, text: '日本へ行ったことがあります。', locale: 'vi' };
const request = (payload = input) => new Request('http://localhost/analyze-grammar', { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify(payload) });
function harness(overrides = {}) {
  const calls = [];
  const deps = {
    authenticate: async () => { calls.push('auth'); return { id: 'verified-owner' }; },
    catalog: async () => { calls.push('catalog'); return [{ id: grammar }]; },
    ledger: {
      begin: async () => { calls.push('begin'); return { status: 'claimed', generation: 1 }; },
      finish: async (...args) => { calls.push(['finish', ...args]); return { status: args[4] ? 'failed' : 'succeeded', result: args[3], error_code: args[4], remaining_quota: 4 }; },
    },
    provider: { model: GEMINI_MODEL, ready: () => true, analyze: async () => { calls.push('provider'); return { matches: [{ grammar_id: grammar }] }; } },
    ...overrides,
  };
  return { calls, deps, handle: createAnalysisHandler(deps) };
}

test('auth failure rejects before body validation and any provider/quota work', async () => {
  const h = harness({ authenticate: async () => null });
  const response = await h.handle(request({ secret: 'malicious' }));
  assert.equal(response.status, 401);
  assert.deepEqual(h.calls, []);
});
test('authenticated input errors do not reserve quota', async () => {
  const h = harness();
  assert.equal((await h.handle(request({ ...input, user_id: 'forged' }))).status, 400);
  assert.deepEqual(h.calls, ['auth']);
});
test('provider readiness and empty catalog fail closed before reservation', async () => {
  for (const overrides of [{ provider: { ready: () => false } }, { catalog: async () => [] }]) {
    const h = harness(overrides);
    assert.equal((await h.handle(request())).status, 503);
    assert.equal(h.calls.includes('begin'), false);
  }
});
test('valid result is committed with verified owner/generation before returning success', async () => {
  const h = harness();
  const response = await h.handle(request());
  assert.equal(response.status, 200);
  assert.equal((await response.json()).remaining_quota, 4);
  assert.deepEqual(h.calls.slice(0, 4), ['auth', 'catalog', 'begin', 'provider']);
  assert.deepEqual(h.calls[4], ['finish', 'verified-owner', id, 1, { matches: [{ grammar_id: grammar }] }, null]);
});
test('invalid provider ID is sanitized and refunded through the current generation', async () => {
  const h = harness({ provider: { model: GEMINI_MODEL, ready: () => true, analyze: async () => ({ matches: [{ grammar_id: 'forged' }] }) } });
  const response = await h.handle(request());
  assert.equal(response.status, 502);
  assert.deepEqual(h.calls.at(-1), ['finish', 'verified-owner', id, 1, null, 'invalid_output']);
});
test('provider timeout/unavailability use sanitized errors and one finalize', async () => {
  for (const code of ['timeout', 'unavailable']) {
    const h = harness({ provider: { model: GEMINI_MODEL, ready: () => true, analyze: async () => { throw new AnalysisContractError(code); } } });
    const response = await h.handle(request());
    assert.equal(response.status, code === 'timeout' ? 504 : 503);
    assert.deepEqual((await response.json()).error, { code, retryable: true });
    assert.equal(h.calls.filter((call) => Array.isArray(call)).length, 1);
  }
});
test('finalize DB failure never sends a compensating refund or exposes provider details', async () => {
  let finishes = 0;
  const h = harness({ ledger: { begin: async () => ({ status: 'claimed', generation: 4 }), finish: async () => { finishes++; throw new Error('private database/provider details'); } } });
  const response = await h.handle(request());
  assert.equal(response.status, 503);
  assert.equal(finishes, 1);
  assert.doesNotMatch(await response.text(), /private/);
});
test('processing/replay/conflict/quota do not call provider', async () => {
  for (const [claim, status] of [
    [{ status: 'processing' }, 202], [{ status: 'succeeded', result: { matches: [] }, remaining_quota: 1 }, 200],
    [{ status: 'request_conflict' }, 409], [{ status: 'quota_exceeded' }, 429],
  ]) {
    const h = harness({ ledger: { begin: async () => claim } });
    const response = await h.handle(request());
    assert.equal(response.status, status);
    assert.equal(h.calls.includes('provider'), false);
    if (status === 200) assert.equal((await response.json()).remaining_quota, 1);
  }
});
test('replay does not return grammar IDs that are no longer approved', async () => {
  const h = harness({ ledger: { begin: async () => ({ status: 'succeeded', result: { matches: [{ grammar_id: 'revoked' }] }, remaining_quota: 4 }) } });
  assert.equal((await h.handle(request())).status, 502);
});

const candidate = [{ id: grammar, pattern: 'ことがある', meaning_vi: 'đã từng' }];
const success = () => Response.json({ candidates: [{ finishReason: 'STOP', content: { parts: [{ text: JSON.stringify({ matches: [{ grammar_id: grammar }] }) }] } }] });
test('Gemini adapter requires explicit free-tier confirmation, key and exact allowed model', async () => {
  let network = 0;
  for (const options of [{}, { apiKey: 'test' }, { apiKey: 'test', freeTierConfirmed: true, model: 'paid-other' }]) {
    const provider = createGeminiFreeProvider({ ...options, transport: async () => { network++; return success(); } });
    assert.equal(provider.ready(), false);
    await assert.rejects(provider.analyze(input, candidate), (error) => error.code === 'unavailable');
  }
  assert.equal(network, 0);
});
test('Gemini transport has fixed origin, header key, bounded output, no tools or paid fallback', async () => {
  let requests = 0;
  const provider = createGeminiFreeProvider({ apiKey: 'fake-test-key', freeTierConfirmed: true, transport: async (url, init) => {
    requests++;
    assert.equal(url, `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent`);
    assert.doesNotMatch(url, /fake-test-key/);
    assert.equal(init.headers['x-goog-api-key'], 'fake-test-key');
    const payload = JSON.parse(init.body);
    assert.equal(payload.generationConfig.maxOutputTokens, 1024);
    assert.equal(payload.generationConfig.responseMimeType, 'application/json');
    assert.equal(payload.tools, undefined);
    assert.equal(payload.contents[0].role, 'user');
    return success();
  } });
  assert.deepEqual(await provider.analyze(input, candidate), { matches: [{ grammar_id: grammar }] });
  assert.equal(requests, 1);
});
test('Gemini 429 does not auto-retry and provider body never leaks', async () => {
  let requests = 0;
  const provider = createGeminiFreeProvider({ apiKey: 'fake', freeTierConfirmed: true, transport: async () => { requests++; return new Response('secret-provider-body', { status: 429 }); } });
  await assert.rejects(provider.analyze(input, candidate), (error) => error.message === 'unavailable');
  assert.equal(requests, 1);
});
test('Gemini oversized candidate context fails before any network request', async () => {
  let requests = 0;
  const provider = createGeminiFreeProvider({ apiKey: 'fake', freeTierConfirmed: true, transport: async () => { requests++; return success(); } });
  await assert.rejects(provider.analyze(input, [{ ...candidate[0], meaning_vi: 'x'.repeat(65537) }]), (error) => error.code === 'unavailable');
  assert.equal(requests, 0);
});
test('Gemini timeout aborts transport and returns timeout', async () => {
  const provider = createGeminiFreeProvider({ apiKey: 'fake', freeTierConfirmed: true, timeoutMs: 5, transport: (_url, init) => new Promise((_resolve, reject) => {
    init.signal.addEventListener('abort', () => reject(new Error('aborted')), { once: true });
  }) });
  await assert.rejects(provider.analyze(input, candidate), (error) => error.code === 'timeout');
});
test('Gemini rejects truncated/blocked/malformed/oversize output', async () => {
  for (const response of [Response.json({ candidates: [{ finishReason: 'MAX_TOKENS' }] }),
    Response.json({ candidates: [] }), Response.json({ candidates: [{ finishReason: 'STOP', content: { parts: [{ text: 'not json' }] } }] }),
    new Response('x'.repeat(65537))]) {
    const provider = createGeminiFreeProvider({ apiKey: 'fake', freeTierConfirmed: true, transport: async () => response });
    await assert.rejects(provider.analyze(input, candidate), (error) => error.code === 'invalid_output');
  }
});
