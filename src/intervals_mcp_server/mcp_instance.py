"""
Shared MCP instance module.

This module provides a shared FastMCP instance that can be imported by both
the server module and tool modules without creating cyclic imports.
"""

from mcp.server.fastmcp import FastMCP  # pylint: disable=import-error

from intervals_mcp_server.api.client import close_api_client, setup_api_client

mcp: FastMCP = FastMCP("intervals-icu", lifespan=setup_api_client)  # pylint: disable=invalid-name


async def init() -> None:
    """
    Initialize hosted-mode resources for a mounted generic-mcp satellite.

    The Intervals satellite creates its HTTP client lazily on first use, so
    hosted mode currently does not require eager startup work.
    """


async def shutdown() -> None:
    """
    Release hosted-mode resources when the parent generic-mcp app stops.
    """
    await close_api_client()
