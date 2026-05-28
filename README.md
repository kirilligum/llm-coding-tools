# LLM Coding Tools

This document is not a course or a full-on guide. It's for people who already
vibe-code and aren't happy with current tools, and who want more cutting-edge
approaches. All prompts are based on recent peer-reviewed academic papers and
have been tested for a few months. There was no A/B testing on something like
SWE-bench. I used these prompts to create an orchestrator that's competitive
with Temporal, but works as a Firebase library, and for a synthetic-data
generation pipeline that uses a knowledge graph. SWE-bench is fairly saturated
with models achieving high scores; many use cases for the prompts in this repo
still can't be done by models or typical wrappers alone.

## Planning

### Discuss the Problem

Have a conversation with an LLM until the problem, constraints, trade-offs, and
candidate implementation direction are clear.

### Step-Back Prompts

```
Step back, think about similar architectural patterns, system designs,
industry standards. Give an extensive technically detailed response with
relevant examples.
```

Optional follow-up when alternatives need more emphasis:

```
Think creatively, do you see any other alternatives? If you were building the
project from scratch for a multi-billion dollar SaaS, how would you do things
differently?
```

After this, create the plan before running the
[Overengineering Check](#overengineering-check).

### Create the Plan

```
Based on the chosen direction above, write a detailed implementation plan. Break
it into ordered phases and concrete steps. Do not implement yet.
```

### Overengineering Check

Run this after [Create the Plan](#create-the-plan). If you use
[Ask Me](#ask-me), run it again after the answers are incorporated. Run it once
more before [Executing the Plan](#executing-the-plan).

This is a critical prompt because LLMs tend to drift, expand, and duplicate
work very quickly, sometimes exponentially across branches and follow-ups. That
can push the critical code out of the effective context window. The full context
window is not equally useful, so the codebase should stay much smaller than the
nominal context limit. Constraining scope, duplication, and fallback paths is
the key control when increasing the size of a codebase.

```
Check the plan.
We don't want to overengineer things; we want one way of
doing things, meaning no legacy and no fallbacks. Prefer direct approaches
over adapters and safety for situations that are unlikely to happen.
We also don't want any logic, style, or code duplication.
Prefer general code over minor performance gains because we want the codebase
to be smaller. We want the code to be easy to maintain, robust, and scalable
without hacks, patches, and tech debt.
```

### Quick Checks

This prompt can be used after any planning step, and in general almost any time
you want the LLM to pause and re-evaluate its current direction.

```
Wait, check your reasoning, do you see any flaws or better alternatives?
```

### Ask Me

Ask Me is a guardrail, not a mandatory step. I skip it when I am confident the
LLM will not hallucinate the plan and will make the right choices.

Ask Me can happen before [Format the Plan](#format-the-plan) when the overall
plan structure is the main uncertainty, or after formatting when implementation
details are the higher-risk questions. Formatting takes a closer look at
dependencies, interfaces, tests, and other implementation details.

There are two ways I use Ask Me, depending on how much structure I need. After
Ask Me, rerun the [Overengineering Check](#overengineering-check) before the
next major step.

#### Quick Follow-Up

Use [`./ask_me.txt`](ask_me.txt) when you want the LLM to quickly identify the
main gaps and ask you targeted questions. It gives multiple options and a
recommendation, so by default you only need to review and approve it; otherwise,
have a discussion.

When I use this prompt, I care more about review speed than maximum accuracy.
For maximum accuracy, ask the LLM to list issues with explanations, then dive
into them in separate sessions. After this prompt, instead of writing
explanatory text, you can just say `I agree with your recommendations` or reply
with `1A, 2A, 3B, 4A, more details about 5`.

#### In-Depth Ask-Me

For more complicated plans, I start with this exact follow-up:

```
Identify areas where you have low confidence, are unsure, or need my input,
and ask me for my guidance or opinion.
```

This phrase is intentionally simple so the LLM does not get distracted by
formatting and just focuses on surfacing uncertainty.

Then I follow up with [`./ask_format.md`](ask_format.md) so the model returns a
document wrapper for `./ask_me/...md`, properly thinks through each question,
formats the answer choices, and gives recommendations.

You can open that generated file and chat about each item to get more
clarification until you fully understand the trade-offs and can answer. After
you give the answers, such as `1B, 2A, 3C`, ask the LLM to update the plan if
the questions came after the plan was already written.

#### Analyze My Answers

After I answer, I sometimes follow up with:

```
Analyze my answers above against the previous task and codebase context.

1. **Gap Check**: If these answers reveal NEW complexities, missing edge
cases, or further ambiguities, you must ask follow-up questions now.
2. **Success Condition**: If everything is now 100% clear and no further
information is needed, state exactly: "Context fully synthesized. All gaps
closed."
```

### Format the Plan

Use the [`phase-plan-follow-upper.txt`](phase-plan-follow-upper.txt) formatter
prompt to create an `.md` plan file in the `plans` folder.

<details>
<summary>Copy <code>phase-plan-follow-upper.txt</code></summary>

<!-- BEGIN phase-plan-follow-upper.txt copy -->
```text
Create exactly one Markdown plan file in ./plans for the work described by the preceding conversation.

Role:
You are a principal research-engineering PM with deep knowledge of ISO/IEC/IEEE 29148 requirements/SRS, ISO/IEC/IEEE 29119-3 test documentation, and ISO/IEC/IEEE 12207 software implementation/life-cycle processes.

Output policy:
Return only this wrapper and document body. No other text.

=== document: plans/<descriptive-name>.md ===
<Markdown document content>

Core requirements:
- The plan must be standalone. Future readers have the repository, but not the conversation.
- Do not write “as discussed,” “per our chat,” or similar references.
- Include all decisions, context, constraints, trade-offs, assumptions, and scope directly in the plan.
- Ground all technical claims, file paths, commands, tests, APIs, and architecture references in the current repository.
- Do not invent commands. Use existing package.json scripts, Makefile targets, scripts/, CI config, or add a phase step to create missing commands before using them.
- Use concise, implementation-ready bullets.
- Use plain Markdown headings only where required; avoid decorative formatting.

Machine-readable rules:
- Phase headers must be exactly: `### Phase Pxx: <Outcome>`.
- Phase IDs must be `P00`, `P01`, `P02`, …, `P99`.
- If any table includes phases, the Phase column must be first and use `Pxx`.
- Requirements use `REQ-###`.
- Tests use `TEST-###`.
- Evaluations use `EVAL-###`.
- Manual checks, if any, use `CHECK-###` and must not appear in the RTM.

TDD and verification contract:
- Verification-first: metrics, tests, and evals are binding acceptance controls.
- Every phase must include ordered Plan-and-Solve subtasks with explicit verification modes.
- No behavior-changing implementation subtask may appear before failing coverage exists for the impacted REQ(s).
- RED and GREEN must run the same command for the same TEST-###.
- Every TEST-### must be concrete: file path, exact command, fixtures/data, deterministic controls, pass criteria, expected runtime.
- Every created or modified test file must include a grep-able traceability tag comment such as `// TEST-###`, or the language/framework equivalent.
- No placeholders: forbidden terms include TBD, manual verify, run tests, ensure, check later, or unspecified Playwright/unit/perf checks.
- Any TEST-### without executable command, repo-relative path, and pass criteria is invalid.
- Any metric threshold change requires an ADR.
- Treat git restore points/tags as phase-boundary checkpoints, not implementation subtasks.
- Define compute controls: branch_limits, reflection_passes, and early_stop%.

Required document sections:

1. Title and metadata
- Project name
- Version
- Owners
- Date
- Document ID
- One-paragraph summary of purpose and scope

2. Design consensus and trade-offs
Extract technical debates and decisions from the conversation.
For each:
- Topic
- Verdict: FOR / AGAINST / DECISION
- Rationale grounded in repository/context constraints

3. PRD / stakeholder and system needs
- Problem
- Users
- Value
- Business goals
- Success metrics
- Scope
- Non-goals
- Dependencies
- Risks
- Assumptions

4. SRS / canonical requirements
- Functional requirements: `REQ-###`, type `func`
- Non-functional requirements: type `nfr`, `perf`, `security`, or `reliability`
- Interface/API requirements: type `int`
- Data requirements: type `data`
- Error handling and telemetry expectations
- Acceptance criteria at requirement level only; do not map to TEST IDs here
- Architecture diagram:
  - Mermaid diagram first
  - C4-style ASCII representation second

5. Iterative implementation and test plan
Include:
- Phase strategy decomposed by complexity into atomic, verifiable Plan-and-Solve subtasks
- Risk register: risk, trigger, mitigation
- Suspension/resumption criteria

Use Plan-and-Solve decomposition for every phase. Decompose the work before
writing, but do not output chain-of-thought. Output only the auditable
implementation plan: ordered subtasks, dependencies, impacted files/surfaces,
requirement links, verification links, commands, expected results, evidence,
risks, and stop conditions.

Standards tailoring note:
- This plan is standards-informed, not a claim of ISO/IEEE/FAA compliance.
- Each phase must produce auditable lifecycle evidence: requirement links,
  design/code surfaces, verification method, validation purpose, configuration
  checkpoint, risks, assumptions, and unresolved decisions.
- For FAA/DO-178C-style or other safety-critical work, add development assurance
  level assumptions, independence expectations, review/analysis evidence,
  structural coverage expectations, tool qualification assumptions, and
  certification data outputs before treating the plan as safety-critical.

For every phase:
- `### Phase Pxx: <Outcome>`
- Phase goal: one concrete system outcome, not an activity label.
- Scope and objectives, including impacted `REQ-###`.
- Impacted surfaces: exact repo-relative files, modules, APIs, schemas,
  commands, data flows, external contracts, or operational surfaces.
- Lifecycle evidence:
  - Requirements evidence
  - Design/code surface evidence
  - Verification method
  - Validation purpose
  - Configuration checkpoint
  - Risks and assumptions
- Plan-and-Solve subtasks:
  - Use ordered IDs: `Pxx.S01`, `Pxx.S02`, ...
  - Each subtask must be atomic enough for one coding agent to complete before
    moving on.
  - Each subtask title must start with a concrete action, for example
    "Add failing coverage for expired token refresh", "Implement bounded retry",
    "Wire session refresh into login flow", or "Measure retry latency".
  - Do not use `RED`, `GREEN`, `REFACTOR`, `MEASURE`, `VERIFY`, restore point,
    or an exit-gate color as the subtask title.
  - Each subtask must include:
    - Action: specific implementation, verification, integration, or measurement action.
    - Why now: dependency or ordering reason.
    - Files/surfaces: exact repo-relative paths or components.
    - Requirement link: impacted `REQ-###`.
    - Verification link: `TEST-###` or `EVAL-###`; use `CHECK-###` only for
      non-automatable human checks, never as the only verification for a
      behavior-changing implementation subtask.
    - Verification mode: `RED`, `GREEN`, `REFACTOR`, `MEASURE`, or `VERIFY`.
    - Command/procedure: exact validation command for `TEST-###` or `EVAL-###`;
      clear human procedure for `CHECK-###`; `N/A` only for bounded inspection
      subtasks.
    - Expected result.
    - Evidence produced: test file, code diff, metric output, ADR, log, or screenshot.
    - Stop/escalate condition.
    - Unlocks: next subtask ID or phase exit.
  - Render every subtask in this exact shape:
    - `Pxx.S01 <Concrete action title>`
      - Action:
      - Why now:
      - Files/surfaces:
      - Requirement link:
      - Verification link:
      - Verification mode:
      - Command/procedure:
      - Expected result:
      - Evidence produced:
      - Stop/escalate condition:
      - Unlocks:
  - Solve one subtask at a time. Do not start `Pxx.S(N+1)` until `Pxx.SN`
    passes its validation or has a documented blocker.
- Required verification sequence:
  - Before behavior-changing implementation subtasks, add or update failing
    coverage with verification mode `RED`.
  - Matching `RED` and `GREEN` subtasks must run the same command for the same
    `TEST-###`.
  - `REFACTOR` is required when the green implementation introduces duplication,
    unclear structure, inconsistent style, unnecessary surface area, or avoidable
    debt; otherwise include a `VERIFY` subtask stating `No refactor needed` with
    one-sentence rationale.
  - `MEASURE` must run the relevant `EVAL-###` or metric command when the phase
    affects performance, reliability, quality, model behavior, data quality, or
    other thresholded outcomes.
- Exit gates:
  - Proceed: all required tests/evals pass and traceability is complete.
  - Escalate: missing decision, missing external contract, unstable test, or
    requirement ambiguity blocks reliable implementation.
  - Stop: acceptance criteria cannot be met without changing scope.
- Phase metrics with estimated value and one-sentence rationale:
  - Confidence %
  - Long-term robustness %
  - Internal interactions
  - External interactions
  - Complexity %
  - Feature creep %
  - Technical debt %
  - YAGNI score
  - MoSCoW
  - Local/non-local scope
  - Architectural changes count

6. Evaluations
Provide a YAML block listing each eval:
- id
- purpose: dev / holdout / adversarial
- metrics
- thresholds
- seeds
- runtime_budget

7. Tests
7.1 Test inventory
- Enumerate actual repo test frameworks/runners.
- List exact existing commands from package.json, Makefile, scripts/, or CI config.
- List file globs/locations for each test type.
- If a command is missing, create it in a phase before referencing it.

7.2 Test suites overview
For each suite:
- name: Unit / Integration / E2E / Perf / Data Drift / Static
- purpose
- runner
- command
- runtime budget
- when it runs: pre-commit / CI / nightly

7.3 Test definitions
For every `TEST-###` referenced anywhere:
- id
- name
- type: unit / integration / e2e / perf / static
- verifies: `REQ-###` list
- location: repo-relative test path, existing or to be created
- command: exact shell command for this test or smallest runnable scope
- fixtures/mocks/data
- deterministic controls: seeds, timeouts, environment variables
- pass_criteria
- expected_runtime

7.4 Manual checks, optional
If needed, define `CHECK-###` with a clear human procedure.
Do not include `CHECK-###` in the RTM.

8. Data contract
- Schema snapshot
- Invariants
- Privacy/data quality constraints

9. Reproducibility
- Seeds
- Hardware assumptions
- OS/driver/container tag
- Relevant environment variables

10. Requirements Traceability Matrix
Table columns must be exactly:
`Phase | REQ-### | TEST-### | Test Path | Command`

Rules:
- Every REQ maps to at least one TEST.
- Every TEST path and command must match Section 7.3.

11. Execution log template
Blank living-document template with:
- Phase Status: Pending/Done
- Completed Steps
- Quantitative Results: metrics mean +/- std, 95% CI
- Issues/Resolutions
- Failed Attempts
- Deviations
- Lessons Learned
- ADR Updates

12. Appendix: ADR index
List ADR IDs and one-line decisions.

13. Consistency check
Before finalizing the document, verify:
- All REQs appear in the RTM.
- All TEST IDs referenced in phases, evals, or RTM are defined in Section 7.3.
- Every phase has ordered Plan-and-Solve subtasks with explicit verification modes.
- Every behavior-changing implementation subtask is preceded by a RED coverage subtask.
- No behavior-changing implementation subtask uses CHECK-### as its only verification link.
- Every phase has populated metrics.
- Every subtask includes a TEST-###, EVAL-###, or CHECK-### link plus an exact
  command/procedure, except bounded inspection subtasks may use `N/A` with
  explicit inspection target and evidence produced.
- No invented commands, placeholders, or context-dependent references remain.
```
<!-- END phase-plan-follow-upper.txt copy -->

</details>

The formatter adds the standalone document wrapper, PRD/SRS/phase structure,
requirements, tests, metrics, and traceability. It should capture the decisions
from the discussion, step-back review, Ask Me answers when available, and
[Overengineering Check](#overengineering-check) instead of reopening design from
scratch.

After the formatted plan is created, look over the phase titles and metrics to
make sure the steps make sense and the metrics look good. If some phases have
low metrics, ask the LLM to split the phase, refine the metrics with more
precise steps, or ask you questions to increase the chances of success.

### Refining the Plan (Optional)

Starting with GPT-5.2, the
[`phase-plan-follow-upper.txt`](phase-plan-follow-upper.txt) formatter does a
better job and is often enough on its own. For complicated plans, run the
[`plan-phase-booster.fish`](plan-phase-booster.fish) script after formatting to
refine each section and phase. This refinement can take around 30-60 minutes on
GPT-5.2 xhigh. High is enough, though; I use xhigh mostly for the original
plan.

### Tests

Testing is highly important for scalability and self-healing in vibecoding.
Logs, tracing, diagnostics, and test output should be easy for LLMs to digest
and turn into action. Add instructions, references, log retrieval commands,
architecture navigation notes, and other context that helps the LLM diagnose the
system without guessing.

Test coverage is important. For test coverage planning, I use:

```
Do we have a proper test coverage and harness? if not, brainstorm which tests
to create so we have a proper test coverage. run subagents for 1) ISO/IEC/IEEE
29119, 2) DO-178C (MC/DC), 3) IEEE 1012 (V&V), 4) NIST Pairwise standards to
analyze which tests to propose.
```

### Executing the Plan

Before execution, rerun the [Overengineering Check](#overengineering-check)
against the final plan.

After the plan is ready, I use:

```
Implement the plan phase by phase and for each phase step by step. Do not
stop until all phases are done and all tests are green; even if it takes a
very long time, this is meant to be a long task. Don't do any shortcuts or
hacks. We need reliable solutions. Do not change the purpose of the tests or
fake passing. We need reliability.
```

This starts a multi-hour job. You can replace "the plan" with the `.md` file
of the plan. Note: LLM feedback on this prompt is that there is no discussion
of what happens when things fail; I didn't find it to be a problem because
models typically stop anyway.

## Known Error Report (KER) Generation

After a long session with an LLM resolving a bug, if you want to keep a note
of the symptoms and the solution for future reference, use
[`./ker-generation-prompt.txt`](ker-generation-prompt.txt) to turn a debugging
session into a reusable Known Error Report (KER) plus a Problem Record, saved
under `./ker/` with a grep-friendly filename.

## Branching

When the LLM gives me feedback with a few points and I want to focus on one at a time:

```
This should be a separate discussion. Inside a folder "./discussions/"
create an .md file that is self-contained and has all of the
information to continue this discussion.
```

## My Personal Stack

My current production stack for [prls.co](https://prls.co), a synthetic-data
generation pipeline with human review, 100s of tests, and 1000s of concurrent
LLM calls, is TypeScript with Firebase, React, GitHub Actions, and Cloudflare
for hosting.

I pick Firebase mainly because of Firestore and the GCP infrastructure. It
drastically reduces boilerplate code, which makes the context window smaller.
With Postgres, I would also need to worry about scaling and vacuuming. For newer
projects that do not require an intense database, I use Cloudflare only with its
D1 database.

For tools, I started moving toward Go for local tools. You can ask an AI to find
publications comparing Go, TypeScript, and Python, but my practical reason is
that Go is typed, resource-efficient, has a fast iteration loop, and has higher
quality training data. I used it for my
[codex-langfuse-tracer](https://github.com/kirilligum/codex-langfuse-tracer)
project and a few other internal ones.

In the future, I plan to migrate to self-hosting. For that, I will use Go,
Temporal, ScyllaDB, ClickHouse, and Elixir Phoenix LiveView.
