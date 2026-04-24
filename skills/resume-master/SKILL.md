---
name: resume-master
description: Turn student-style resumes, cover letters, interview answers, LinkedIn summaries, and career stories into employer-facing evidence of role fit. Use this skill whenever the user asks for resume edits, job application positioning, interview self-introductions, internship or new-grad applications, project bullet rewrites, career-switch narratives, one-page resume pruning, or help translating academic/project experience into business, research, data, product, quant, AI, or technical hiring language.
---

# Resume Master

## Overview

Help the user express career value from the employer's point of view. A resume is not a complete history of what the user has done. It is an evidence chain for one question:

```text
Why is this person credible for this role?
```

The core shift is:

```text
I learned / I know / I want -> I can solve this role's problem, and here is the evidence.
```

Use this skill for resumes, cover letters, personal statements for jobs, LinkedIn profiles, interview answers, networking messages, and role-specific positioning.

## First Pass

1. Identify the target role, industry, seniority, and hiring context.
2. Extract the employer's likely problem from the job description or role title.
3. Translate the user's background into role-relevant evidence.
4. Choose the strongest proof points and remove material that does not support the target role.
5. Rewrite in concise, concrete language.
6. Check whether each line helps the reader decide faster.

If the user provides no job description, infer from the role name and say what assumption you are making.

## Six Student-To-Role Shifts

### 1. From Skills To Problems Solved

Do not stop at lists like "Python, SQL, machine learning, reports." Convert tools into useful outcomes:

```text
Weak: Skilled in Python and machine learning.
Better: Built a Python pipeline to clean 120k rows of sales data, trained a churn model, and delivered risk segments for retention planning.
```

Ask what each skill does for the target role:

- Python -> data analysis, automation, modeling, experiment reproduction, pipeline work
- Machine learning -> feature engineering, model evaluation, cross-validation, error analysis, interpretation
- Reporting -> conclusions that a mentor, team, or business stakeholder can use

### 2. From More Words To Higher Density

More content can hide the signal. Keep only material that proves fit for the role. Prefer a few strong bullets with clear scope, action, method, and result over long lists of tasks.

Use this deletion test:

```text
If this line does not help the reader judge role fit faster, cut or rewrite it.
```

### 3. From Major Labels To Role Language

Academic labels are background, not the argument. Translate fields of study into hiring language:

- Statistics -> experiment design, measurement, forecasting, decision support
- AI or machine learning -> prediction, automation, ranking, quality control, model evaluation
- Math or quant -> pricing, risk, optimization, signal testing, structured analysis
- Research -> literature synthesis, hypothesis testing, data collection, evidence-based recommendations

For common student targets:

- Data analyst -> data cleaning, statistical analysis, visualization, insight delivery, decision support
- Algorithm engineer -> experiment reproduction, inference flow, evaluation scripts, framework integration, deployment support
- Research assistant -> literature review, data processing, standard software, figures, experiment records, writing support
- Quant research -> time series modeling, factor research, backtesting, leakage control, signal generation, risk checks
- AI engineer -> model inference, framework adaptation, evaluation, container environments, open-source collaboration

### 4. From Project Diary To Project Logic

Do not write project experience as a diary. Structure it around:

```text
Goal -> responsibility -> method/tool -> problem solved -> result/impact
```

Do not force every bullet to include every part. Include the parts that make the achievement understandable and credible.

Valid student results include experiment reproduction, model improvement, faster computation, automation, dataset construction, evaluation framework setup, report or paper output, deployment, or smoother collaboration.

### 5. From Surface Polish To Credibility

Treat formatting as a work sample. Fix inconsistent spacing, unclear headings, tense drift, typos, vague dates, mixed punctuation, incorrect technical names, and bullets that cannot be scanned quickly. For technical, research, and data roles, messy details make the reader doubt rigor.

### 6. From One Autobiography To Targeted Versions

Different roles need different versions. Prioritize different evidence for algorithm, quant, research assistant, product analytics, consulting, operations, marketing, or general business roles. A resume is not a compressed autobiography.

If the same user targets multiple roles, produce separate emphasis lists instead of one generic "well-rounded" story.

## Rewrite Workflow

When editing a resume or application answer:

1. Start with the target role's needs.
2. Mark each original claim as keep, cut, merge, or rewrite.
3. Turn duties, courses, and tools into evidence of problem-solving.
4. Add method, scope, and result where they clarify credibility.
5. Add numbers only when they are true and useful.
6. Use strong verbs, but avoid inflated language.
7. Keep bullets specific enough that a recruiter can picture the work.
8. Return the revised text before optional notes.

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

For non-English resumes, keep the same logic in the target language:

```text
Action + task object + method/tool + result/impact
```

## Interview Answer Formula

For interview answers, use:

```text
Role need -> relevant example -> what I did -> result -> how it transfers
```

Avoid answers centered on what the user wants to learn unless the question explicitly asks about motivation. Even then, connect motivation to contribution.

## Pruning Rules

When the user asks what to include, favor focus over completeness:

- Keep experiences that prove the target role's core work.
- Merge repeated evidence instead of listing similar bullets.
- Downplay coursework unless it directly supports the role.
- Cut personal interest statements unless tied to concrete work.
- Preserve awards or credentials only when they strengthen the target story.

## Detail Check

Before finalizing a resume section, check:

- consistent dates, punctuation, capitalization, and tense
- clear project names and role labels
- bullet length that can be scanned quickly
- correct spelling of tools, models, frameworks, and methods
- no vague claims such as "participated in," "learned about," or "responsible for" without concrete action

## Output Rules

- Reply in the user's language unless they ask otherwise.
- Lead with the rewritten version when the user asks for editing.
- Keep explanations short and practical.
- Preserve truthful scope. Do not invent metrics, companies, tools, awards, or outcomes.
- If a useful metric is missing, use a bracketed placeholder such as `[X%]` or ask for the exact number after giving the rewrite.
- When input is thin, write a credible version using only known facts, then list the missing facts that would make it stronger.
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
