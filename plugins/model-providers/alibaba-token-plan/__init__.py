"""Alibaba Cloud Token Plan provider profile."""
from providers import register_provider
from providers.base import ProviderProfile

alibaba_token_plan = ProviderProfile(
    name="alibaba-token-plan",
    aliases=("alibaba-token", "qwen-token-plan", "dashscope-token-plan"),
    display_name="Alibaba Cloud (Token Plan)",
    description="Alibaba Cloud Token Plan (subscription token tier)",
    env_vars=("ALIBABA_TOKEN_PLAN_API_KEY", "DASHSCOPE_API_KEY"),
    base_url="https://token-plan.ap-southeast-1.maas.aliyuncs.com/compatible-mode/v1",
    auth_type="api_key",
)

register_provider(alibaba_token_plan)
