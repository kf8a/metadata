
  You are an expert in Ruby on Rails, PostgreSQL, Hotwire (Turbo and Stimulus), and Tailwind CSS.

  Code Style and Structure
  - Write concise, idiomatic Ruby code with accurate examples.
  - Follow Rails conventions and best practices.
  - Use object-oriented and functional programming patterns as appropriate.
  - Prefer iteration and modularization over code duplication.
  - Use descriptive variable and method names (e.g., user_signed_in?, calculate_total).
  - Structure files according to Rails conventions (MVC, concerns, helpers, etc.).

  Naming Conventions
  - Use snake_case for file names, method names, and variables.
  - Use CamelCase for class and module names.
  - Follow Rails naming conventions for models, controllers, and views.

  Ruby and Rails Usage
  - Use Ruby 3.x features when appropriate (e.g., pattern matching, endless methods).
  - Leverage Rails' built-in helpers and methods.
  - Use ActiveRecord effectively for database operations.

  Syntax and Formatting
  - Follow the Ruby Style Guide (https://rubystyle.guide/)
  - Use Ruby's expressive syntax (e.g., unless, ||=, &.)
  - Prefer single quotes for strings unless interpolation is needed.

  Error Handling and Validation
  - Use exceptions for exceptional cases, not for control flow.
  - Implement proper error logging and user-friendly messages.
  - Use ActiveModel validations in models.
  - Handle errors gracefully in controllers and display appropriate flash messages.

  UI and Styling
  - Use Hotwire (Turbo and Stimulus) for dynamic, SPA-like interactions.
  - Implement responsive design with Tailwind CSS.
  - Use Rails view helpers and partials to keep views DRY.

  Performance Optimization
  - Use database indexing effectively.
  - Implement caching strategies (fragment caching, Russian Doll caching).
  - Use eager loading to avoid N+1 queries.
  - Optimize database queries using includes, joins, or select.

  Key Conventions
  - Follow RESTful routing conventions.
  - Use concerns for shared behavior across models or controllers.
  - Implement service objects for complex business logic.
  - Use background jobs (e.g., Sidekiq) for time-consuming tasks.

  Testing
  - Write comprehensive tests using RSpec or Minitest.
  - Follow TDD/BDD practices.
  - Use factories (FactoryBot) for test data generation.

  Security
  - Implement proper authentication and authorization (e.g., Devise, Pundit).
  - Use strong parameters in controllers.
  - Protect against common web vulnerabilities (XSS, CSRF, SQL injection).

  Follow the official Ruby on Rails guides for best practices in routing, controllers, models, views, and other Rails components.


<!-- BEGIN BEADS INTEGRATION v:1 profile:minimal hash:46cd31e7 -->
## Beads Issue Tracker

This project uses **bd (beads)** for issue tracking. Run `bd prime` to see full workflow context and commands.

### Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --claim  # Claim work
bd close <id>         # Complete work
```

### Rules

- Use `bd` for ALL task tracking — do NOT use TodoWrite, TaskCreate, or markdown TODO lists
- Run `bd prime` for detailed command reference and session close protocol
- Use `bd remember` for persistent knowledge — do NOT use MEMORY.md files

**Architecture in one line:** issues live in a local Dolt DB; sync uses `refs/dolt/data` on your git remote; `.beads/issues.jsonl` is a passive export. See https://github.com/gastownhall/beads/blob/main/docs/core-concepts/sync-concepts.md for details and anti-patterns.

## Agent Context Profiles

The managed Beads block is task-tracking guidance, not permission to override repository, user, or orchestrator instructions.

- **Conservative (default)**: Use `bd` for task tracking. Do not run git commits, git pushes, or Dolt remote sync unless explicitly asked. At handoff, report changed files, validation, and suggested next commands.
- **Minimal**: Keep tool instruction files as pointers to `bd prime`; use the same conservative git policy unless active instructions say otherwise.
- **Team-maintainer**: Only when the repository explicitly opts in, agents may close beads, run quality gates, commit, and push as part of session close. A current "do not commit" or "do not push" instruction still wins.

## Session Completion

This protocol applies when ending a Beads implementation workflow. It is subordinate to explicit user, repository, and orchestrator instructions.

1. **File issues for remaining work** - Create beads for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **Handle git/sync by active profile**:
   ```bash
   # Conservative/minimal/default: report status and proposed commands; wait for approval.
   git status

   # Team-maintainer opt-in only, unless current instructions forbid it:
   git pull --rebase
   bd dolt push
   git push
   git status
   ```
5. **Hand off** - Summarize changes, validation, issue status, and any blocked sync/commit/push step

**Critical rules:**
- Explicit user or orchestrator instructions override this Beads block.
- Do not commit or push without clear authority from the active profile or the current user request.
- If a required sync or push is blocked, stop and report the exact command and error.
<!-- END BEADS INTEGRATION -->

<!-- BEGIN BEADS CODEX SETUP: generated by bd setup codex -->
## Beads Issue Tracker

Use Beads (`bd`) for durable task tracking in repositories that include it. Use the `beads` skill at `.agents/skills/beads/SKILL.md` (project install) or `~/.agents/skills/beads/SKILL.md` (global install) for Beads workflow guidance, then use the `bd` CLI for issue operations.

### Quick Reference

```bash
bd ready                # Find available work
bd show <id>            # View issue details
bd update <id> --claim  # Claim work
bd close <id>           # Complete work
bd prime                # Refresh Beads context
```

### Rules

- Use `bd` for all task tracking; do not create markdown TODO lists.
- Run `bd prime` when Beads context is missing or stale. Codex 0.129.0+ can load Beads context automatically through native hooks; use `/hooks` to inspect or toggle them.
- Keep persistent project memory in Beads via `bd remember`; do not create ad hoc memory files.

**Architecture in one line:** issues live in a local Dolt DB; sync uses `refs/dolt/data` on your git remote; `.beads/issues.jsonl` is a passive export. See https://github.com/gastownhall/beads/blob/main/docs/core-concepts/sync-concepts.md for details and anti-patterns.
<!-- END BEADS CODEX SETUP -->
