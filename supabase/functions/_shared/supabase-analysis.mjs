import { boundedJson } from './gemini-free.mjs';

export function createSupabaseAnalysisPorts({ url, anonKey, serviceKey, approvedIds = [], transport = fetch }) {
  const base = new URL(url);
  if (!['https:', 'http:'].includes(base.protocol) || base.username || base.password || base.search || base.hash) throw new Error('Invalid server URL');
  const origin = base.origin;
  const uuid = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
  if (!Array.isArray(approvedIds) || approvedIds.some((id) => typeof id !== 'string' || !uuid.test(id))) throw new Error('Invalid approved candidate IDs');
  const approved = new Set(approvedIds.map((id) => id.toLowerCase()));
  async function call(path, headers, body) {
    const response = await transport(origin + path, {
      method: body === undefined ? 'GET' : 'POST',
      headers: { ...headers, 'content-type': 'application/json' },
      body: body === undefined ? undefined : JSON.stringify(body), signal: AbortSignal.timeout(10000),
    });
    if (!response.ok) { try { await response.body?.cancel(); } catch {} throw new Error('Backend unavailable'); }
    return boundedJson(response, 262144);
  }
  async function rpc(name, body) {
    return call(`/rest/v1/rpc/${name}`, { apikey: serviceKey, authorization: `Bearer ${serviceKey}` }, body);
  }
  return {
    async authenticate(request) {
      const authorization = request.headers.get('authorization');
      if (!authorization || !/^Bearer [^\s]+$/i.test(authorization)) return null;
      const response = await transport(origin + '/auth/v1/user', {
        headers: { apikey: anonKey, authorization }, signal: AbortSignal.timeout(10000),
      });
      if ([401, 403].includes(response.status)) { await response.body?.cancel(); return null; }
      if (!response.ok) { await response.body?.cancel(); throw new Error('Auth unavailable'); }
      const user = await boundedJson(response);
      if (typeof user.id !== 'string' || !uuid.test(user.id)) return null;
      return { id: user.id, authorization };
    },
    async catalog(owner) {
      if (!approved.size) return [];
      const value = await call('/rest/v1/grammar_points?select=id,pattern,meaning_vi&order=id&limit=120', { apikey: anonKey, authorization: owner.authorization });
      if (!Array.isArray(value)) throw new Error('Invalid catalog');
      return value.filter((item) => typeof item.id === 'string' && approved.has(item.id.toLowerCase())
        && typeof item.pattern === 'string' && typeof item.meaning_vi === 'string');
    },
    ledger: {
      begin: (owner, request, fingerprint) => rpc('bunly_analysis_begin', { p_user: owner, p_request: request, p_fingerprint: fingerprint }),
      finish: (owner, request, generation, result, error) => rpc('bunly_analysis_finish', { p_user: owner, p_request: request, p_generation: generation, p_result: result, p_error: error }),
    },
  };
}
