from django.contrib import admin
from .models import RouteRequest


@admin.register(RouteRequest)
class RouteRequestAdmin(admin.ModelAdmin):
    list_display = ["user", "danger_score", "hazard_count", "map_provider", "created_at"]
    list_filter = ["map_provider"]
