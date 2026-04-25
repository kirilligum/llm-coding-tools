# Ask Format Prompt

## Output contract

Create exactly one Markdown ask-me file in `./ask_me` for the clarifying
questions you asked in the preceding conversation.

Return only this wrapper and document body. No other text.

```text
=== document: ask_me/<descriptive-name>.md ===
<Markdown document content>
```

## Terminology rule

Define any conversation-specific term, shorthand, or implied meaning that may be
unclear from context, and include the foundational function/variable names that
anchor it in the current codebase.

## Clarifying-question instructions

You asked me clarifying questions. For each individual question, I need you to:

1. Provide context.
2. Give options for thoughtful answers.
3. Provide your recommendation.

For each question, include:

- **Contextualize**: Explain why you are asking the question. Define any
  conversation-specific term using the Terminology rule. Provide examples,
  reference relevant pieces of code, and establish the context.
- **Present options**: Always provide 2 to 5 materially distinct options. Do
  not include technically possible but architecturally inferior options just to
  increase the number.
- **Rank by structural spectrum**: Order options from long-term, structural
  choices to short-term, pragmatic choices. Do not order by recommendation
  strength; the recommendation is a separate judgment.
- **Follow guidelines**: Ensure every option follows the architectural guidance and
  decision precedence listed below.
- **Recommend**: Recommend one option and justify it.

## Decision precedence

When architectural principles conflict, resolve them in this order:

1. Correctness and verified local context.
2. Security and data integrity.
3. Fit with existing architecture.
4. Simplicity and YAGNI (You Aren't Gonna Need It).
5. Observability and fail-fast mechanisms.
6. Performance (only where explicitly relevant and measured).
7. Extensibility (only when rigorously justified).

## Option design guidance

- **Evidence hierarchy**: Base decisions on this order of evidence:
  1. Verified local source, 2) Existing architecture/tests, 3) Project
     schemas/config, 4) Official docs, 5) Known engineering principles. Label any
     assumptions.
- **One way principle (YAGNI & KISS)**: Propose one direct option per path.
  Avoid redundant fallbacks and unlikely-edge-case safety nets.
- **DRY**: Avoid duplication in logic, style, and code.
- **SSoT**: Keep each piece of state or core logic centralized.
- **Functional core, imperative shell**: Keep side effects at boundaries; keep
  core logic pure.
- **Dependency inversion (external boundaries only)**: Apply abstractions only at
  stable external boundaries (I/O, database, network, vendor, queue).
- **Design by contract and observability**: Validate invariants immediately.
  Crash early and loudly on violations. Use structured logging at external
  boundaries. Avoid unstructured print statements.
- **Explicit state machines**: Use explicit FSMs/ADTs for mutually exclusive
  lifecycle states. Do not model one lifecycle with multiple booleans.
- **Mechanical sympathy vs conciseness**: Prefer clear code. Optimize only when
  measured, clearly asymptotic, or explicitly performance-critical.
- **Transparent semantics and minimal surface area**: Keep naming and APIs
  minimal and explicit. Expose the smallest necessary surface.
- **Verified API and contextual integrity**: Fit existing architecture. Do not
  invent APIs, fields, or config keys. Rely only on verified local source,
  official docs, or schemas.

## Option rubrics

Use compact rubrics to make option trade-offs easy to scan. Rubrics are
observational signals, not a scoring system. Do not choose an option by
counting `a` ranks. The recommendation still follows Decision precedence.

Rubrics rank each option along an axis. The examples below are calibration
anchors, not required buckets. Do not force an option into a named bucket if the
fit is imperfect. Rank by where the option sits relative to the other presented
options on that axis.

### Rubric ranking rules

Use this rubric line for every option:

`Conf | Invest | Commit | Fit | Lib | Obs | Surface | Perf`

`Conf` is absolute: provide both a 0-100% score and a 10-level bucket.

All other rubrics are relative ranks within the current question. For each
rubric, use consecutive lowercase letters starting at `a`, where `a` is highest
on that rubric's axis among the presented options. Prefer unique letters; use
ties only when options are genuinely indistinguishable on that dimension.

The option line must contain only compact values, not prose explanations.

### Conf - confidence

Absolute evidence confidence. Format: `Conf:<score>%/<bucket>`.

- `C10` = 90-100%: Proven by local source, tests, schemas/config, and no
  material unknowns.
- `C9` = 80-89%: Strongly verified by local source with minor untested edge
  cases.
- `C8` = 70-79%: Well supported by local architecture, tests, or schemas, but
  not fully verified.
- `C7` = 60-69%: Supported by local context and known engineering principles;
  some integration details remain open.
- `C6` = 50-59%: Plausible, but meaningful local context or edge cases are
  unverified.
