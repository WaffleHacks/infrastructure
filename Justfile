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

# Lint all configurations
lint:
  @just all lint

alias f := fmt
alias v := validate
alias l := lint

# Run all tests in CI
ci:
  @just all ci

# Run a task on all projects
all *FLAGS:
  #!/usr/bin/env sh
  for project in access vault; do \
    just -f ${project}/Justfile {{FLAGS}}; \
  done

# Run a task in the specificed subproject
sub project *FLAGS:
  @just -f {{project}}/Justfile {{FLAGS}}
