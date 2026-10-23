#!/bin/zsh
# PreToolUse hook: before Claude runs `git push`, run the project's type-check, lint and tests.
# Exit 2 blocks the push and shows the failure to Claude. Non-JS projects pass through.
input=$(cat)
cmd=$(jq -r '.tool_input.command // ""' <<<"$input")
[[ $cmd =~ '(^|[;&|[:space:]])git[[:space:]]+push' ]] || exit 0

cd "$(jq -r '.cwd // "."' <<<"$input")" || exit 0
root=$(git rev-parse --show-toplevel 2>/dev/null) && cd "$root"
[[ -f package.json ]] || exit 0

if   [[ -f bun.lock || -f bun.lockb ]]; then run=(bun run)
elif [[ -f pnpm-lock.yaml ]];           then run=(pnpm run)
elif [[ -f yarn.lock ]];                then run=(yarn)
else                                         run=(npm run --silent)
fi

script_for() {
  for name in "$@"; do
    jq -e --arg n "$name" '.scripts[$n]' package.json >/dev/null && { echo $name; return; }
  done
}

checks=()
tc=$(script_for typecheck type-check tsc types)
if [[ -n $tc ]]; then checks+=("$run $tc")
elif [[ -f tsconfig.json && -x node_modules/.bin/tsc ]]; then checks+=("node_modules/.bin/tsc --noEmit")
fi
lint=$(script_for lint);  [[ -n $lint ]] && checks+=("$run $lint")
test=$(script_for test);  [[ -n $test ]] && checks+=("$run $test")

failed=0
for c in $checks; do
  out=$(CI=true eval "$c" 2>&1) || { failed=1; print -u2 "✗ $c\n$(tail -30 <<<"$out")\n"; }
done

(( failed )) && { print -u2 "Push blocked: fix the failures above, then push again."; exit 2; }
exit 0
