import { createAnalysisHandler } from '../_shared/analysis-service.mjs';
import { createGeminiFreeProvider } from '../_shared/gemini-free.mjs';
import { createSupabaseAnalysisPorts } from '../_shared/supabase-analysis.mjs';

// Supabase supplies its local server credentials. Provider key stays server-side.
const ports = createSupabaseAnalysisPorts({
  url: Deno.env.get('SUPABASE_URL') ?? 'http://127.0.0.1:54321',
  anonKey: Deno.env.get('SUPABASE_ANON_KEY') ?? '',
  serviceKey: Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
  approvedIds: JSON.parse(Deno.env.get('BUNLY_APPROVED_GRAMMAR_IDS') ?? '[]'),
});
const provider = createGeminiFreeProvider({
  apiKey: Deno.env.get('GEMINI_API_KEY') ?? '',
  freeTierConfirmed: Deno.env.get('GEMINI_FREE_TIER_CONFIRMED') === 'true',
});
Deno.serve(createAnalysisHandler({ ...ports, provider }));
