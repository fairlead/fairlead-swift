import Foundation

/// JSON fixture strings matching the exact API response shapes.
enum Fixtures {

    // MARK: - Organizations

    static let organization = """
    {
      "id": "org_4K7fR9pLm2nQwXvY8cJH3",
      "name": "Acme Corp",
      "api_version": null,
      "tags": ["production", "us-east"],
      "labels": {"team": "growth", "tier": "enterprise"},
      "annotations": {
        "created": {"at": "2026-01-15T10:30:00Z", "by": "user_abc123"},
        "updated": {"at": "2026-02-01T14:00:00Z", "by": "user_abc123"}
      }
    }
    """

    static let organizationList = """
    {
      "data": [
        {
          "id": "org_4K7fR9pLm2nQwXvY8cJH3",
          "name": "Acme Corp",
          "api_version": null,
          "tags": ["production"],
          "labels": {},
          "annotations": {
            "created": {"at": "2026-01-15T10:30:00Z", "by": "user_abc123"},
            "updated": null
          }
        },
        {
          "id": "org_9Xm2kP4wR7nLvQ8fYJ3hT",
          "name": "Beta Inc",
          "api_version": "2026-01-01",
          "tags": [],
          "labels": {"region": "eu-west"},
          "annotations": {
            "created": {"at": "2026-01-20T08:00:00Z", "by": "user_def456"},
            "updated": null
          }
        }
      ],
      "pagination": {
        "offset": 0,
        "limit": 25,
        "total_results": 2
      },
      "meta": {}
    }
    """

    // MARK: - API Keys

    static let apiKey = """
    {
      "id": "key_7mN3pR9xK2wLvY8cJH4fQ",
      "organization_id": "org_4K7fR9pLm2nQwXvY8cJH3",
      "name": "Production Backend",
      "key_prefix": "mk_live_",
      "key_suffix": "xK2w",
      "role": "member",
      "scopes": ["api_keys:read", "organizations:read"],
      "environment": "live",
      "is_active": true,
      "expires_at": null,
      "tags": ["production"],
      "labels": {"team": "backend"},
      "annotations": {
        "created": {"at": "2026-01-15T10:30:00Z", "by": "user_abc123"},
        "updated": null,
        "last_used": {"at": "2026-02-10T09:15:00Z", "by": "key_7mN3pR9xK2wLvY8cJH4fQ"}
      }
    }
    """

    static let apiKeyCreate = """
    {
      "api_key": {
        "id": "key_7mN3pR9xK2wLvY8cJH4fQ",
        "organization_id": "org_4K7fR9pLm2nQwXvY8cJH3",
        "name": "Production Backend",
        "key_prefix": "mk_live_",
        "key_suffix": "xK2w",
        "role": "member",
        "scopes": ["api_keys:read", "organizations:read"],
        "environment": "live",
        "is_active": true,
        "expires_at": null,
        "tags": [],
        "labels": {},
        "annotations": {
          "created": {"at": "2026-01-15T10:30:00Z", "by": "user_abc123"},
          "updated": null,
          "last_used": null
        }
      },
      "raw_key": "mk_live_abc123def456ghi789jkl012mno"
    }
    """

    static let apiKeyList = """
    {
      "data": [
        {
          "id": "key_7mN3pR9xK2wLvY8cJH4fQ",
          "organization_id": "org_4K7fR9pLm2nQwXvY8cJH3",
          "name": "Production Backend",
          "key_prefix": "mk_live_",
          "key_suffix": "xK2w",
          "role": "member",
          "scopes": ["api_keys:read", "organizations:read"],
          "environment": "live",
          "is_active": true,
          "expires_at": null,
          "tags": [],
          "labels": {},
          "annotations": {
            "created": {"at": "2026-01-15T10:30:00Z", "by": "user_abc123"},
            "updated": null,
            "last_used": null
          }
        }
      ],
      "pagination": {
        "offset": 0,
        "limit": 25,
        "total_results": 1
      },
      "meta": {}
    }
    """

    // MARK: - Advertisers

