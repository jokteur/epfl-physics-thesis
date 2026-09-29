#!/usr/bin/env bash
# Install the two packages as @local/<name>:<version>.
#
# By default they are symlinked, so editing packages/<name>/src/*.typ takes
# effect on the next compile. Pass --copy to copy them instead.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname -s)" in
  Darwin) root="$HOME/Library/Application Support/typst/packages/local" ;;
  *)      root="${XDG_DATA_HOME:-$HOME/.local/share}/typst/packages/local" ;;
esac

mode="link"
[ "${1:-}" = "--copy" ] && mode="copy"

install_one() {
  local dir="$1"
  local name version target
  name=$(sed -n 's/^name *= *"\(.*\)"/\1/p' "$dir/typst.toml" | head -1)
  version=$(sed -n 's/^version *= *"\(.*\)"/\1/p' "$dir/typst.toml" | head -1)
  target="$root/$name/$version"

  mkdir -p "$(dirname "$target")"
  rm -rf "$target"
  if [ "$mode" = "link" ]; then
    ln -s "$dir" "$target"
    echo "linked  @local/$name:$version -> $dir"
  else
    cp -R "$dir" "$target"
    echo "copied  @local/$name:$version"
  fi
}

for pkg in "$here"/packages/*/; do
  install_one "${pkg%/}"
done

echo
echo "Now compile the example:"
echo "  typst compile $here/example/main.typ"
