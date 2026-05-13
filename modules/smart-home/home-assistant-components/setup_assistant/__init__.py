from __future__ import annotations

from dataclasses import dataclass
from typing import Any

import voluptuous as vol

from homeassistant.config_entries import SIGNAL_CONFIG_ENTRY_CHANGED
from homeassistant.core import HomeAssistant, callback
from homeassistant.helpers.dispatcher import async_dispatcher_connect
import homeassistant.helpers.config_validation as cv
from homeassistant.helpers import issue_registry as ir
from homeassistant.loader import IntegrationNotFound, async_get_integration

DOMAIN = "setup_assistant"

CONF_REQUIRED_INTEGRATIONS = "required_integrations"


@dataclass(frozen=True)
class RequiredIntegration:
    domain: str
    name: str

    @property
    def issue_id(self) -> str:
        return f"missing_{self.domain}"

    @property
    def setup_url(self) -> str:
        return f"/config/integrations/dashboard/add?domain={self.domain}"


CONFIG_SCHEMA = vol.Schema(
    {
        DOMAIN: vol.Schema(
            {
                vol.Optional(CONF_REQUIRED_INTEGRATIONS, default=[]): vol.All(
                    cv.ensure_list,
                    [cv.string],
                ),
            }
        ),
    },
    extra=vol.ALLOW_EXTRA,
)


async def async_setup(hass: HomeAssistant, config: dict[str, Any]) -> bool:
    configured = config.get(DOMAIN, {})
    required_integrations = []
    for domain in configured[CONF_REQUIRED_INTEGRATIONS]:
        required_integrations.append(
            RequiredIntegration(
                domain=domain,
                name=await _async_get_integration_name(hass, domain),
            )
        )

    hass.data[DOMAIN] = tuple(required_integrations)

    @callback
    def refresh_issues(*_: Any) -> None:
        _refresh_issues(hass, hass.data[DOMAIN])

    refresh_issues()
    async_dispatcher_connect(hass, SIGNAL_CONFIG_ENTRY_CHANGED, refresh_issues)

    return True


async def _async_get_integration_name(hass: HomeAssistant, domain: str) -> str:
    try:
        integration = await async_get_integration(hass, domain)
    except IntegrationNotFound:
        return domain

    return integration.name


@callback
def _refresh_issues(
    hass: HomeAssistant,
    required_integrations: tuple[RequiredIntegration, ...],
) -> None:
    configured_domains = {entry.domain for entry in hass.config_entries.async_entries()}
    configured_domains.add(DOMAIN)

    for integration in required_integrations:
        if integration.domain in configured_domains:
            ir.async_delete_issue(hass, DOMAIN, integration.issue_id)
            continue

        ir.async_create_issue(
            hass,
            DOMAIN,
            integration.issue_id,
            data={"domain": integration.domain},
            is_fixable=True,
            is_persistent=True,
            issue_domain=integration.domain,
            learn_more_url=integration.setup_url,
            severity=ir.IssueSeverity.WARNING,
            translation_key="missing_required_integration",
            translation_placeholders={
                "domain": integration.domain,
                "name": integration.name,
            },
        )
