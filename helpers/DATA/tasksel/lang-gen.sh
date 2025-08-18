#!/bin/sh
set -e

# Args:
#  $1 = LANGS_DESC (lista de códigos crudos)
#  $2 = L10N_PKGS  (familias base: language-pack, -gnome, hunspell, hyphen, mythes)
#  $3 = destino (directorio trisquel-tasks)

raw_langs="$1"
families="$2"
dest="$3"

canon() {
  case "$1" in
    pt_BR)  echo pt ;;
    zh_CN)  echo zh-hans ;;
    zh_TW)  echo zh-hant ;;
    *)      echo "${1%%_*}" ;;
  esac
}

have_pkg() { apt-cache show "$1" >/dev/null 2>&1; }

mkdir -p "$dest"

# de-dup
uniq_langs=$(for l in $raw_langs; do canon "$l"; done | tr ' ' '\n' | sort -u)

for lang in $uniq_langs; do
  base="language-pack-$lang"
  if ! have_pkg "$base"; then
    echo "skip: $lang (no $base)" >&2
    continue
  fi
  f="$dest/l10n-$lang"
  {
    echo "Task: $lang"
    echo "Description: $lang environment"
    echo " This task localises the desktop in $lang."
    echo "Key:"
    echo " $base"
    echo "Packages: list"
    for fam in $families; do
      echo " ${fam}-${lang}"
    done
    echo "Section: l10n"
    echo "Test-lang: $lang"
    echo
  } > "$f"
done
