SHELL := /bin/bash

POSTGRES_BIN ?= /opt/homebrew/opt/postgresql@16/bin
PATH := $(POSTGRES_BIN):$(PATH)

.DEFAULT_GOAL := help

.PHONY: help setup bootstrap reset server dev console routes db-prepare db-seed db-disconnect db-reset \
		test coverage lint security check docker-up docker-down docker-logs docker-build


help:
	@printf "\nEMS commands\n\n"
	@printf "  %-16s %s\n" "make setup" "Install gems and prepare the database"
	@printf "  %-16s %s\n" "make dev" "Start the local development stack"
	@printf "  %-16s %s\n" "make server" "Start Rails server only"
	@printf "  %-16s %s\n" "make console" "Open Rails console"
	@printf "  %-16s %s\n" "make routes" "Show Rails routes"
	@printf "  %-16s %s\n" "make db-prepare" "Create, migrate, and seed the database"
	@printf "  %-16s %s\n" "make db-seed" "Seed the database"
	@printf "  %-16s %s\n" "make db-disconnect" "Terminate other Postgres sessions on app DBs"
	@printf "  %-16s %s\n" "make db-reset" "Drop, recreate, migrate, and seed the database"
	@printf "  %-16s %s\n" "make test" "Run the RSpec suite"
	@printf "  %-16s %s\n" "make coverage" "Run RSpec with SimpleCov (writes coverage/)"
	@printf "  %-16s %s\n" "make lint" "Run RuboCop"
	@printf "  %-16s %s\n" "make security" "Run Brakeman and bundler-audit"
	@printf "  %-16s %s\n" "make check" "Run zeitwerk, specs, lint, and security checks"
	@printf "  %-16s %s\n" "make docker-up" "Start Docker Compose services"
	@printf "  %-16s %s\n" "make docker-down" "Stop Docker Compose services"
	@printf "  %-16s %s\n" "make docker-logs" "Tail Docker Compose logs"
	@printf "  %-16s %s\n" "make docker-build" "Build Docker Compose images"

setup:
	bin/setup --skip-server

bootstrap: setup

reset:
	bin/setup --reset --skip-server

server:
	bin/rails server

dev:
	bin/dev

console:
	bin/rails console

routes:
	bin/rails routes

db-prepare:
	bin/rails db:prepare
	bin/rails db:seed

db-seed:
	bin/rails db:seed

db-disconnect:
	@psql -d postgres -v ON_ERROR_STOP=1 -c "\
		SELECT pg_terminate_backend(pid) \
		FROM pg_stat_activity \
		WHERE datname IN ( \
			'employee_management_system_development', \
			'employee_management_system_test' \
		) \
		AND pid <> pg_backend_pid();"

db-reset: db-disconnect
	bin/rails db:drop db:create db:migrate db:seed

test:
	bundle exec rspec

coverage:
	COVERAGE=true bundle exec rspec

lint:
	bin/rubocop

security:
	bin/brakeman --no-pager
	bin/bundler-audit

check:
	bin/rails zeitwerk:check
	bundle exec rspec
	bin/rubocop
	bin/brakeman --no-pager
	bin/bundler-audit

docker-up:
	docker compose up --build

docker-down:
	docker compose down

docker-logs:
	docker compose logs -f

docker-build:
	docker compose build
