import { AnalysisContractError, analysisFingerprint, readAnalysisInput, validateAnalysisOutput } from './analysis-contract.mjs';

export const PROMPT_VERSION = 'bunly-analysis-v1';
const errors = {
  invalid_input: [400, false], unauthenticated: [401, false], request_conflict: [409, false],
  quota_exceeded: [429, false], invalid_output: [502, false], unavailable: [503, true], timeout: [504, true],
};

function reply(body, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { 'content-type': 'application/json; charset=utf-8', 'cache-control': 'no-store' } });
}

function fail(id, code) {
  const [status, retryable] = errors[code] ?? errors.unavailable;
  return reply({ request_id: id, error: { code: errors[code] ? code : 'unavailable', retryable } }, status);
}

// Dependencies are server-only ports. Auth is verified before body/catalog/quota/provider work.
export function createAnalysisHandler({ authenticate, catalog, ledger, provider }) {
  return async (request) => {
    let id = null;
    if (request.method !== 'POST') return fail(id, 'invalid_input');
    let owner;
    try { owner = await authenticate(request); } catch { return fail(id, 'unavailable'); }
    if (!owner) return fail(id, 'unauthenticated');
    let input;
    try { input = await readAnalysisInput(request); id = input.request_id; }
    catch { return fail(id, 'invalid_input'); }
    let candidates;
    let claim;
    try {
      if (!provider.ready()) return fail(id, 'unavailable');
      candidates = await catalog(owner);
      if (!candidates.length) return fail(id, 'unavailable');
      const fingerprint = await analysisFingerprint(input, `${PROMPT_VERSION}:${provider.model}`);
      claim = await ledger.begin(owner.id, id, fingerprint);
    } catch { return fail(id, 'unavailable'); }
    if (claim.status === 'processing') return reply({ request_id: id, status: 'processing', retry_after_ms: 1000 }, 202);
    if (claim.status === 'succeeded') {
      // Use today's server quota; never reuse a cached quota snapshot.
      try {
        const replay = validateAnalysisOutput(claim.result, input, new Set(candidates.map((item) => item.id)));
        return reply({ request_id: id, ...replay, remaining_quota: claim.remaining_quota });
      } catch { return fail(id, 'invalid_output'); }
    }
    if (claim.status === 'failed') return fail(id, claim.error_code);
    if (claim.status !== 'claimed') return fail(id, claim.status);

    let output;
    let providerError = null;
    try {
      const candidateSet = new Set(candidates.map((item) => item.id));
      const hintedIds = Array.isArray(input.candidate_ids)
        ? new Set(input.candidate_ids.filter((id) => candidateSet.has(id)))
        : new Set();
      const providerCandidates = hintedIds.size >= 1
        ? [
            ...candidates.filter((item) => hintedIds.has(item.id)),
            ...candidates.filter((item) => !hintedIds.has(item.id)).slice(0, Math.max(0, 18 - hintedIds.size)),
          ]
        : candidates;
      output = validateAnalysisOutput(await provider.analyze(input, providerCandidates), input, candidateSet);
    } catch (error) {
      providerError = error instanceof AnalysisContractError && ['invalid_output', 'timeout', 'unavailable'].includes(error.code)
        ? error.code : 'unavailable';
    }
    let committed;
    try {
      // Never convert a DB-finalize failure into a refund: provider may already have succeeded.
      committed = await ledger.finish(owner.id, id, claim.generation, providerError ? null : output, providerError);
    } catch { return fail(id, 'unavailable'); }
    if (committed.status === 'succeeded') return reply({ request_id: id, ...committed.result, remaining_quota: committed.remaining_quota });
    if (committed.status === 'failed') return fail(id, committed.error_code);
    return fail(id, 'unavailable');
  };
}
