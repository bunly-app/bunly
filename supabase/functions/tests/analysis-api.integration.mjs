// Explicit local-only integration. Invoke through scripts/verify-a05-api-local.py.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { randomUUID, randomBytes } from 'node:crypto';
import { createSupabaseAnalysisPorts } from '../_shared/supabase-analysis.mjs';
import { createAnalysisHandler } from '../_shared/analysis-service.mjs';

const config = JSON.parse(readFileSync(0, 'utf8'));
const base = new URL(config.API_URL);
if (base.protocol !== 'http:' || !['localhost', '127.0.0.1'].includes(base.hostname) || base.port !== '54321') throw new Error('Local backend only');
const uuid = /^[a-f0-9-]{36}$/;
const headers = (key, token = key) => ({ apikey: key, authorization: `Bearer ${token}`, 'content-type': 'application/json' });
function sql(query) {
  return execFileSync('docker', ['exec', '-i', 'supabase_db_bunly', 'psql', '-U', 'postgres', '-d', 'postgres', '-X', '-A', '-t', '-v', 'ON_ERROR_STOP=1'], { input: query, encoding: 'utf8' }).trim();
}

test('real LOCAL Auth/PostgREST ledger integration; provider is an explicit test stub', async () => {
  const created = [];
  const tokens = [];
  const password = `A05-${randomBytes(24).toString('hex')}!a9`;
  try {
    for (let index = 0; index < 2; index++) {
      const email = `a05-${randomUUID()}@example.test`;
      const response = await fetch(base.origin + '/auth/v1/admin/users', { method: 'POST', headers: headers(config.SERVICE_ROLE_KEY), body: JSON.stringify({ email, password, email_confirm: true }) });
      assert.equal(response.status, 200, 'local disposable user setup');
      const user = await response.json();
      assert.match(user.id, uuid);
      created.push(user.id);
      const login = await fetch(base.origin + '/auth/v1/token?grant_type=password', { method: 'POST', headers: headers(config.ANON_KEY), body: JSON.stringify({ email, password }) });
      assert.equal(login.status, 200);
      tokens.push((await login.json()).access_token);
      sql(`insert into bunly_analysis_private.entitlements(user_id,daily_limit) values ('${user.id}',2);`);
    }
    const points = await fetch(base.origin + '/rest/v1/grammar_points?select=id,pattern,meaning_vi&limit=1', { headers: headers(config.ANON_KEY, tokens[0]) });
    assert.equal(points.status, 200);
    const grammar = (await points.json())[0];
    assert.ok(grammar, 'existing local content present; fixture approval is test-only');
    let providerCalls = 0;
    const ports = createSupabaseAnalysisPorts({ url: base.origin, anonKey: config.ANON_KEY, serviceKey: config.SERVICE_ROLE_KEY, approvedIds: [grammar.id] });
    const handle = createAnalysisHandler({ ...ports, provider: { model: 'test-stub-not-live-AI', ready: () => true, analyze: async () => { providerCalls++; return { matches: [{ grammar_id: grammar.id }] }; } } });
    const input = { request_id: randomUUID(), text: '日本へ行ったことがあります。', locale: 'vi' };
    const request = (token, value = input) => new Request('http://localhost/analyze-grammar', { method: 'POST', headers: { 'content-type': 'application/json', ...(token ? { authorization: `Bearer ${token}` } : {}) }, body: JSON.stringify(value) });
    assert.equal((await handle(request(null))).status, 401);
    assert.equal((await handle(request('forged-token'))).status, 401);
    assert.equal((await handle(request(tokens[0], { ...input, user_id: created[1] }))).status, 400);
    const first = await handle(request(tokens[0]));
    assert.equal(first.status, 200);
    assert.equal((await first.json()).remaining_quota, 1);
    const replay = await handle(request(tokens[0]));
    assert.equal(replay.status, 200);
    assert.equal(providerCalls, 1, 'retry does not call provider twice');
    assert.equal((await handle(request(tokens[0], { ...input, text: '別の文です。' }))).status, 409);
    assert.equal((await handle(request(tokens[0], { ...input, request_id: randomUUID() }))).status, 200);
    assert.equal((await handle(request(tokens[0], { ...input, request_id: randomUUID() }))).status, 429);
    assert.equal(providerCalls, 2);
    assert.equal((await handle(request(tokens[1]))).status, 200, 'same request ID for B is independent');
    assert.equal(providerCalls, 3);
    for (const key of [config.ANON_KEY, tokens[0], tokens[1]]) {
      const denied = await fetch(base.origin + '/rest/v1/rpc/bunly_analysis_begin', {
        method: 'POST', headers: headers(config.ANON_KEY, key),
        body: JSON.stringify({ p_user: created[1], p_request: randomUUID(), p_fingerprint: 'a'.repeat(64) }),
      });
      assert.ok([401, 403, 404].includes(denied.status), 'clients cannot call privileged RPC as another owner');
      await denied.body?.cancel();
    }
    assert.equal(sql(`select sum(successes) from bunly_analysis_private.usage where user_id='${created[0]}';`), '2');
    assert.equal(sql(`select sum(successes) from bunly_analysis_private.usage where user_id='${created[1]}';`), '1');
    if (process.env.BUNLY_CHECK_EDGE_RUNTIME === '1') {
      const endpoint = base.origin + '/functions/v1/analyze-grammar';
      const anonymous = await fetch(endpoint, { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify(input) });
      assert.equal(anonymous.status, 401, 'Edge gateway keeps JWT verification enabled');
      await anonymous.body?.cancel();
      const configuredOff = await fetch(endpoint, { method: 'POST', headers: headers(config.ANON_KEY, tokens[0]), body: JSON.stringify(input) });
      assert.equal(configuredOff.status, 503, 'actual Deno handler is unavailable while free-tier key/confirmation is absent');
      assert.deepEqual(await configuredOff.json(), { request_id: input.request_id, error: { code: 'unavailable', retryable: true } });
    }
  } finally {
    // Only invocation-created disposable identities are removed; real user data are untouched.
    for (const id of created) {
      assert.match(id, uuid);
      const removed = await fetch(base.origin + '/auth/v1/admin/users/' + id, { method: 'DELETE', headers: headers(config.SERVICE_ROLE_KEY) });
      assert.equal(removed.status, 200, 'disposable test identity cleanup');
      await removed.body?.cancel();
    }
  }
});
