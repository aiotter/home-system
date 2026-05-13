from __future__ import annotations

from homeassistant.components.repairs import ConfirmRepairFlow, RepairsFlow
from homeassistant.core import HomeAssistant
from homeassistant.data_entry_flow import FlowResult
from homeassistant.helpers import issue_registry as ir

from . import DOMAIN


class RequiredIntegrationRepairFlow(RepairsFlow):
    def __init__(self, domain: str, issue_id: str) -> None:
        self.domain = domain
        self.issue_id = issue_id

    async def async_step_init(self, user_input: None = None) -> FlowResult:
        if self.hass.config_entries.async_entries(self.domain):
            ir.async_delete_issue(self.hass, DOMAIN, self.issue_id)
            return self.async_create_entry(data={})

        return self.async_abort(reason="integration_not_configured")


async def async_create_fix_flow(
    hass: HomeAssistant,
    issue_id: str,
    data: dict[str, str | int | float | None] | None,
) -> RepairsFlow:
    if data is not None and isinstance(domain := data.get("domain"), str):
        return RequiredIntegrationRepairFlow(domain, issue_id)

    return ConfirmRepairFlow()
