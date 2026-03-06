#!/usr/bin/env bash
set -euo pipefail

# Compile a TeX CV and write a canonical output file name used by the site.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TEX_FILE="${1:-cv_Kim.tex}"
TEX_PATH="${SCRIPT_DIR}/${TEX_FILE}"

if [[ ! -f "${TEX_PATH}" ]]; then
  echo "Error: TeX file not found: ${TEX_PATH}" >&2
  exit 1
fi

BASE_NAME="$(basename "${TEX_FILE}" .tex)"
PDF_PATH="${SCRIPT_DIR}/${BASE_NAME}.pdf"
OUTPUT_NAME="CV_Jae_Yeon_Kim.pdf"
OUTPUT_PATH="${REPO_DIR}/${OUTPUT_NAME}"

if command -v latexmk >/dev/null 2>&1; then
  latexmk -pdf -interaction=nonstopmode -halt-on-error "${TEX_PATH}"
elif command -v pdflatex >/dev/null 2>&1; then
  pdflatex -interaction=nonstopmode -halt-on-error -output-directory="${SCRIPT_DIR}" "${TEX_PATH}"
  pdflatex -interaction=nonstopmode -halt-on-error -output-directory="${SCRIPT_DIR}" "${TEX_PATH}"
elif command -v tectonic >/dev/null 2>&1; then
  tectonic --outdir "${SCRIPT_DIR}" "${TEX_PATH}"
else
  echo "Error: No LaTeX engine found (latexmk, pdflatex, or tectonic)." >&2
  exit 1
fi

if [[ ! -f "${PDF_PATH}" ]]; then
  echo "Error: Expected PDF not found: ${PDF_PATH}" >&2
  exit 1
fi

cp "${PDF_PATH}" "${OUTPUT_PATH}"
echo "Compiled PDF written to: ${OUTPUT_PATH}"

SITE_UPDATE_SCRIPT="${SCRIPT_DIR}/../update_site.sh"
if [[ -x "${SITE_UPDATE_SCRIPT}" ]]; then
  "${SITE_UPDATE_SCRIPT}"
  echo "Done: ran ${SITE_UPDATE_SCRIPT}"
else
  echo "Warning: site update script not found or not executable: ${SITE_UPDATE_SCRIPT}" >&2
fi

if git -C "${REPO_DIR}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git -C "${REPO_DIR}" add "generate_cv/${TEX_FILE}" "generate_cv/${BASE_NAME}.pdf" "${OUTPUT_NAME}"

  if git -C "${REPO_DIR}" diff --cached --quiet; then
    echo "No changes to commit."
  else
    COMMIT_MSG="${COMMIT_MSG:-Update CV ($(date '+%Y-%m-%d %H:%M:%S'))}"
    git -C "${REPO_DIR}" commit -m "${COMMIT_MSG}"
    git -C "${REPO_DIR}" push
    echo "Done: committed and pushed changes."
  fi
else
  echo "Warning: ${REPO_DIR} is not a git repository; skipping commit/push." >&2
fi
