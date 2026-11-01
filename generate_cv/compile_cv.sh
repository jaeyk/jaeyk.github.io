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

# Normalize malformed or inconsistent double quotation marks before compiling.
QUOTE_NORMALIZER="${SCRIPT_DIR}/normalize_cv_quotes.py"
if command -v python3 >/dev/null 2>&1 && [[ -f "${QUOTE_NORMALIZER}" ]]; then
  python3 "${QUOTE_NORMALIZER}" "${TEX_PATH}"
else
  echo "Error: Python 3 or quote normalizer not found." >&2
  exit 1
fi

BASE_NAME="$(basename "${TEX_FILE}" .tex)"
PDF_PATH="${SCRIPT_DIR}/${BASE_NAME}.pdf"
OUTPUT_NAME="CV_Jae_Yeon_Kim.pdf"
OUTPUT_PATH="${REPO_DIR}/public/${OUTPUT_NAME}"

# The CV loads its fonts from generate_cv/fonts, which needs XeTeX and this working directory.
cd "${SCRIPT_DIR}"
if command -v latexmk >/dev/null 2>&1; then
  latexmk -xelatex -interaction=nonstopmode -halt-on-error "${TEX_FILE}"
elif command -v xelatex >/dev/null 2>&1; then
  xelatex -interaction=nonstopmode -halt-on-error "${TEX_FILE}"
  xelatex -interaction=nonstopmode -halt-on-error "${TEX_FILE}"
elif command -v tectonic >/dev/null 2>&1; then
  tectonic "${TEX_FILE}"
else
  echo "Error: No XeTeX engine found (latexmk with xelatex, xelatex, or tectonic)." >&2
  exit 1
fi

if [[ ! -f "${PDF_PATH}" ]]; then
  echo "Error: Expected PDF not found: ${PDF_PATH}" >&2
  exit 1
fi

cp "${PDF_PATH}" "${OUTPUT_PATH}"
echo "Compiled PDF written to: ${OUTPUT_PATH}"

SITE_UPDATE_SCRIPT="${SCRIPT_DIR}/../update_site.sh"
if [[ "${UPDATE_SITE_SKIP_RECURSE:-0}" == "1" ]]; then
  echo "Skipping site update recursion (UPDATE_SITE_SKIP_RECURSE=1)."
elif [[ -x "${SITE_UPDATE_SCRIPT}" ]]; then
  "${SITE_UPDATE_SCRIPT}"
  echo "Done: ran ${SITE_UPDATE_SCRIPT}"
else
  echo "Warning: site update script not found or not executable: ${SITE_UPDATE_SCRIPT}" >&2
fi

if [[ "${UPDATE_SITE_SKIP_GIT:-0}" == "1" ]]; then
  echo "Skipping git commit/push from compile script (UPDATE_SITE_SKIP_GIT=1)."
elif git -C "${REPO_DIR}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git -C "${REPO_DIR}" add \
    "generate_cv/${TEX_FILE}" \
    "generate_cv/${BASE_NAME}.pdf" \
    "generate_cv/compile_cv.sh" \
    "generate_cv/normalize_cv_quotes.py" \
    "generate_cv/fonts" \
    "public/${OUTPUT_NAME}"

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