    static let advertiser = """
    {
      "id": "adv_5K8gR0pLm3nQwXvY9cJH4",
      "organization_id": "org_4K7fR9pLm2nQwXvY8cJH3",
      "name": "Acme Ads",
      "external_id": "ext_123",
      "status": "active",
      "metadata": {"category": "retail"},
      "tags": ["premium"],
      "labels": {"tier": "gold"},
      "annotations": {
        "created": {"at": "2026-01-15T10:30:00Z", "by": "user_abc123"},
        "updated": null
      }
    }
    """

    static let advertiserList = """
    {
      "data": [
        {
          "id": "adv_5K8gR0pLm3nQwXvY9cJH4",
          "organization_id": "org_4K7fR9pLm2nQwXvY8cJH3",
          "name": "Acme Ads",
          "external_id": null,
          "status": "active",
          "metadata": {},
          "tags": [],
          "labels": {},
          "annotations": {
            "created": {"at": "2026-01-15T10:30:00Z", "by": "user_abc123"},
            "updated": null
          }
        }
      ],
      "pagination": {
        "offset": 0,
        "limit": 25,
        "total_results": 1
      },
      "meta": {}
    }
    """

    // MARK: - Campaigns

    static let campaign = """
    {
      "id": "cmp_6L9hS1qMn4oRxYwZ0dKI5",
      "advertiser_id": "adv_5K8gR0pLm3nQwXvY9cJH4",
      "organization_id": "org_4K7fR9pLm2nQwXvY8cJH3",
      "name": "Summer Sale",
      "status": "active",
      "budget_total_cents": 100000,
      "budget_daily_cents": 5000,
      "start_date": "2026-06-01",
      "end_date": "2026-08-31",
      "tags": ["seasonal"],
      "labels": {"quarter": "Q3"},
      "annotations": {
        "created": {"at": "2026-01-15T10:30:00Z", "by": "user_abc123"},
        "updated": null
      }
    }
    """

    static let campaignList = """
    {
      "data": [
        {
          "id": "cmp_6L9hS1qMn4oRxYwZ0dKI5",
          "advertiser_id": "adv_5K8gR0pLm3nQwXvY9cJH4",
          "organization_id": "org_4K7fR9pLm2nQwXvY8cJH3",
          "name": "Summer Sale",
          "status": "active",
          "budget_total_cents": 100000,
          "budget_daily_cents": null,
          "start_date": null,
          "end_date": null,
          "tags": [],
          "labels": {},
          "annotations": {
            "created": {"at": "2026-01-15T10:30:00Z", "by": "user_abc123"},
            "updated": null
          }
        }
      ],
      "pagination": {
        "offset": 0,
        "limit": 25,
        "total_results": 1
      },
      "meta": {}
    }
    """

    // MARK: - Line Items

    static let lineItem = """
    {
      "id": "li_7M0iT2rNo5pSyZxA1eLJ6",
      "campaign_id": "cmp_6L9hS1qMn4oRxYwZ0dKI5",
      "organization_id": "org_4K7fR9pLm2nQwXvY8cJH3",
      "bidder_type": "first_price",
      "status": "active",
      "bid_strategy": "cpc",
      "bid_amount_cents": 150,
      "targeting": {"geo": "US"},
      "priority": 10,
      "delivery_goal": null,
      "tags": ["high-priority"],
      "labels": {"team": "growth"},
      "annotations": {
        "created": {"at": "2026-01-15T10:30:00Z", "by": "user_abc123"},
        "updated": null
      }
    }
    """

    static let lineItemList = """
    {
      "data": [
        {
          "id": "li_7M0iT2rNo5pSyZxA1eLJ6",
          "campaign_id": "cmp_6L9hS1qMn4oRxYwZ0dKI5",
          "organization_id": "org_4K7fR9pLm2nQwXvY8cJH3",
          "bidder_type": "first_price",
          "status": "active",
          "bid_strategy": "cpc",
          "bid_amount_cents": 150,
          "targeting": {},
          "priority": 0,
          "delivery_goal": null,
          "tags": [],
          "labels": {},
          "annotations": {
            "created": {"at": "2026-01-15T10:30:00Z", "by": "user_abc123"},
            "updated": null
          }
        }
      ],
      "pagination": {
        "offset": 0,
        "limit": 25,
        "total_results": 1
      },
      "meta": {}
    }
    """

