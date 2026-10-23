#!/bin/zsh
# Links this toolkit into ~/.claude. Anything already there is archived first, never deleted.
set -e
REPO=${0:A:h}
C=~/.claude
A=$C/_archive/$(date +%F-%H%M%S)

archive() {
  local target=$1
  [[ -L $target ]] && { rm "$target"; return; }
  [[ -e $target ]] || return 0
  local dest=$A/${${target:h}#$C}
  mkdir -p "$dest"
  mv "$target" "$dest/"
}

link() {
  archive "$2"
  ln -s "$1" "$2"
  echo "linked  ${2/#$HOME/~}"
}

mkdir -p $C/skills

# First install only: archive pieces of the older setup that this toolkit replaces.
if [[ ! -e $C/.claude-flow-installed ]]; then
  for old in prompts drafts README.md plans; do archive $C/$old; done
  archive $C/skills/work
  touch $C/.claude-flow-installed
fi
mkdir -p $C/plans

link $REPO/CLAUDE.md     $C/CLAUDE.md
link $REPO/settings.json $C/settings.json
link $REPO/commands      $C/commands
link $REPO/notes         $C/notes
link $REPO/hooks         $C/hooks
for s in $REPO/skills/*(/); do link $s $C/skills/${s:t}; done

# The flow log is personal, so it lives in the private claude-notes repo next to this one.
NOTES=${REPO:h}/claude-notes
[[ -d $NOTES ]] || git clone -q git@github.com:Akram11/claude-notes.git $NOTES
ln -sfn $NOTES/ai-flow-log.md $REPO/notes/ai-flow-log.md
echo "linked  notes/ai-flow-log.md -> ${NOTES/#$HOME/~}"

[[ -d $A ]] && echo "archived old files to ${A/#$HOME/~}"
echo "done"
