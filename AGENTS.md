# Development Guidelines

## Priorities
- Prefer simple, readable, maintainable solutions.
- Follow the established project architecture and conventions.
- Avoid unnecessary dependencies and abstractions.
- Keep changes focused on the requested task.

## Before editing
- Inspect relevant code and tests.
- For significant changes, briefly outline the approach.
- Ask before making major architectural decisions.

## Implementation
- Write clear, idiomatic code for the chosen language.
- Add or update tests for behavior changes.
- Handle errors and edge cases appropriately.
- Do not change unrelated files.

## Verification
- Run relevant tests, linting, and type checks when available.
- Fix failures introduced by the change.
- Report checks that could not be completed.

## Safety
- Never commit secrets or credentials.
- Do not run destructive commands, deploy, or modify external services without approval.
- Do not commit or push unless explicitly requested.

## Completion
- Summarize what changed.
- State what was tested and what remains uncertain.

## Project and toolchain
- This is a learning project for modern C++, GTSAM factor graphs,
  deterministic simulation, and eventually ROS 2 visualization.
- Use Bazel with Bzlmod as the primary application build system.
  Do not replace it with CMake or introduce a second build system
  without discussing the need first.
- Build and test inside the development container at /workspace.
  Do not assume the WSL host has the required dependencies.
- Use C++17 and the versions pinned in repository configuration.

## Container and dependencies
- Preserve the two-image Docker setup: Dockerfile.base contains
  stable dependencies and GTSAM; Dockerfile adds development tooling.
- Avoid rebuilding the base image unless required. Explain the reason
  and expected cost before starting an expensive rebuild.
- Use the existing ubuntu container user. Keep cache paths and
  permissions consistent with that user.
- GTSAM is installed under /usr/local. Bazel must use its bundled
  Eigen headers at /usr/local/include/gtsam/3rdparty/Eigen.

## Development sequence
- Progress incrementally: reusable batch estimator and tests,
  deterministic simulation, ROS 2/RViz, then iSAM2.
- Do not start later milestones without an explicit request.
- Explain significant estimation and architectural choices.
- Use fixed random seeds for simulations and numerical tolerances
  for floating-point tests.

## Build and editor verification
- Build the example with:
  bazel build -c dbg //estimation:pose_graph
- Run relevant Bazel tests when tests exist.
- After changing headers, dependencies, or build targets, refresh
  editor configuration with:
  bazel run //:refresh_compile_commands
- Do not edit generated compile_commands.json manually.
- Rebuild before using executable output as evidence about current source.