- `C5` = 40-49%: Assumption-dependent; explicit assumptions are not locally
  verified.
- `C4` = 30-39%: Weak local evidence; architecture or API behavior is
  uncertain.
- `C3` = 20-29%: Speculative; significant integration uncertainty remains.
- `C2` = 10-19%: Barely supported; mostly unknown local behavior.
- `C1` = 0-9%: Insufficient context to judge safely.

### Invest - engineering investment

Relative axis from highest durable investment to lowest pragmatic investment.

- `a` side: Durable architecture, domain model, explicit lifecycle model, FSM,
  ADT, or structural refactor.
- Middle: Architecture-preserving implementation, centralized service/function,
  targeted invariant, or validation.
- Later-letter side: Compatibility shim, migration bridge, temporary patch, or
  narrow call-site fix.

### Commit - structural commitment

Relative axis from hardest-to-reverse or broadest commitment to
easiest-to-reverse or smallest blast radius. This is not a desirability score.

- `a` side: Breaking, irreversible, migration-heavy, schema/API-affecting, or
  broad-blast-radius change.
- Middle: Reversible internal rewiring, staged rollout, feature flag, or
  config-gated change.
- Later-letter side: Local, reversible, low-risk, minimal-blast-radius change.

### Fit - architecture fit

Relative axis from strongest existing-architecture fit to weakest acceptable
fit.

- `a` side: Uses existing architecture exactly or follows current
  framework/module conventions directly.
- Middle: Small extension of existing architecture, justified boundary
  abstraction, or narrow adapter at an existing seam.
- Later-letter side: Local composition or workaround that remains acceptable
  only because it is narrow and justified.

### Lib - library-readiness

Relative axis for how close the solution is to being extractable as an external
library.

- `a` side: Independently packageable, clean public API, isolated side effects,
  no app-specific dependencies.
- Middle: Self-contained module, stable boundary, ports/adapters, or narrow
  dependencies.
- Later-letter side: Existing service implementation, shared helper, call-site
  coordination, or inline app-specific logic.

### Obs - observability

Relative axis from strongest fail-fast/auditable behavior to weakest acceptable
visibility.

- `a` side: Invariants enforced by contract, type, schema, explicit state
  transition, or immediate structured failure.
- Middle: Structured logging, validation, explicit boundary errors, metrics,
  traces, or counters.
- Later-letter side: Basic logs, limited invariant enforcement, or behavior
  requiring manual inspection.

### Surface - surface-area discipline

Relative axis from smallest/clearest surface to broadest acceptable surface.

- `a` side: No new API surface, local private function, or smallest explicit
  callable surface.
- Middle: One narrow method, field, parameter, type, schema, ADT, adapter, or
  wrapper at an existing seam.
- Later-letter side: Expanded public/module API or broader maintenance surface.

### Perf - performance posture

Relative axis from strongest performance posture to weakest acceptable
performance posture. Use as observation unless performance is explicitly
relevant, measured, asymptotic, hot-path, high-volume, high-concurrency, or
latency-sensitive.

Use `Perf:na` when performance is not meaningfully relevant or cannot be ranked
from available local context.

- `a` side: Designed for verified hot-path constraints, measured limits, or
  improved algorithmic complexity.
- Middle: Uses batching, streaming, indexing, caching, bounded concurrency, or
  clear time/space bounds.
- Later-letter side: Adequate for known small/non-hot-path inputs or least
  performance-aware acceptable implementation.

## Auditable decision record format

(Repeat this sequence for every question.)

### 1) Question [Number]

Define the specific decision needed.

### 2) Context & clarification

- Explain why this question is being asked.
- Describe project impact.
- Apply the Terminology rule for any ambiguous term.
- Add clarifying code snippets when relevant.

### 3) Options

Provide 2 to 5 materially distinct options ordered by structural spectrum, from
Long-Term/Structural to Short-Term/Pragmatic. Do not order by recommendation
strength.

- `Option [Letter]`: [Option title]
  - **Rubrics**: `Conf:<score>%/<C1-C10> | Invest:<rank> | Commit:<rank> |
Fit:<rank> | Lib:<rank> | Obs:<rank> | Surface:<rank> | Perf:<rank|na>`
  - **Approach**: Description of the approach.
  - **Architecture**: How this fits the existing codebase, module boundaries, and
    framework conventions.
  - **SSoT**: Where the definitive source of state or logic lives, and why this
    option does not duplicate it.
  - **System limits**: API rate limits, concurrency limits, and time/space
    complexity. If unknown, state exactly:
    `"Unknown - not available in local context."` Do not guess.
  - **Trade-offs**: Brief summary of logic, pros, and cons.

### 4) Recommendation

State which option you recommend and why, using the precedence hierarchy when
relevant.
