#!/usr/bin/env bash

# Catppuccin Mocha renk paleti (renk ismi → hex kodu)
# declare -A colors=(
#   [cat-mocha-blue]="#89B4FA"
#   [cat-mocha-flamingo]="#F2CDCD"
#   [cat-mocha-green]="#A6E3A1"
#   [cat-mocha-lavender]="#B4BEFE"
#   [cat-mocha-maroon]="#EBA0AC"
#   [cat-mocha-mauve]="#CBA6F7"
#   [cat-mocha-peach]="#FAB387"
#   [cat-mocha-pink]="#F5C2E7"
#   [cat-mocha-red]="#F38BA8"
#   [cat-mocha-rosewater]="#F5E0DC"
#   [cat-mocha-sapphire]="#74C7EC"
#   [cat-mocha-sky]="#89DCEB"
#   [cat-mocha-teal]="#94E2D5"
#   [cat-mocha-yellow]="#F9E2AF"
# )
# Catppuccin renk paleti (renk ismi → hex kodu)
declare -A colors=(
  # Mocha
  [cat-mocha-blue]="#89B4FA"
  [cat-mocha-flamingo]="#F2CDCD"
  [cat-mocha-green]="#A6E3A1"
  [cat-mocha-lavender]="#B4BEFE"
  [cat-mocha-maroon]="#EBA0AC"
  [cat-mocha-mauve]="#CBA6F7"
  [cat-mocha-peach]="#FAB387"
  [cat-mocha-pink]="#F5C2E7"
  [cat-mocha-red]="#F38BA8"
  [cat-mocha-rosewater]="#F5E0DC"
  [cat-mocha-sapphire]="#74C7EC"
  [cat-mocha-sky]="#89DCEB"
  [cat-mocha-teal]="#94E2D5"
  [cat-mocha-yellow]="#F9E2AF"

  # Frappe
  [cat-frappe-blue]="#8CAAEE"
  [cat-frappe-flamingo]="#F2D5CF"
  [cat-frappe-green]="#A6D189"
  [cat-frappe-lavender]="#BABBF1"
  [cat-frappe-maroon]="#E78284"
  [cat-frappe-mauve]="#CA9EE6"
  [cat-frappe-peach]="#FAC29A"
  [cat-frappe-pink]="#F4B8E4"
  [cat-frappe-red]="#E78284"
  [cat-frappe-rosewater]="#F2D5CF"
  [cat-frappe-sapphire]="#85C1DC"
  [cat-frappe-sky]="#99D1DB"
  [cat-frappe-teal]="#81C8BE"
  [cat-frappe-yellow]="#E5C890"

  # Latte
  [cat-latte-blue]="#1E66F5"
  [cat-latte-flamingo]="#DD7878"
  [cat-latte-green]="#40A02B"
  [cat-latte-lavender]="#7287FD"
  [cat-latte-maroon]="#E64553"
  [cat-latte-mauve]="#8839EF"
  [cat-latte-peach]="#FE640B"
  [cat-latte-pink]="#EA76CB"
  [cat-latte-red]="#D20F39"
  [cat-latte-rosewater]="#DC8A78"
  [cat-latte-sapphire]="#209FB5"
  [cat-latte-sky]="#04A5E5"
  [cat-latte-teal]="#179299"
  [cat-latte-yellow]="#DF8E1D"

  # Macchiato
  [cat-macchiato-blue]="#8AADF4"
  [cat-macchiato-flamingo]="#F0C6C6"
  [cat-macchiato-green]="#A6DA95"
  [cat-macchiato-lavender]="#B7BDF8"
  [cat-macchiato-maroon]="#EE99A0"
  [cat-macchiato-mauve]="#C6A0F6"
  [cat-macchiato-peach]="#F5A97F"
  [cat-macchiato-pink]="#F5BDE6"
  [cat-macchiato-red]="#ED8796"
  [cat-macchiato-rosewater]="#F4DBD6"
  [cat-macchiato-sapphire]="#7DC4E4"
  [cat-macchiato-sky]="#91D7E3"
  [cat-macchiato-teal]="#8BD5CA"
  [cat-macchiato-yellow]="#EED49F"
)

# declare -A colors=(
#   [cat-mocha-blue]="#799bd0"
#   [cat-mocha-flamingo]="#dec2c7"
#   [cat-mocha-green]="#8bba89"
#   [cat-mocha-lavender]="#a2a7c9"
#   [cat-mocha-maroon]="#c88197"
#   [cat-mocha-mauve]="#ac95c2"
#   [cat-mocha-peach]="#dfb07c"
#   [cat-mocha-pink]="#d6acc5"
#   [cat-mocha-red]="#d27782"
#   [cat-mocha-rosewater]="#e8d5d0"
#   [cat-mocha-sapphire]="#60a3bc"
#   [cat-mocha-sky]="#76b9c7"
#   [cat-mocha-teal]="#7db9aa"
#   [cat-mocha-yellow]="#dbc493"
# )

# Hex kodunu plaintext dosyadan oku
hex=$(<~/.config/matugen/papirus-folders/folder-color.txt)

# HEX'i RGB'ye çeviren fonksiyon
hex_to_rgb() {
  local hex=$1
  local r=$((16#${hex:1:2}))
  local g=$((16#${hex:3:2}))
  local b=$((16#${hex:5:2}))
  echo "$r $g $b"
}

read r1 g1 b1 <<< "$(hex_to_rgb "$hex")"

# En yakın rengi bul
min_distance=1000000
closest_color=""

for name in "${!colors[@]}"; do
  read r2 g2 b2 <<< "$(hex_to_rgb "${colors[$name]}")"
  distance=$(( (r1 - r2) * (r1 - r2) + (g1 - g2) * (g1 - g2) + (b1 - b2) * (b1 - b2) ))
  if (( distance < min_distance )); then
    min_distance=$distance
    closest_color=$name
  fi
done

echo "Closest Catppuccin Mocha color to $hex is: $closest_color"
~/.local/share/icons/papirus-folders.sh -C $closest_color -t ~/.local/share/icons/Papirus-Dark
