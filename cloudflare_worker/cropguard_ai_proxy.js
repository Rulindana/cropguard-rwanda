/**
 * CropGuard AI proxy — Cloudflare Worker.
 *
 * Why this exists: browsers cannot call api.cloudflare.com directly
 * (no CORS headers, OPTIONS -> 405). This Worker lives on YOUR domain,
 * adds `Access-Control-Allow-Origin`, and keeps the Workers AI token
 * server-side so it never ships inside public JS.
 *
 * Setup (Cloudflare dashboard > Workers & Pages > Create > Create Worker):
 *   1. Name it cropguard-ai > Deploy > Edit code.
 *   2. Paste this file as the Worker code > Deploy.
 *   3. Settings > Variables and Secrets > add TWO secrets:
 *        CLOUDFLARE_AI_TOKEN    (= your cfut_... token)
 *        CLOUDFLARE_ACCOUNT_ID  (= 32-char Account ID from Workers & Pages Overview)
 *        --dart-define=AI_PROVIDER=cloudflare
 *        --dart-define=CLOUDFLARE_PROXY_URL=https://cropguard-ai.<you>.workers.dev
 *
 * Endpoints:
 *   POST /v1/vision  {prompt, image_base64, max_tokens?, temperature?}
 *   POST /v1/chat    {messages, max_tokens?, temperature?}
 */
const VISION_MODEL = '@cf/meta/llama-3.2-11b-vision-instruct';
const CHAT_MODEL = '@cf/meta/llama-3.3-70b-instruct-fp8-fast';

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'content-type',
  'Access-Control-Max-Age': '86400',
};

export default {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: CORS });
    }
    const url = new URL(request.url);
    if (request.method !== 'POST' || (url.pathname !== '/v1/vision' && url.pathname !== '/v1/chat')) {
      return json({ error: 'Use POST /v1/vision or POST /v1/chat' }, 404);
    }
    if (!env.CLOUDFLARE_AI_TOKEN) {
      return json({ error: 'Worker misconfigured: CLOUDFLARE_AI_TOKEN secret missing' }, 500);
    }
    let body;
    try {
      body = await request.json();
    } catch {
      return json({ error: 'Invalid JSON body' }, 400);
    }

    let model, payload;
    if (url.pathname === '/v1/vision') {
      if (!body.prompt || !body.image_base64) {
        return json({ error: 'vision needs {prompt, image_base64}' }, 400);
      }
      model = VISION_MODEL;
      payload = {
        prompt: body.prompt,
        image: { base64: body.image_base64 },
        max_tokens: body.max_tokens ?? 700,
        temperature: body.temperature ?? 0.2,
      };
    } else {
      if (!Array.isArray(body.messages)) {
        return json({ error: 'chat needs {messages}' }, 400);
      }
      model = CHAT_MODEL;
      payload = {
        messages: body.messages,
        max_tokens: body.max_tokens ?? 500,
        temperature: body.temperature ?? 0.4,
      };
    }

    const upstream = await fetch(
      `https://api.cloudflare.com/client/v4/accounts/${env.CLOUDFLARE_ACCOUNT_ID ?? ''}/ai/run/${model}`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${env.CLOUDFLARE_AI_TOKEN}`,
        },
        body: JSON.stringify(payload),
      }
    );
    const data = await upstream.json().catch(() => ({}));
    // Pass through the Workers AI envelope; the Flutter app already parses it.
    return json(data, upstream.status);
  },
};

function json(obj, status = 200) {
  return new Response(JSON.stringify(obj), {
    status,
    headers: { 'Content-Type': 'application/json', ...CORS },
  });
}
