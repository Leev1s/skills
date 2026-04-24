---
name: resume-master
description: Turn student-style resumes, cover letters, interview answers, LinkedIn summaries, and career stories into employer-facing evidence of role fit. Use this skill whenever the user asks for resume edits, job application positioning, interview self-introductions, internship or new-grad applications, project bullet rewrites, career-switch narratives, or help translating academic/project experience into business, research, data, product, quant, AI, or technical hiring language.
---

# Resume Master

## Overview

Help the user express career value from the employer's point of view. The core shift is:

```text
I learned / I know / I want -> I can solve this role's problem, and here is the evidence.
```

Use this skill for resumes, cover letters, personal statements for jobs, LinkedIn profiles, interview answers, networking messages, and role-specific positioning.

## First Pass

1. Identify the target role, industry, seniority, and hiring context.
2. Extract the employer's likely problem from the job description or role title.
3. Translate the user's background into role-relevant evidence.
4. Remove material that does not support the target role.
5. Rewrite in concise, concrete language.

If the user provides no job description, infer from the role name and say what assumption you are making.

## Six Traps To Avoid

### 1. Defending Skills Instead Of Solving Problems

Do not stop at lists like "Python, SQL, machine learning, reports." Convert tools into useful outcomes:

```text
Weak: Skilled in Python and machine learning.
Better: Built a Python pipeline to clean 120k rows of sales data, trained a churn model, and delivered risk segments for retention planning.
```

### 2. Writing More As If More Means Better

More content can hide the signal. Keep only material that proves fit for the role. Prefer a few strong bullets with clear scope, action, method, and result over long lists of tasks.

### 3. Describing The Major Instead Of The Business Need

Academic labels are not enough. Translate fields of study into hiring language:

- Statistics -> experiment design, measurement, forecasting, decision support
- AI or machine learning -> prediction, automation, ranking, quality control, model evaluation
- Math or quant -> pricing, risk, optimization, signal testing, structured analysis
- Research -> literature synthesis, hypothesis testing, data collection, evidence-based recommendations

### 4. Ignoring Formatting And Detail

Treat formatting as evidence of judgment. Fix inconsistent spacing, unclear headings, tense drift, typos, vague dates, and bullets that cannot be scanned quickly. A messy resume makes the reader doubt the user's rigor.

### 5. Missing Logic In Experience Descriptions

Structure project and experience bullets around this logic:

```text
Context -> Problem -> Action -> Method -> Result -> Role relevance
```

Do not force every bullet to include every part. Include the parts that make the achievement understandable and credible.

### 6. Putting Everything In One Resume

Different roles need different versions. Prioritize different evidence for algorithm, quant, research assistant, product analytics, consulting, operations, marketing, or general business roles. A resume is not a compressed autobiography.

## Rewrite Workflow

When editing a resume or application answer:

1. Start with the target role's needs.
2. Mark each original claim as keep, cut, merge, or rewrite.
3. Turn duties into outcomes.
4. Add numbers only when they clarify scale or impact.
5. Use strong verbs, but avoid inflated language.
6. Keep bullets specific enough that a recruiter can picture the work.
7. Return the revised text before optional notes.

## Bullet Formula

Use this as the default pattern:

```text
Action verb + task/problem + method/tool + scope + result/impact
```

Examples:

```text
Cleaned and joined 8 raw survey tables in Python, reducing manual data prep from 3 hours to 20 minutes per weekly report.
Evaluated three classification models with cross-validation and error analysis, identifying a simpler baseline that improved recall by 12%.
Synthesized 35 policy papers into a 6-page evidence memo, helping the research team narrow its interview protocol.
```

## Interview Answer Formula

For interview answers, use:

```text
Role need -> relevant example -> what I did -> result -> how it transfers
```

Avoid answers centered on what the user wants to learn unless the question explicitly asks about motivation. Even then, connect motivation to contribution.

## Output Rules

- Reply in the user's language unless they ask otherwise.
- Lead with the rewritten version when the user asks for editing.
- Keep explanations short and practical.
- Preserve truthful scope. Do not invent metrics, companies, tools, awards, or outcomes.
- If a useful metric is missing, use a bracketed placeholder such as `[X%]` or ask for the exact number after giving the rewrite.
- Do not add unrelated career advice unless it directly improves the application material.

## Common Output Shapes

For a resume rewrite:

```text
Rewritten bullets:
- ...
- ...

Notes:
- ...
```

For role positioning:

```text
Target angle:
...

Evidence to emphasize:
- ...

Evidence to cut or downplay:
- ...
```

For an interview answer:

```text
Answer:
...

Why this works:
- ...
```
