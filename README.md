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

### Follow Up

After execution finishes, ask for a concrete closeout:

```
Are you completely done? If you diverged from the plan, detail exactly where
and why. List the specific files where you updated documentation and tests.
Confirm what temporary files or artifacts you cleaned up, and outline the
immediate next steps.
```

The answer should separate completed work, verification, documentation/test
updates, cleanup, and remaining follow-ups.

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

## Keyboard Prompt Presets (ZMK/QMK)

These prompts can be configured as text macros in ZMK or QMK, making them
available as keyboard shortcuts in any LLM interface. Here is one Fn-layer
layout:

### Reason — Fn + G

> Wait, check your reasoning, do you see any flaws or better alternatives?

### Abstract — Fn + B

> Take a step back. Formulate a broader, more abstract version of my question
> that captures the core mechanics of the problem without any of my specific
> details. Answer that abstract question first, then use that foundational
> knowledge to solve my specific request

### Plan — Fn + V

> Identify the specific missing variables, unstated assumptions, or system
> constraints required to execute this flawlessly. Ask for my input on them
> using high-SNR context. Generate 2 to 5 materially distinct execution paths
> (A, B, C, D, E), ranking them strictly from highest long-term structural value
> to highest short-term immediate utility. For each path, explicitly define the
> primary trade-off being made. Finally, declare your definitive recommendation,
> and state the exact condition or new piece of information that would force you
> to change this recommendation
