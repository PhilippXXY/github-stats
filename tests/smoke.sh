#!/usr/bin/env bash
set -euo pipefail

output_dir=$(mktemp -d)
trap 'rm -rf "$output_dir"' EXIT

./zig-out/bin/github-stats --json-input-file tests/stats.json \
  --overview-output-file "$output_dir/overview.svg" \
  --languages-output-file "$output_dir/languages.svg" --silent

grep -Fq 'Example User' "$output_dir/overview.svg"
grep -Fq '1,234' "$output_dir/overview.svg"
grep -Fq '5,678' "$output_dir/overview.svg"
grep -Fq '100.00%' "$output_dir/languages.svg"
grep -Fq '>Zig</span>' "$output_dir/languages.svg"
if grep -Fq '{{' "$output_dir/overview.svg" "$output_dir/languages.svg"; then
  echo 'Unresolved placeholders in generated images.' >&2
  exit 1
fi

./zig-out/bin/github-stats --json-input-file tests/stats.json \
  --exclude-repos 'example/*' \
  --overview-output-file "$output_dir/overview.svg" \
  --languages-output-file "$output_dir/languages.svg" --silent

test -s "$output_dir/overview.svg"
test -s "$output_dir/languages.svg"
if grep -Eq '\{\{|1,234|>Zig</span>' "$output_dir/overview.svg" "$output_dir/languages.svg"; then
  echo 'Excluded statistics or unresolved placeholders in generated images.' >&2
  exit 1
fi
