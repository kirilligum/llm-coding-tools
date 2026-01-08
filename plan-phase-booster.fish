#!/usr/bin/env fish

# plan-phase-booster.fish
# Usage:
#   ./plan-phase-booster.fish plans/some-plan.md

# 1) Require exactly one argument: the plan file
if test (count $argv) -ne 1
    echo "Usage: plan-phase-booster.fish <plan-file>" >&2
    exit 1
end

set PLAN_FILE $argv[1]

if not test -f $PLAN_FILE
    echo "File not found: $PLAN_FILE" >&2
    exit 1
end

# 2) Extract phase IDs from lines like "P01" at the start (indented or not)
#    This matches your "Detailed Phase Specifications" section:
#      P01
#        Scope/Objectives: ...
set phases (grep -E '^[[:space:]]*P[0-9]{2}\b' $PLAN_FILE \
    | sed -E 's/^[[:space:]]*(P[0-9]{2}).*/\1/' \
    | sort \
    | uniq)

if test (count $phases) -eq 0
    echo "No phases found in $PLAN_FILE using lines starting with 'PXX' (e.g., 'P01')." >&2
    exit 1
end

echo "Using plan file: $PLAN_FILE"
echo "Detected phases: $phases"
echo

# 3) Loop over phases and refine each one via Codex
for phase in $phases
    echo "=== Detailing phase $phase in $PLAN_FILE ==="

    # Hash before edits
    set BEFORE (md5sum $PLAN_FILE | awk '{print $1}')

    # Build the prompt as a single, multi-line string
    set -l PROMPT "
You are operating inside a repository that contains a standards-aligned plan at \"$PLAN_FILE\".

Target phase
  Phase ID: $phase.

Design and reasoning preferences
  - Prefer the simplest design that can work reliably over feature-rich or clever solutions.
  - Minimize complexity and coupling where possible.
  - Avoid speculative guessing: do NOT invent file names, function names, APIs, or commands that are not implied by the existing plan or code.
  - If some information is missing or undecidable from the current repo/plan, say so explicitly and describe what must be decided by a human or a later phase, instead of fabricating details.

Goal
  Deepen and refine Phase $phase so that it is executable by a junior engineer in one sitting, and fix any inconsistencies in \"$PLAN_FILE\" that you discover while doing so, without increasing unnecessary complexity.

Scope of edits
  - You may READ any files for context, but MODIFY ONLY \"$PLAN_FILE\".
  - Focus your changes primarily on Phase $phase.
  - If, while enhancing Phase $phase, you find logical errors, broken traceability, contradictions, or clearly better, simpler patterns elsewhere in \"$PLAN_FILE\", you MUST correct them in this file as well.
  - Preserve identifiers and structure (REQ-###, TEST-###, Phase IDs like P01, P02, etc.). Do NOT renumber or delete IDs. If you must deprecate something, mark it clearly as such in text.

Locate and interpret the target phase
  - Find the Phase $phase block in \"$PLAN_FILE\" (e.g., under \"Detailed Phase Specifications\" or equivalent).
  - Treat that block and its related references (REQ-###, TEST-###, entries in RTM, etc.) as the primary focus of this run.

Required work for Phase $phase

1) Implementation steps
  - Create or refine a numbered, step-by-step implementation plan for Phase $phase ONLY.
  - Steps must reference concrete artifacts where they are already named in the plan or repo:
    - File names, modules, functions, variables, interfaces, data shapes.
  - When a concrete name is not available from the existing context, do NOT guess it; instead:
    - Describe the responsibility and constraints of the artifact in clear text,
    - Note that the implementer must choose names consistent with the existing codebase.
  - Make explicit links to the relevant REQ-### and TEST-### IDs.
  - Call out which C4 layers this phase touches (e.g., UI, service, workflow/orchestration, DB, external systems).
  - Name any patterns used (e.g., pub/sub, CQRS, event sourcing, Temporal-style workflow, circuit breaker, retry with backoff, idempotent handlers), but prefer the simplest viable pattern.

2) Per-Phase Test Plan
  - Define test items, environments (local, CI, staging), and concrete commands or scripts where they are already known.
  - When exact commands or tool invocations are not derivable from the current context, explain the required checks in precise terms and note that the project must define the corresponding test harness.
  - Include, as appropriate for this phase:
    - Functional tests.
    - Non-functional tests (performance, reliability, observability).
    - Contract and data checks (schemas, invariants, data quality).
  - Provide explicit pass/fail criteria that can be checked automatically when possible.
  - Tie tests back to TEST-### IDs and ensure mapping to REQ-### is coherent and minimal.

