terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "~> 6.0"
    }
  }
}

# Configure the GitHub Provider
provider "github" {
  owner = "liatrio-enterprise"
}

locals {
  bypass_actors = [
    {
      actor_id   = 1
      actor_type = "OrganizationAdmin"
    },
    {
      actor_id   = 166418
      actor_type = "Integration"
    }
    # Add more maps here for additional actors
  ]
}

locals {
  exclude_repos = yamldecode(file("exclude_repos.yaml"))
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
    repository_property {
      include = ["~environment:prod"]
      exclude = []
    }
    # repository_name {
    #   include = ["~ALL"]
    #   exclude = local.exclude_repos.repos
    # }
  }

  dynamic "bypass_actors" {
    for_each = local.bypass_actors
    content {
      actor_id    = bypass_actors.value.actor_id
      actor_type  = bypass_actors.value.actor_type
      bypass_mode = "always"
    }
  }

  rules {
    // Do not touch
    pull_request {
      require_last_push_approval        = true
      required_approving_review_count   = 1
      required_review_thread_resolution = true
    }
    required_status_checks {
      required_check {
        context = "CodeQL"
      }
    }
    // Define your extra rules here
  }
}

resource "github_organization_ruleset" "liatrio-enterprise-rulesets-for-iac" {
  name        = "liatrio-enterprise-rulesets-for-iac"
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

  rules {
    pull_request {
      require_last_push_approval = true
      required_approving_review_count = 1
      required_review_thread_resolution = true
    }
    required_workflows {
      required_workflow {
        repository_id = 793815922
        path = ".github/workflows/checkov.yml"
      }
    }
  }
}
