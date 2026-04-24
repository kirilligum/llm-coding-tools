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
- **Present options**: Provide 2 to 5 materially distinct options. Use exactly one
  option if the decision is obvious or architecturally mandated. Do not include
  technically possible but architecturally inferior options just to increase the
  number.
- **Rank by spectrum**: Order options from long-term, robust choices to
  short-term, pragmatic ones.
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

Provide 2 to 5 materially distinct options ordered from
Long-Term/Robust to Short-Term/Pragmatic.

- `Option [Letter]`: [Option title]
  - **Approach**: Description of the approach.
  - **Architecture**: How this fits the existing codebase, module boundaries, and
    framework conventions.
  - **SSoT**: Why this does not duplicate state/logic and where the definitive
    source lives.
  - **System limits**: API rate limits, concurrency limits, and time/space
    complexity. If unknown, state exactly:
    `"Unknown - not available in local context."` Do not guess.
  - **Confidence**: High, Medium, or Low. Justify using evidence sources and
    known unknowns.
  - **Trade-offs**: Brief summary of logic, pros, and cons.

### 4) Recommendation

State which option you recommend and why, using the precedence hierarchy when
relevant.