3) Exit Gate Rules (Green / Yellow / Red)
  - Green: clearly defined, minimal conditions under which Phase $phase is complete and safe to close.
  - Yellow: conditions where the phase may proceed with documented risks or TODOs, but without speculative optimizations.
  - Red: conditions that require rework or rollback.
  - Make these rules concrete and testable (metrics, test outcomes, telemetry signals), favoring simple checks over elaborate gating.

4) Phase Metrics with deep rationale
  For Phase $phase, ensure all of these metrics are present and each has:
    - A value (number or category).
    - One or more sentences of rationale referencing the implementation, architecture, and risks, explicitly favoring simplicity and reliability.

  Metrics:
    - Confidence % (likelihood of completion without major issues).
    - Long-term robustness % (sustainability of the code, ease of future change).
    - Internal interactions count (module-to-module coupling).
    - External interactions count (API/system dependencies).
    - Complexity % (cognitive load to reason about this phase).
    - Feature creep % (likelihood that scope will expand within this phase).
    - YAGNI % (how well the phase avoids building unused generality).
    - MoSCoW category (Must/Should/Could/Won’t).
    - Local vs Non-local changes (describe scope of impact for this phase).
    - Architectural changes count (how many architecture-level decisions are impacted).

  - If a metric is high or low, justify why (e.g., due to cross-service coupling, stateful workflows, external dependencies, or conversely, small scope and simple boundaries).
  - Where there is a tradeoff between simplicity and feature richness, prefer simplicity and explain the decision.

5) Consistency / correction pass over \"$PLAN_FILE\"
  - While focusing on Phase $phase, scan \"$PLAN_FILE\" for:
    - Broken REQ-### ↔ TEST-### ↔ Phase mappings.
    - Conflicting descriptions of the same requirement or phase.
    - RTM entries that no longer align with your updated understanding.
    - Overly complex patterns or phases that contradict the stated preference for simplicity and reliability.
  - If you find inconsistencies or clearly better, simpler alternatives:
    - Update the relevant sections (requirements, test descriptions, RTM, other phase summaries) in \"$PLAN_FILE\" to restore consistency and reduce unnecessary complexity.

Completion conditions for this run
  - If Phase $phase already has:
    - A clear, multi-step implementation plan suitable for a junior engineer,
    - A detailed per-phase test plan,
    - Deep rationales for each metric listed above,
    - And the surrounding plan is logically consistent and not needlessly complex,
    then make only minimal cleanup edits (if any) and keep the structure stable.

Output behavior
  - Apply edits directly to \"$PLAN_FILE\".
  - Do NOT create, delete, or rename any files.
  - Do NOT wrap the whole document in a new \"=== document:\" wrapper; this is an in-place refinement pass, not a fresh document.
  - Keep all other files unchanged.

Now, perform this operation once, focusing on Phase $phase as described.
"

    # Send prompt to Codex; full output prints to your terminal
    printf '%s\n' "$PROMPT" | codex exec -

    if test $status -ne 0
        echo "codex exec failed for phase $phase" >&2
        exit $status
    end

    # Hash after edits
    set AFTER (md5sum $PLAN_FILE | awk '{print $1}')

    if test "$BEFORE" = "$AFTER"
        echo "No changes detected for phase $phase."
    else
        echo "Updated $PLAN_FILE for phase $phase."
    end

    echo
end

echo "All phases processed."
