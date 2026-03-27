"""Simple API key authentication for the MCP server."""

from __future__ import annotations

from mcp.server.auth.provider import AccessToken


class ApiKeyVerifier:
    """Verify Bearer tokens against a pre-shared API key.

    Implements the ``TokenVerifier`` protocol expected by FastMCP.
    When the token matches the expected key, returns an ``AccessToken``;
    otherwise returns ``None`` (which makes the SDK return 401).
    """

    def __init__(self, expected_key: str) -> None:
        self._key = expected_key

    async def verify_token(self, token: str) -> AccessToken | None:
        """Return an AccessToken if the token matches, else None."""
        if token == self._key:
            return AccessToken(
                token=token,
                client_id="api-key",
                scopes=[],
            )
        return None
