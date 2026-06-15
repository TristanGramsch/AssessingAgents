# AssessingAgents

An agentic Assessor's office that independently appraises and exempts properties, producing a fairness-seeking tax roll.

[![Watch the video](https://img.youtube.com/vi/D-tFgs3hMRE/maxresdefault.jpg)](https://youtu.be/D-tFgs3hMRE)

## Workflow

```
Client instruction (location / scope)
              │
              ▼
  ┌─────────────────────────┐
  │  1. Chief Assessor      │  Research local legal landscape, assessment
  │                         │  history, and Assessor's Office structure.
  │  → chief-report.txt     │
  └────────────┬────────────┘
               │
               ▼
  ┌─────────────────────────┐
  │  2. Collector           │  Map and collect all relevant data sources
  │                         │  (parcels, classifications, sales, etc.).
  │  → collector-report.txt │
  │  → data schemas         │
  └────────────┬────────────┘
               │
               ▼
  ┌─────────────────────────┐
  │  3. Appraiser           │  Apply appraisal methods to value every
  │                         │  property in the dataset.
  │  → initial-tax-roll.csv │
  │  → appraiser-report.txt │
  │  → appraisal/           │
  └────────────┬────────────┘
               │
               ▼
  ┌─────────────────────────┐
  │  4. Exemptor            │  Simulate the exemption process (homestead,
  │                         │  senior, veteran, etc.) and apply reductions.
  │  → final-tax-roll.csv   │
  │  → exemptor-report.txt  │
  │  → exemptions/          │
  └────────────┬────────────┘
               │
               ▼
  ┌─────────────────────────┐
  │  5. Educator            │  Produce public-facing equity studies (COD,
  │                         │  PRD, ratio analysis) and plain-language docs.
  │  → educator-report.txt  │
  │  → studies/             │
  └────────────┬────────────┘
               │
               ▼
  ┌─────────────────────────┐
  │  6. Chief Assessor      │  Review quality and fairness of the full roll.
  │     (Final Review)      │  Approve or reject with clear justification.
  │  → review-decision.txt  │
  └─────────────────────────┘
               │
               ▼
        Tax roll published
       (or returned for rework)
```

## Usage

Create `runs/<n>/client_instruction.txt` with the location / client instruction, then run:

```
./run_assessment.sh --run <n> --provider <provider> --model <model> --api-key <key> --instructions ./instructions
```

Example:

```
./run_assessment.sh --run 3 --provider openrouter --model "openai/gpt-5.4-nano" --api-key "sk-..." --instructions ./instructions
```

Step logs and agent reports are written under `runs/<n>/`.
