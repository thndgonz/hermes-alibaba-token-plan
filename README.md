# Hermes Agent — Alibaba Cloud Token Plan provider

A [Hermes Agent](https://github.com/NousResearch/hermes-agent) model-provider
plugin for the **Alibaba Cloud Token Plan** (阿里云百炼 Token 套餐) — the
subscription token tier for Qwen and partner models on Alibaba Cloud Model
Studio.

## Why this plugin exists

Hermes ships several Alibaba/Qwen-adjacent providers, but **none of them
target the Token Plan endpoint**:

| Hermes provider | Endpoint | Token Plan key works? |
|---|---|---|
| `alibaba` | `dashscope-intl.aliyuncs.com/compatible-mode/v1` (pay-per-token DashScope) | ❌ 401 |
| `alibaba-coding-plan` | `coding-intl.dashscope.aliyuncs.com/v1` (coding tier) | ❌ wrong tier |
| `qwen-oauth` | `portal.qwen.ai/v1` (Qwen Code CLI subscription) | ❌ different product |
| **`alibaba-token-plan` (this plugin)** | `token-plan.ap-southeast-1.maas.aliyuncs.com/compatible-mode/v1` | ✅ |

Token Plan keys start with `sk-sp-` and are **only** valid on the Token Plan
endpoint — they 401 on the regular DashScope endpoint, which is the classic
"why doesn't my key work in Hermes" trap. OpenCode and other tools get this
for free because the [models.dev](https://models.dev) catalog includes
`alibaba-token-plan`; Hermes' catalog has not (yet) adopted it.

## Install

Drop the plugin into your Hermes user plugin directory (auto-extended by the
provider catalog — no core edits, survives Hermes updates):

```bash
mkdir -p ~/.hermes/plugins/model-providers
cp -r plugins/model-providers/alibaba-token-plan ~/.hermes/plugins/model-providers/
```

Then set your key in `~/.hermes/.env`:

```bash
echo 'ALIBABA_TOKEN_PLAN_API_KEY=sk-sp-...' >> ~/.hermes/.env
```

> `DASHSCOPE_API_KEY` is accepted as a fallback (mirrors the upstream
> `alibaba-coding-plan` plugin), so an existing Token Plan key stored under
> that name also works.

## Use

```bash
hermes model                      # pick "Alibaba Cloud (Token Plan)" → model
hermes config set model.provider alibaba-token-plan
hermes config set model.default   qwen3.6-flash
hermes chat -q "hi" --provider alibaba-token-plan -m qwen3.6-flash
```

### Models

The Token Plan endpoint serves Qwen, GLM, DeepSeek, Kimi, MiniMax and more —
run `scripts/smoke-test.sh` (or `curl` the `/models` route) for the **live**
list for your key (the catalog advertises more than any single key sees).
The live list at the time of writing:

```
qwen3.7-max        qwen3.7-plus       qwen3.6-flash
qwen3.8-max        glm-5.2            deepseek-v4-pro
deepseek-v4-flash-0731                wan2.7-image / wan2.7-image-pro
qwen-audio-3.0-tts-plus               qwen-audio-3.0-realtime-plus
```

## Gotchas (learned the hard way)

- **Token Plan ≠ DashScope.** `sk-sp-` keys only authenticate on
  `token-plan.*.maas.aliyuncs.com`. Using one with provider `alibaba` in
  Hermes always yields `401 InvalidApiKey`.
- **Token Plan ≠ Qwen Code subscription.** `qwen-oauth` targets
  `portal.qwen.ai` and requires a local Qwen CLI login
  (`~/.qwen/oauth_creds.json`) — a different product with different billing.
- **Region variants.** The China-region endpoint is
  `https://token-plan.cn-beijing.maas.aliyuncs.com/compatible-mode/v1`
  (not covered by this plugin; same `sk-sp-` key family).
- **Anthropic-compatible route.** The same service also exposes
  `https://token-plan.ap-southeast-1.maas.aliyuncs.com/apps/anthropic`
  (Anthropic Messages API, streaming + extended thinking + prompt caching),
  which is how Claude-Code-style tools connect.
- **Context windows are huge.** Qwen3.x models on this endpoint advertise 1M
  context — budget `max_tokens`/output caps accordingly.

## Upstream adoption

The plugin lives at `plugins/model-providers/alibaba-token-plan/` — the same
relative path Hermes uses for its bundled provider plugins, so adopting it
upstream is a literal directory copy into
`NousResearch/hermes-agent/plugins/model-providers/`. The `env_vars` fallback
and `auth_type="api_key"` follow the existing `alibaba-coding-plan` plugin's
conventions.

Related providers also missing from Hermes' catalog (same models.dev family,
same treatment would apply): `alibaba-token-plan-cn`, `xiaomi-token-plan-*`,
`tencent-token-plan`.

## License

MIT — see [LICENSE](LICENSE).
