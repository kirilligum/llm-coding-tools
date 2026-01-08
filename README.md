# llm-coding-tools

## Planning

### Creating a Plan

1. Have a conversation with an LLM, then use `phase-plan-follow-upper.txt` prompt to create an `.md` plan file in the `plans` folder.

2. Besides typical instructions that fix weaknesses of current LLMs and advocate for the best coding and architecture principles, the prompt uses IEEE standard references that have a lot of training data. We also break it into PRD, SRS, and phases sections. To control the quality of each section, we use metrics for high-quality code and common mistakes of LLMs (overengineering, duplication, etc.).

3. After you do that, look over the phase titles and metrics to make sure the steps make sense and the metrics look good. If some phases have low metrics, ask the LLM to split the phase, refine the metrics with more precise steps, or ask you questions to increase the chances of success.

### Refining the Plan

Starting with GPT-5.2, the `phase-plan-follow-upper.txt` prompt does a better job and is often enough on its own. However, LLM models typically don't produce very long outputs, so we run `plan-phase-booster.fish` script to refine each section and phase. This refinement can take around 30-60 minutes on GPT-5.2 xhigh. High is enough though; I use xhigh mostly for the original plan.

### Executing the Plan

After the plan is done, I use:

```
Implement the plan phase by phase and for each phase step by step. Do not stop until all phases are done and all tests are green; even if it takes a very long time, this is meant to be a long task. Don't do any shortcuts or hacks. We need reliable solutions. Do not change the purpose of the tests or fake passing. We need reliability.
```

This starts a multi-hour job. You can replace "the plan" with the `.md` file of the plan. Note: LLM feedback on this prompt is that there is no discussion of what happens when things fail; I didn't find it to be a problem—models typically stop anyway.

### Reviewing the Plan

After execution, I use:

```
Check the plan. We don't want to overengineer things; we want one way of doing things, meaning no legacy and no fallbacks. Prefer direct approaches over adapters and safety for situations that are unlikely to happen. Prefer general code over minor performance gains because we want the codebase to be smaller.
```

## Step-back

```
step back, think about similar architectural patterns, system designs, industry standards. give an extensive technically detailed response with relevant examples
```

```
think creatively, do you see any other alternatives? if you would be building the project from scratch for a multi-billion dollar saas, how would you do things differently
```

## quick checks

```
wait, check your reasoning, do you see any flaws or better alternatives?
```

## ask me

```
Analyze the current context and the task discussed in our recent messages.
Do not write code or modify files yet. Execute the following:

### STEP 1: GROUND TRUTH
Identify the tech stack and coding patterns (files, types, structure) currently in use.

### STEP 2: GAP ANALYSIS & RESEARCH
Identify the key decisions, ambiguities, or missing logic (the "Gaps") needed to complete the task.
For *each* Gap, perform internal research to formulate distinct technical approaches.

### STEP 3: CONSULTATIVE QUESTIONING
For each Gap, present a **Multiple Choice Menu** using letters (A, B, C, etc.).

**Guidelines for Options:**
* **Autonomy**: You are not limited to a fixed number of options. Provide as many distinct, viable paths as you identify.
* **Spectrum**: Ensure your options cover the range from "Robust System Architecture" (long-term, scalable) to "Pragmatic/Simple" (immediate, low-risk).
* **Research-Backed**: Briefly explain the logic or trade-off for each option.

**Format for each Gap:**
1. **The Question**: Define the specific decision needed.
2. **Context**: Why does this matter? (e.g., "This affects how we handle Auth state globally").
3. **The Options**:
   * **A**: [Description of approach]
   * **B**: [Description of approach]
   * ... (continue as needed)
4. **Recommendation**: State which letter you recommend and why.

**STOP**: End your response immediately after presenting the menu. I will reply with my selection (e.g., "1A, 2C").
```

and i sometimes follow up with

```
Analyze my answers above against the previous task and codebase context.

1. **Gap Check**: If these answers reveal NEW complexities, missing edge cases, or further ambiguities, you must ask follow-up questions now.
2. **Success Condition**: If everything is now 100% clear and no further information is needed, state exactly: "Context fully synthesized. All gaps closed."

**STOP**: Do not write code. Do not propose a blueprint yet. We are strictly in the discussion phase.
```

## branching

When llm gives me a feedback with a few points and i want to focus on one at a time,

```
this should be a separate discussions. make a folder discussions and inside create an md file that is self
  contained and has all of the information to continue this discussion
```
