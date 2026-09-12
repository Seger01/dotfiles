#!/bin/bash

set -e

package_list="$(dirname "$0")/pkglist.txt"

case "$1" in
    update)
        yay -Qqett > "$package_list"
        ;;
    install)
        yay -S --needed - < "$package_list"
        ;;
    *)
        printf 'Usage: %s {update|install}\n' "$0" >&2
        exit 1
        ;;
esac
