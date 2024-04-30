terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# Configure the GitHub Provider
provider "github" {
  owner = "liatrio-enterprise"
}

resource "github_organization_ruleset" "liatrio-enterprise-rulesets" {
  name        = "liatrio-enterprise-rulesets"
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
    repository_name {
      include = ["~ALL"]
      exclude = []
    }
  }

  # bypass_actors {
  #   actor_id    = 20977329
  #   actor_type  = "OrganizationAdmin"
  #   bypass_mode = "always"
  # }

  # dynamic "bypass_actors" {
  #   for_each = data.github_user.bypass_user
  #   content {
  #     actor_id    = bypass_actors.value.id
  #     actor_type  = "OrganizationAdmin"
  #     bypass_mode = "always"
  #   }
  # }

  rules {
    pull_request {}
    required_status_checks {
      required_check {
        context = "CodeQL"
      }
    }
  }
}
