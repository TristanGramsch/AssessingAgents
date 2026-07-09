# AssessingAgents

An agentic Assessor's office that independently appraises and exempts properties, producing a fairness-seeking tax roll.

[![Watch the video](https://img.youtube.com/vi/D-tFgs3hMRE/maxresdefault.jpg)](https://youtu.be/D-tFgs3hMRE)

## How it works

The engine is an organization of agents. Each has a profile (who they are) and an instruction (what they do this run). A runner reads these files, feeds them to an LLM with the right context and artifacts, and the agents produce the tax roll. This is pure content, not executable code. 

## Structure

```
engine/
  organization/
    profiles/          # who each agent is (general, human descriptions)
    instructions/      # what each agent does (mission + outputs per run)
  locations/           # location-specific data fed to runs
```

## Workflow

The numbering encodes the dependency graph. Same depth = run in parallel.

```
Client instruction (location / scope)
              │
              ▼
  ┌─────────────────────────┐
  │  1. Chief               │  depth 0 — no dependencies
  │  → chief-report.txt     │
  └────────────┬────────────┘
               │
     ┌─────────┴─────────┐
     ▼                   ▼
  ┌───────────────┐  ┌───────────────┐
  │  2a. Collector│  │  2b. Exemptor │  depth 1 — both need chief only
  │  → schemas    │  │  → exemptions/│
  │  → report     │  │  → final-roll │
  └───────┬───────┘  │  → report     │
          │          └───────────────┘
          ▼
  ┌─────────────────────────┐
  │  3a. Appraiser          │  depth 2 — needs collector
  │  → initial-tax-roll.csv │
  │  → appraiser-report.txt │
  │  → appraisal/           │
  └────────────┬────────────┘
               │
     ┌─────────┴─────────┐
     ▼                   ▼
  ┌───────────────┐  ┌───────────────┐
  │  4. Educator  │  │ 5. Chief      │  depths 3-4 — need everything
  │  → studies/   │  │    (Review)   │
  │  → report     │  │  → decision   │
  └───────────────┘  └───────────────┘
               │
               ▼
        Tax roll published
       (or returned for rework)
```

## Agent dependencies

| Agent | Needs | Produces |
|---|---|---|
| Chief | nothing | `chief-report.txt` |
| Collector | `chief-report.txt` | data schemas, `collector-report.txt` |
| Exemptor | `chief-report.txt` | `exemptions/`, `final-tax-roll.csv`, `exemptor-report.txt` |
| Appraiser | `chief-report.txt`, `collector-report.txt`, schemas | `appraisal/`, `initial-tax-roll.csv`, `appraiser-report.txt` |
| Educator | all reports + both tax rolls | `studies/`, `educator-report.txt` |
| Chief (Review) | all outputs | `review-decision.txt` |
