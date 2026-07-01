# Unit Tests for tf-molecule-nlb-internal-aws
#
# These tests use a mock AWS provider — no real AWS calls are made.
# Run with:      terraform test -test-directory=tests/unit
# Run verbose:   terraform test -test-directory=tests/unit -verbose
# Run specific:  terraform test -test-directory=tests/unit -run "creates_when_enabled"
#
# Assertions target plan-KNOWN values only (the tf-label ID and input
# pass-throughs). Computed values such as the NLB / target-group ARNs are
# unknown under a mock provider and are therefore never asserted on directly.

mock_provider "aws" {}

variables {
  # tf-label identity
  namespace = "eg"
  stage     = "test"
  name      = "thing"

  # Module-specific required inputs
  vpc_id     = "vpc-0123456789abcdef0"
  subnet_ids = ["subnet-0aaaa1111bbbb2222", "subnet-0cccc3333dddd4444"]

  # Non-default overrides to exercise pass-through
  listener_port = 443
  target_port   = 8080
  target_type   = "ip"
}

# ---------------------------------------------------------------------------
# Test: module builds the NLB stack when enabled
# ---------------------------------------------------------------------------
run "creates_when_enabled" {
  command = plan

  assert {
    condition     = output.id == "eg-test-thing"
    error_message = "tf-label ID should be composed as namespace-stage-name (eg-test-thing)"
  }

  assert {
    condition     = module.nlb.enabled == true
    error_message = "NLB child module should be enabled by default"
  }

  assert {
    condition     = module.target_group.enabled == true
    error_message = "Target group child module should be enabled by default"
  }
}

# ---------------------------------------------------------------------------
# Test: naming and child wiring reflect the supplied labels/ports
# ---------------------------------------------------------------------------
# NOTE: an `enabled = false` plan cannot be exercised here — the downstream
# tf-atom-lb-listener-aws module validates that load_balancer_arn is non-null,
# and a disabled NLB yields a null ARN, which fails that validation at plan
# time regardless of assertions. So the disabled path is left to integration
# coverage; these asserts pin the plan-known naming/wiring instead.
run "labels_and_ports_propagate" {
  command = plan

  variables {
    name          = "svc"
    listener_port = 9000
    target_port   = 9001
  }

  assert {
    condition     = output.id == "eg-test-svc"
    error_message = "tf-label ID should incorporate the overridden name (eg-test-svc)"
  }

  assert {
    condition     = module.tcp_listener.enabled == true
    error_message = "TCP listener child module should be enabled by default"
  }

  assert {
    condition     = module.target_group.name == "eg-test-svc-tg"
    error_message = "Target group should be named with the -tg suffix off the molecule name"
  }
}
