#!/usr/bin/env just --justfile

# List all the tasks
list:
  @just --list --unsorted

# Initialize terraform providers
init:
  terraform init
  tflint --init

# Apply formatting
fmt:
  terraform fmt -recursive .

# Check if the configuration is valid
validate:
  terraform validate

# Run linters
lint:
  tflint --recursive

alias f := fmt
alias v := validate
alias l := lint

# Plan the changes
plan *FLAGS: validate
  terraform plan {{FLAGS}}

# Launch an interactive console
console:
  terraform console

# Run checks in CI
ci: validate lint
  terraform fmt -recursive -diff -check
