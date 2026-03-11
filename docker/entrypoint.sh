#!/bin/sh
set -e

if [ -z "$GIT_REPO" ]; then
  echo "ERROR: GIT_REPO is required"
  exit 1
fi

if [ -z "$GIT_REF" ]; then
  echo "ERROR: GIT_REF is required"
  exit 1
fi

python prepare.py \
  --num-shards "${NUM_SHARDS:-10}" \
  --download-workers "${DOWNLOAD_WORKERS:-8}"

git config --global --add safe.directory /workspace
git clone "$GIT_REPO" /workspace
cd /workspace
git checkout "$GIT_REF"

exec python train.py
