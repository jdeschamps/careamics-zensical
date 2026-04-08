#!/usr/bin/env bash
set -euo pipefail # fail fast

# -- Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
FROM_GIT_DIR="$ROOT_DIR/from_git"
GUIDES_DIR="$ROOT_DIR/docs/content/guides"

# Add repositories here (one per line)
REPOS=(
  "https://github.com/CAREamics/careamics.git"
)

# -- Helpers

# extract the repo name from a git URL (necessary for pulling if it exists)
repo_name_from_url() {
  basename "$1" .git
}

# clone or update a repository
clone_or_update_repo() {
  local url="$1"
  local name
  name="$(repo_name_from_url "$url")"
  local dest="$FROM_GIT_DIR/$name"

  if [[ -d "$dest/.git" ]]; then
    echo "Updating '$name' ..."
    git -C "$dest" pull --ff-only
  else
    echo "Cloning '$name' ..."
    git clone "$url" "$dest"
  fi
}

# copy docs from careamics/docs into docs/content/guides
copy_careamics_docs_v2() {
  local src="$FROM_GIT_DIR/careamics/docs"

  if [[ ! -d "$src" ]]; then
    echo "Error: $src not found, skipping copy."
    return 1
  fi

  echo "Copying careamics docs to $GUIDES_DIR ..."
  mkdir -p "$GUIDES_DIR"
  cp -R "$src"/. "$GUIDES_DIR"/
}

copy_careamics_docs_v1() {
  local src="$FROM_GIT_DIR/careamics/docs/v0.1"

  if [[ ! -d "$src" ]]; then
    echo "Error: $src not found, skipping copy."
    return 1
  fi

  echo "Copying careamics docs to $GUIDES_DIR ..."
  mkdir -p "$GUIDES_DIR"
  cp -R "$src"/. "$GUIDES_DIR"/
}


# -- Main

main() {
  mkdir -p "$FROM_GIT_DIR"

  for url in "${REPOS[@]}"; do
    clone_or_update_repo "$url"
  done

  # copy_careamics_docs_v2
}

main "$@"
