#!/usr/bin/env bash
#
# run_assessment.sh
#
# Runs the AssessingAgents workflow loop against an already-prepared run directory.
# The run directory must exist and contain client_instruction.txt plus all data files.
#
# Usage:
#   ./run_assessment.sh --run <n> --provider <provider> --model <model> --api-key <key> --instructions <path>
#
# Example:
#   ./run_assessment.sh --run 3 --provider openrouter --model "openai/gpt-5.4-nano" --api-key "sk-..." --instructions ./instructions
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

STEPS=(
  "01_chief_assessor.txt"
  "02_collector.txt"
  "03_appraiser.txt"
  "04_exemptor.txt"
  "05_educator.txt"
  "06_chief_review.txt"
)

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------
RUN="" PROVIDER="" MODEL="" API_KEY="" INSTRUCTIONS_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --run)      RUN="$2";      shift 2 ;;
    --provider) PROVIDER="$2"; shift 2 ;;
    --model)    MODEL="$2";    shift 2 ;;
    --api-key)       API_KEY="$2";          shift 2 ;;
    --instructions) INSTRUCTIONS_DIR="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$RUN" || -z "$PROVIDER" || -z "$MODEL" || -z "$API_KEY" || -z "$INSTRUCTIONS_DIR" ]]; then
  echo "Usage: $0 --run <n> --provider <provider> --model <model> --api-key <key> --instructions <path>" >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Validate environment
# ---------------------------------------------------------------------------
RUN_DIR="${SCRIPT_DIR}/runs/${RUN}"

if [[ ! -d "$INSTRUCTIONS_DIR" ]]; then
  echo "Error: instructions directory not found: ${INSTRUCTIONS_DIR}" >&2
  exit 1
fi

if [[ ! -d "$RUN_DIR" ]]; then
  echo "Error: run directory not found: ${RUN_DIR}" >&2
  exit 1
fi

if [[ ! -f "${RUN_DIR}/client_instruction.txt" ]]; then
  echo "Error: client_instruction.txt not found in ${RUN_DIR}" >&2
  exit 1
fi

if ! command -v forge >/dev/null 2>&1; then
  echo "Error: 'forge' CLI not found on PATH." >&2
  exit 1
fi

# ---------------------------------------------------------------------------
# Configure provider and model
# ---------------------------------------------------------------------------
API_KEY_VAR="$(echo "${PROVIDER}" | tr '[:lower:]' '[:upper:]')_API_KEY"
export "${API_KEY_VAR}=${API_KEY}"

forge config set model "${PROVIDER}" "${MODEL}"

LOCATION="$(cat "${RUN_DIR}/client_instruction.txt")"

echo "Run ${RUN} | ${PROVIDER} / ${MODEL}"

# ---------------------------------------------------------------------------
# Step loop
# ---------------------------------------------------------------------------
step_num=0
for step_file in "${STEPS[@]}"; do
  step_num=$((step_num + 1))
  instruction_path="${INSTRUCTIONS_DIR}/${step_file}"

  if [[ ! -f "$instruction_path" ]]; then
    echo "Error: missing instruction file: ${instruction_path}" >&2
    exit 1
  fi

  echo "Step ${step_num}/${#STEPS[@]}: ${step_file}"

  prompt="$(cat <<EOF
Run context
===========
You are an agent, member of the AssessingAgents organization.

Your working directory is organized as follows:
- data/     : input files for this run (client instruction, property data, schemas). Read only.
- reports/  : outputs from all agents. Read peer reports here. Write your own report here.
- logs/     : managed by the runner.

LOCATION / CLIENT INSTRUCTION:
${LOCATION}

(The same instruction is saved in client_instruction.txt.)

===========================================================
$(cat "${instruction_path}")
EOF
)"

  forge -C "${RUN_DIR}" -p "${prompt}" \
    | tee "${RUN_DIR}/step_${step_num}_$(basename "${step_file}" .txt)_log.txt"

  echo "Step ${step_num} complete."
done

echo "Workflow complete. Outputs are in: ${RUN_DIR}"
