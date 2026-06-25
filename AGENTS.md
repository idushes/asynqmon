# AGENTS.md

Instructions for AI agents working in this repository.

## Scope

These instructions apply to the entire repository.

Do not make major changes to the product, architecture, API, UX, or business logic without explicit user confirmation. Keep changes narrowly scoped to the requested task.

When the user asks for code changes, do not forget to commit and push the completed work unless they explicitly ask otherwise.

## Project Overview

Asynqmon is a Go library and CLI binary for monitoring and administering Asynq task queues. The Go package serves HTTP API endpoints and embeds the production React UI from `ui/build` using Go `embed`.

The frontend lives under `ui/` and is a Create React App TypeScript application using React 16, Material UI v4, Redux Toolkit, and Yarn.

## Repository Layout

- `cmd/asynqmon/`: CLI entrypoint, flag parsing, Redis connection setup, server startup.
- `*.go` at the repository root: `asynqmon` library package, HTTP handlers, API helpers, static asset serving.
- `ui/src/`: React/TypeScript source.
- `ui/build/`: generated production UI assets embedded by the Go package.
- `Makefile`: root build targets for API-only, assets, full binary, and Docker.

## Common Commands

Run commands from the repository root unless noted otherwise.

- Go tests: `go test ./...`
- Build API-only binary without rebuilding UI assets: `make api`
- Build release binary with UI assets: `make build`
- Build UI assets only: `make assets`
- Run UI dev server: `cd ui && yarn start`
- Run UI tests once: `cd ui && yarn test --watchAll=false`
- Build UI directly: `cd ui && yarn build`

`make build` and `make assets` may install UI dependencies with Yarn if `ui/node_modules` is missing.

## Go Guidelines

- Preserve Go 1.16 compatibility unless the user explicitly approves a version bump.
- Run `gofmt` on changed Go files.
- Keep HTTP API behavior and response shapes backward-compatible unless the task explicitly requires a breaking change.
- Be careful with queue/task mutation endpoints. Respect read-only mode and existing handler authorization flow.
- Prefer existing handler, formatter, and conversion patterns over adding new abstractions.
- Update tests when behavior changes, especially for flag parsing, handlers, Redis option construction, and response formatting.

## Frontend Guidelines

- Keep the existing Create React App, React 16, Material UI v4, Redux, and TypeScript patterns.
- Use Yarn and keep `ui/yarn.lock` in sync when dependencies change.
- Avoid broad UX or navigation changes without explicit user confirmation.
- Keep UI API calls aligned with the Go handlers under `/api`.
- If UI source changes affect the production bundle, rebuild `ui/build` before completing the task.

## Static Assets

The Go package embeds `ui/build` via `//go:embed ui/build/*`. When changing frontend source that affects shipped UI behavior, update both the source files and the generated build assets unless the user specifically asks not to.

Do not manually edit minified files in `ui/build/static` unless there is no source alternative.

## Dependency Changes

- For Go dependency changes, update `go.mod` and `go.sum` intentionally and run `go mod tidy` when appropriate.
- For UI dependency changes, use Yarn from `ui/` and commit the resulting `yarn.lock` changes.
- Do not introduce new major frameworks, state managers, routers, build tools, or service dependencies without explicit user confirmation.

## Verification

Choose verification proportional to the change:

- Documentation-only changes: no runtime tests required, but check formatting and links when applicable.
- Go code changes: run `go test ./...`.
- CLI/server changes: run `go test ./...` and `make api`.
- UI source changes: run `cd ui && yarn test --watchAll=false`; run `cd ui && yarn build` or `make assets` when shipped assets must change.
- Full release-impacting changes: run `make build` when practical.

If a command cannot be run because of missing services, network restrictions, time, or environment issues, report that clearly in the final response.

## Git Workflow

- Check `git status --short --branch` before editing and before committing.
- Do not revert or overwrite unrelated user changes.
- Keep commits focused and use a clear commit message.
- Push the current branch after a successful commit unless the user explicitly asks not to.
