"""
Shared MCP instance module.

This module provides a shared FastMCP instance that can be imported by both
the server module and tool modules without creating cyclic imports.
"""

from mcp.server.auth.settings import AuthSettings
from mcp.server.fastmcp import FastMCP  # pylint: disable=import-error

from intervals_mcp_server.api.client import setup_api_client
from intervals_mcp_server.auth import ApiKeyVerifier
from intervals_mcp_server.config import get_config

# Enable bearer token auth when MCP_API_KEY is set (HTTP/SSE modes only).
_mcp_kwargs: dict = {"name": "intervals-icu", "lifespan": setup_api_client}
_config = get_config()
if _config.mcp_api_key:
    _mcp_kwargs["token_verifier"] = ApiKeyVerifier(_config.mcp_api_key)
    _mcp_kwargs["auth"] = AuthSettings()

mcp: FastMCP = FastMCP(**_mcp_kwargs)  # pylint: disable=invalid-name
