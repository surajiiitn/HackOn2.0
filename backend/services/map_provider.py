"""
Pluggable map provider abstraction.

Supports swapping between map services (Google Maps, Mapbox, OpenRouteService)
without changing application code.
"""
import logging
from abc import ABC, abstractmethod
from django.conf import settings
from django.contrib.gis.geos import Point

logger = logging.getLogger(__name__)


class BaseMapProvider(ABC):
    """Interface for map routing providers."""

    @abstractmethod
    def get_route(self, start: Point, end: Point) -> dict:
        """
        Get a route between two points.

        Returns:
            dict with polyline, distance_meters, duration_seconds, waypoints
        """
        pass

    @abstractmethod
    def geocode(self, address: str) -> Point | None:
        """Convert address to coordinates."""
        pass

    @abstractmethod
    def reverse_geocode(self, point: Point) -> str | None:
        """Convert coordinates to address."""
        pass


class StubMapProvider(BaseMapProvider):
    """
    Development stub that returns direct-line routes.
    No external API calls needed.
    """

    def get_route(self, start: Point, end: Point) -> dict:
        distance = start.distance(end) * 111000  # rough meters
        return {
            "polyline": [
                {"lat": start.y, "lng": start.x},
                {"lat": (start.y + end.y) / 2, "lng": (start.x + end.x) / 2},
                {"lat": end.y, "lng": end.x},
            ],
            "distance_meters": round(distance),
            "duration_seconds": round(distance / 1.4),  # walking speed
            "provider": "stub",
        }

    def geocode(self, address: str) -> Point | None:
        logger.info(f"[Stub] Geocode: {address}")
        return None

    def reverse_geocode(self, point: Point) -> str | None:
        return f"{point.y:.4f}, {point.x:.4f}"


class GoogleMapsProvider(BaseMapProvider):
    """Google Maps Directions API. TODO: Implement with googlemaps package."""

    def __init__(self):
        self.api_key = settings.MAP_API_KEY

    def get_route(self, start: Point, end: Point) -> dict:
        # TODO: import googlemaps; client = googlemaps.Client(key=self.api_key)
        # result = client.directions(origin, destination, mode="walking")
        logger.info("[Google Maps stub] Route requested")
        return StubMapProvider().get_route(start, end)

    def geocode(self, address: str) -> Point | None:
        logger.info(f"[Google Maps stub] Geocode: {address}")
        return None

    def reverse_geocode(self, point: Point) -> str | None:
        return None


class MapboxProvider(BaseMapProvider):
    """Mapbox Directions API. TODO: Implement with requests."""

    def __init__(self):
        self.api_key = settings.MAP_API_KEY

    def get_route(self, start: Point, end: Point) -> dict:
        # TODO: requests.get(f"https://api.mapbox.com/directions/v5/mapbox/walking/...")
        logger.info("[Mapbox stub] Route requested")
        return StubMapProvider().get_route(start, end)

    def geocode(self, address: str) -> Point | None:
        return None

    def reverse_geocode(self, point: Point) -> str | None:
        return None


def get_map_provider() -> BaseMapProvider:
    """Factory function — returns the configured map provider."""
    provider_name = getattr(settings, "MAP_PROVIDER", "stub")

    providers = {
        "stub": StubMapProvider,
        "google": GoogleMapsProvider,
        "mapbox": MapboxProvider,
    }

    provider_class = providers.get(provider_name, StubMapProvider)
    return provider_class()
