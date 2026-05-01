# Sentry CI Pipeline Health

Cato reports failed GitHub Actions jobs to Sentry as CI-only error events. These
events are separate from app runtime crashes by using:

- `environment: ci`
- `logger: github_actions`
- `server_name: github-actions`
- `telemetry.source: ci`
- `platform: ci`
- `pipeline: github_actions`

Useful Sentry filters:

```text
environment:ci telemetry.source:ci
environment:ci pipeline:github_actions
environment:ci workflow:"CI"
```

Each event includes the workflow, job, repository, ref, short SHA, run attempt,
GitHub run URL, and commit URL. Events are fingerprinted by workflow and job so
repeated failures in the same job group together.

The workflow uses `SENTRY_DSN` only. `SENTRY_AUTH_TOKEN` is still only required
for release/debug-file uploads.
