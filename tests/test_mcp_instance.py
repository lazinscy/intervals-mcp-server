"""
Tests for the shared MCP instance exported by intervals_mcp_server.mcp_instance.
"""

import asyncio
import os
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1] / "src"))
os.environ.setdefault("API_KEY", "test")
os.environ.setdefault("ATHLETE_ID", "i1")

from intervals_mcp_server.api import client as api_client  # pylint: disable=wrong-import-position
from intervals_mcp_server.mcp_instance import (  # pylint: disable=wrong-import-position
    init,
    mcp,
    shutdown,
)


class MockAsyncClient:
    """Simple async client double that tracks closure."""

    def __init__(self):
        self.is_closed = False

    async def aclose(self):
        """Mark the mock client as closed."""
        self.is_closed = True


def test_mcp_instance_exports_hosted_hooks():
    """
    Test the shared MCP module exports the hosted lifecycle hooks.
    """
    assert mcp is not None
    assert callable(init)
    assert callable(shutdown)


def test_shutdown_closes_shared_http_client():
    """
    Test the hosted shutdown hook closes the shared API client.
    """
    mock_client = MockAsyncClient()
    api_client.httpx_client = mock_client

    asyncio.run(shutdown())

    assert mock_client.is_closed is True
    api_client.httpx_client = None
