# List all the tasks
list:
  @just --list --unsorted

# Initialize all projects
init:
  @just all init

# Format all configurations
fmt:
  @just all fmt

# Validate all configurations
validate:
  @just all validate

alias f := fmt
alias v := validate

# Run all tests in CI
ci:
  @just all ci

# Run a task on all projects
all *FLAGS:
  #!/usr/bin/env bash
  set -e

  for project in access cluster/deployment vault/configuration vault/deployment vault/image; do
    echo "Entering ${project}..."
    just -f ${project}/Justfile {{FLAGS}};
  done

# Run a task in the specificed subproject
sub project *FLAGS:
  @just -f {{project}}/Justfile {{FLAGS}}
