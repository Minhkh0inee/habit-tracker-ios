---
name: pre-push-code-review
description: Comprehensive pre-push code review for HabitTracker / Momentum iOS app. Analyzes git diff against Swift best practices, memory management, concurrency, security, and project integrity.
---

# Pre-Push Code Review Guide for HabitTracker

Use this skill whenever reviewing code changes before pushing to remote (`git push`).

## Review Workflow

1. **Check Git Status & Diffs**:
   - Run `git status` to see staged, unstaged, and untracked files.
   - Run `git diff HEAD` (or against `origin/main`) to inspect all changes.

2. **iOS & Swift Architecture Checklist**:
   - **Concurrency & MainActor**: Are UI-related state mutations properly `@MainActor` isolated? Are unstructured `Task` blocks properly tracked with a cancellable handle or scoped in `.task {}` view modifiers?
   - **Naming & Consistency**: Check for typos in file names, class names, types, and module names.
   - **Secret Protection**: Ensure secrets (API keys, service roles, tokens) are not committed to source files. Verify environment configs or bundle lookups (`SupabaseConfig`, `GeminiSyncService`).
   - **Xcode Project Integrity**: When files are added or renamed, verify that `project.pbxproj` references or `PBXFileSystemSynchronizedRootGroup` paths remain valid.
   - **Resource & Plist Verification**: Verify URL schemes, capabilities, and bundle identifiers match between the main app and extensions (e.g. `HabitTrackerWidget`).

3. **Issue Reporting & Resolution**:
   - Summarize issues by severity: **Critical** (breaks build/runtime/security), **Warning** (architecture/maintainability), **Suggestion** (style/cleanup).
   - Offer or automatically apply complete drop-in fixes.