    // MARK: - Ads

    static let ad = """
    {
      "id": "ad_8N1jU3sOp6qTzAyB2fMK7",
      "line_item_id": "li_7M0iT2rNo5pSyZxA1eLJ6",
      "organization_id": "org_4K7fR9pLm2nQwXvY8cJH3",
      "ad_type": "listing_ref",
      "external_item_id": "sku_12345",
      "quality_score": 0.95,
      "metadata": {"source": "catalog"},
      "status": "active",
      "tags": ["featured"],
      "labels": {"category": "electronics"},
      "annotations": {
        "created": {"at": "2026-01-15T10:30:00Z", "by": "user_abc123"},
        "updated": null
      }
    }
    """

    static let adList = """
    {
      "data": [
        {
          "id": "ad_8N1jU3sOp6qTzAyB2fMK7",
          "line_item_id": "li_7M0iT2rNo5pSyZxA1eLJ6",
          "organization_id": "org_4K7fR9pLm2nQwXvY8cJH3",
          "ad_type": "listing_ref",
          "external_item_id": null,
          "quality_score": 0.85,
          "metadata": {},
          "status": "active",
          "tags": [],
          "labels": {},
          "annotations": {
            "created": {"at": "2026-01-15T10:30:00Z", "by": "user_abc123"},
            "updated": null
          }
        }
      ],
      "pagination": {
        "offset": 0,
        "limit": 25,
        "total_results": 1
      },
      "meta": {}
    }
    """

    // MARK: - Placements

    static let placement = """
    {
      "id": "plc_9O2kV4tPq7rUaBzC3gNL8",
      "organization_id": "org_4K7fR9pLm2nQwXvY8cJH3",
      "name": "Homepage Banner",
      "slug": "homepage-banner",
      "ad_format": "sponsored_listing",
      "max_ads": 5,
      "rules": {"min_bid": 100},
      "bidder_config": {"strategy": "first_price"},
      "tags": ["homepage"],
      "labels": {"page": "home"},
      "annotations": {
        "created": {"at": "2026-01-15T10:30:00Z", "by": "user_abc123"},
        "updated": null
      }
    }
    """

    static let placementList = """
    {
      "data": [
        {
          "id": "plc_9O2kV4tPq7rUaBzC3gNL8",
          "organization_id": "org_4K7fR9pLm2nQwXvY8cJH3",
          "name": "Homepage Banner",
          "slug": "homepage-banner",
          "ad_format": "sponsored_listing",
          "max_ads": 5,
          "rules": {},
          "bidder_config": {},
          "tags": [],
          "labels": {},
          "annotations": {
            "created": {"at": "2026-01-15T10:30:00Z", "by": "user_abc123"},
            "updated": null
          }
        }
      ],
      "pagination": {
        "offset": 0,
        "limit": 25,
        "total_results": 1
      },
      "meta": {}
    }
    """

    // MARK: - Errors

    static let errorNotFound = """
    {
      "error": {
        "type": "not_found_error",
        "message": "Organization not found.",
        "code": 404,
        "details": null,
        "request_id": "req_abc123"
      }
    }
    """

    static let errorValidation = """
    {
      "error": {
        "type": "invalid_request_error",
        "message": "Validation failed.",
        "code": 400,
        "details": [
          {
            "field": "name",
            "code": "required",
            "message": "Name is required."
          },
          {
            "field": "tags",
            "code": "invalid_type",
            "message": "Expected an array."
          }
        ],
        "request_id": "req_def456"
      }
    }
    """

    static let errorAuth = """
    {
      "error": {
        "type": "authentication_error",
        "message": "Invalid API key.",
        "code": 401,
        "details": null,
        "request_id": "req_ghi789"
      }
    }
    """
}
