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

### Creating a Plan

1. Have a conversation with an LLM, then use the [`phase-plan-follow-upper.txt`](phase-plan-follow-upper.txt) prompt to create an `.md` plan file in the `plans` folder.

2. Besides typical instructions that fix weaknesses of current LLMs and advocate for the best coding and architecture principles, the prompt uses IEEE standard references that have a lot of training data. We also break it into PRD, SRS, and phases sections. To control the quality of each section, we use metrics for high-quality code and common mistakes of LLMs (overengineering, duplication, etc.).

3. After you do that, look over the phase titles and metrics to make sure the steps make sense and the metrics look good. If some phases have low metrics, ask the LLM to split the phase, refine the metrics with more precise steps, or ask you questions to increase the chances of success.

### Refining the Plan

Starting with GPT-5.2, the [`phase-plan-follow-upper.txt`](phase-plan-follow-upper.txt) prompt does a better job and is often enough on its own. However, LLMs typically don't produce very long outputs, so we run the [`plan-phase-booster.fish`](plan-phase-booster.fish) script to refine each section and phase. This refinement can take around 30-60 minutes on GPT-5.2 xhigh. High is enough though; I use xhigh mostly for the original plan.

### Executing the Plan

After the plan is ready, I use:

```
Implement the plan phase by phase and for each phase step by step. Do not
stop until all phases are done and all tests are green; even if it takes a
very long time, this is meant to be a long task. Don't do any shortcuts or
hacks. We need reliable solutions. Do not change the purpose of the tests or
fake passing. We need reliability.
```

This starts a multi-hour job. You can replace "the plan" with the `.md` file of the plan. Note: LLM feedback on this prompt is that there is no discussion of what happens when things fail; I didn't find it to be a problem—models typically stop anyway.

### Reviewing the Plan

After execution, I use:

```
Check the plan. We don't want to overengineer things; we want one way of
doing things, meaning no legacy and no fallbacks. Prefer direct approaches
over adapters and safety for situations that are unlikely to happen. Prefer
general code over minor performance gains because we want the codebase to be
smaller.
```

## Step-Back Prompts

```
Step back, think about similar architectural patterns, system designs,
industry standards. Give an extensive technically detailed response with
relevant examples.
```

```
Think creatively, do you see any other alternatives? If you were building the
project from scratch for a multi-billion dollar SaaS, how would you do things
differently?
```

## Quick Checks

```
Wait, check your reasoning, do you see any flaws or better alternatives?
```

## Ask Me

Use [`./ask_me.txt`](ask_me.txt) to get the LLM to ask you questions. It will give you options and suggestions. By default, you just need to review and approve it; otherwise, have a discussion.

Here I ask the LLM to structure the output as multiple options with a
recommendation. When I use this prompt, I care more about review speed than
highest accuracy; for highest accuracy, ask the LLM to list issues with
explanations, then dive into them in separate sessions. After this prompt,
instead of writing explanatory text, you can just say `I agree with your
recommendations` or reply with `1A, 2A, 3B, 4A, more details
about 5`.

I sometimes follow up with:

```
Analyze my answers above against the previous task and codebase context.

1. **Gap Check**: If these answers reveal NEW complexities, missing edge
cases, or further ambiguities, you must ask follow-up questions now.
2. **Success Condition**: If everything is now 100% clear and no further
information is needed, state exactly: "Context fully synthesized. All gaps
closed."

**STOP**: Do not write code. Do not propose a blueprint yet. We are strictly
in the discussion phase.
```

## KER Generation

After a long session with an LLM resolving a bug, if you want to keep a note
of the symptoms and the solution for future reference, use
[`./ker-generation-prompt.txt`](ker-generation-prompt.txt) to turn a debugging
session into a reusable Known Error Record (KER) plus a Problem Record, saved
under `./ker/` with a grep-friendly filename.

## Branching

When the LLM gives me feedback with a few points and I want to focus on one at a time:

```
This should be a separate discussion. Make a folder called "discussions" and
inside create an .md file that is self-contained and has all of the
information to continue this discussion.
```
