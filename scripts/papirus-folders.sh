#!/usr/bin/env bash
# This script lets you change the colors of folders in the Papirus icon theme
#
# @author: Sergei Eremenko (https://github.com/SmartFinn)
# @license: MIT license (MIT)
# @link: https://github.com/PapirusDevelopmentTeam/papirus-folders

if test -z "$BASH_VERSION"; then
	printf "Error: this script only works in bash.\n" >&2
	exit 1
fi

if (( BASH_VERSINFO[0] * 10 + BASH_VERSINFO[1] < 40 )); then
	printf "Error: this script requires bash version >= 4.0\n" >&2
	exit 1
fi

# set -x  # Uncomment to debug this shell script
set -o errexit \
	-o noclobber \
	-o pipefail

readonly THIS_SCRIPT="$(readlink -f "${BASH_SOURCE[0]}")"
readonly PROGNAME="$(basename "${BASH_SOURCE[0]}")"
readonly VERSION="1.14.0"
readonly -a ARGS=("$@")

msg() {
	printf "%s: %b\n" "$PROGNAME" "$*"
}

verbose() {
	[ -t 4 ] || return 0
	msg "$@" >&4
}

err() {
	msg "Error:" "$*" >&2
}

_exit() {
	msg "$*" "Exiting ..."
	exit 0
}

fatal() {
	err "$*"
	exit 1
}

usage() {
	cat <<- EOF
	USAGE
	  $ $PROGNAME [options] -t <theme> {-C --color} <color>
	  $ $PROGNAME [options] -t <theme> {-D --default}
	  $ $PROGNAME [options] -t <theme> {-R --restore}

	OPERATIONS
	  -C --color <color>  change color of folders (supports named colors or hex codes)
	  -D --default        back to the default color
	  -R --restore        restore the last used color from the config file

	OPTIONS
	  -l --list           show available colors
	  -o --once           do not save the changes to the config file
	  -p --png            convert custom SVG files to PNG for faster loading
	  -t --theme <theme>  make changes to the specified theme (Default: Papirus)
	  -u --update-caches  update icon caches for Papirus and siblings
	  -V --version        print $PROGNAME version and exit
	  -v --verbose        be verbose
	  -h --help           show this help

	EXAMPLES
	  $ $PROGNAME -C blue                    # Use predefined blue color
	  $ $PROGNAME -C '#FF5733'               # Use custom hex color (with quotes)
	  $ $PROGNAME -C FF5733                  # Use custom hex color (without #)
	  $ $PROGNAME -C '#FF5733' -p -u         # Custom color + PNG conversion + cache update
	EOF

	exit "${1:-0}"
}

_is_root_user() {
	if [ "$(id -u)" -eq 0 ]; then
		return 0
	fi

	return 1
}

_is_user_dir() {
	[ -n "$USER_HOME" ] || return 1

	# if $THEME_DIR is placed in home dir
	if [ -z "${THEME_DIR##"$USER_HOME"/*}" ]; then
		return 0
	fi

	return 1
}

_is_writable() {
	if [ -w "$THEME_DIR/48x48/places/folder.svg" ]; then
		return 0
	fi

	return 1
}

_is_valid_color() {
	local color="$1"

	# Check if it's a hex color code
	if _is_hex_color "$color"; then
		return 0
	fi

	eval "$(declare_colors)"

	for i in "${colors[@]}"; do
		[ "$i" == "$color" ] || continue
		return 0
	done

	return 1
}

_is_hex_color() {
	local color="$1"
	# Match hex color with or without # prefix (e.g., #FF5733 or FF5733)
	if [[ "$color" =~ ^#?[0-9A-Fa-f]{6}$ ]]; then
		return 0
	fi
	return 1
}

declare_colors() {
	local -a colors=()

	for f in "$THEME_DIR/48x48/places/folder-"*"-documents.svg"; do
		[ -e "$f" ] || continue

		# Extract color from the path
		if [[ $f =~ .*/folder-(.+)-documents.svg ]]; then
			colors=( "${colors[@]}" "${BASH_REMATCH[1]}" )
		fi
	done

	# return array of colors
	declare -p colors
}

declare_current_color() {
	local icon_file icon_name current_color=''

	icon_file=$(readlink -f "$THEME_DIR/48x48/places/folder.svg")
	icon_name=$(basename "$icon_file" .svg)
	current_color="${icon_name##*-}"

	declare -p current_color
}

get_theme_dir() {
	local data_dir icons_dir
	local -a data_dirs=()
	local -a icons_dirs=(
		"$USER_HOME/.icons"
		"${XDG_DATA_HOME:-$USER_HOME/.local/share}/icons"
	)

	# Get data directories from XDG_DATA_DIRS variable and
	# convert colon-separated list into bash array
	IFS=: read -ra data_dirs <<< "${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"

	for data_dir in "${data_dirs[@]}"; do
		[ -d "$data_dir/icons" ] || continue
		icons_dirs=( "${icons_dirs[@]}" "${data_dir%/}/icons" )
	done

	for icons_dir in "${icons_dirs[@]}"; do
		[ -f "$icons_dir/$THEME_NAME/index.theme" ] || continue
		printf '%s' "$icons_dir/$THEME_NAME"
		verbose "'$THEME_NAME' is found in '$icons_dir'."
		return 0
	done

	return 1
}

get_real_user() {
	# return name of the user that runs the script
	local user=''

	if [ -n "$PKEXEC_UID" ]; then
		user="$(id -nu "$PKEXEC_UID")"
	elif [ -n "$SUDO_USER" ]; then
		user="$SUDO_USER"
	else
		user="$(id -nu)"
	fi

	printf '%s' "$user"
}

get_user_home() {
	local user="$1"

	getent passwd "$user" | awk -F: '{print $(NF-1)}'
}

config() {
	# usage: config [{-n --new}] {-s --set} key=value... | {-g --get} key...
	local config_dir
	local config_file

	if _is_user_dir; then
		config_dir="${XDG_CONFIG_HOME:-$USER_HOME/.config}/$PROGNAME"
	else
		config_dir="/var/lib/$PROGNAME"
	fi

	config_file="$config_dir/keep"

	while (( "$#" )); do
		case "$1" in
			-g|--get) shift;
				[ -f "$config_file" ] || return 1

				for key; do
					[ -n "$key" ] || continue
					awk -F= -v key="$key" '
					$1 == key {
						print $2
						exit
					}
					' "$config_file"
				done

				break
				;;
			-n|--new) shift;
				rm -f "$config_file"
				;;
			-e|--exists) shift;
				# return 1 if test config_file not exist or empty
				if [ -f "$config_file" ] && [ -s "$config_file" ]; then
					return 0
				else
					return 1
				fi
				;;
			-s|--set) shift;
				[ "$ONCE" -eq "1" ] && break
				[ -d "$config_dir"  ] || mkdir -p "$config_dir"
				[ -f "$config_file" ] || touch "$config_file"

				verbose "Saving params to '$config_file' ..."
				cat >> "$config_file" <<- EOF
				$(for key_value; do echo "$key_value"; done)
				EOF

				break
				;;
			*)
				err "illegal option -- '$1'"
				return 1
		esac
	done

	return 0
}

change_color() {
	local color="${1:?${FUNCNAME[-1]}: color is not set}"
	local size prefix file_path file_name symlink_path
	local -a sizes=(22x22 24x24 32x32 48x48 64x64)
	local -a prefixes=("folder-$color" "user-$color")

	# Check if this is a custom hex color
	if _is_hex_color "$color"; then
		create_custom_color_files "$color"
		return 0
	fi

	for size in "${sizes[@]}"; do
		for prefix in "${prefixes[@]}"; do
			for file_path in "$THEME_DIR/$size/places/$prefix"{-*,}.svg; do
				[ -f "$file_path" ] || continue  # is a file
				[ -L "$file_path" ] && continue  # is not a symlink

				file_name="${file_path##*/}"
				symlink_path="${file_path/-$color/}"  # remove color suffix

				ln -sf "$file_name" "$symlink_path" || {
					fatal "Fail to create '$symlink_path' symlink"
				}
			done
		done
	done
}

create_custom_color_files() {
	local target_color="$1"
	local base_color="blue"  # Use blue as the reference
	local size file_path target_path temp_svg real_file
	local -a sizes=(22x22 24x24 32x32 48x48 64x64)
	
	# Normalize hex color (ensure it has # prefix)
	[[ "$target_color" =~ ^# ]] || target_color="#$target_color"
	
	# Convert hex to uppercase for consistency
	target_color=$(echo "$target_color" | tr '[:lower:]' '[:upper:]')
	
	msg "Creating custom color files from hex: $target_color"
	
	# Clean up any existing custom files first
	verbose "Removing old custom color files..."
	for size in "${sizes[@]}"; do
		rm -f "$THEME_DIR/$size/places/folder-custom"*.svg 2>/dev/null || true
		rm -f "$THEME_DIR/$size/places/user-custom"*.svg 2>/dev/null || true
	done
	
	# Find a real SVG file to extract colors from (follow symlinks)
	local base_svg="$THEME_DIR/48x48/places/folder-$base_color.svg"
	if [ -L "$base_svg" ]; then
		base_svg=$(readlink -f "$base_svg")
	fi
	[ -f "$base_svg" ] || fatal "Base template file not found: $base_svg"
	
	verbose "Using template: $base_svg"
	
	# Extract the three main colors from folder SVG
	local color1 color2 color3
	color1=$(grep -oP 'fill:#[0-9A-Fa-f]{6}' "$base_svg" | head -n1 | cut -d: -f2)
	color2=$(grep -oP 'fill:#[0-9A-Fa-f]{6}' "$base_svg" | head -n2 | tail -n1 | cut -d: -f2)
	color3=$(grep -oP 'fill:#[0-9A-Fa-f]{6}' "$base_svg" | head -n3 | tail -n1 | cut -d: -f2)
	
	verbose "Extracted base colors: $color1, $color2, $color3"
	
	# Calculate lighter and darker shades of target color
	local light_color dark_color
	light_color=$(adjust_hex_brightness "$target_color" 30)
	dark_color=$(adjust_hex_brightness "$target_color" -15)
	
	verbose "Generated shades - Light: $light_color, Main: $target_color, Dark: $dark_color"
	
	# Process each size
	for size in "${sizes[@]}"; do
		verbose "Processing size: $size"
		for file_path in "$THEME_DIR/$size/places/folder-$base_color"{-*,}.svg; do
			[ -e "$file_path" ] || continue
			
			# Follow symlinks to get the real file
			real_file="$file_path"
			if [ -L "$file_path" ]; then
				real_file=$(readlink -f "$file_path")
			fi
			
			# Skip if not a regular file
			[ -f "$real_file" ] || continue
			
			file_name="${file_path##*/}"
			target_path="${file_path/$base_color/custom}"
			
			# Create recolored version (using >| to force overwrite if needed)
			sed -e "s/$color1/$light_color/gI" \
			    -e "s/$color2/$target_color/gI" \
			    -e "s/$color3/$dark_color/gI" \
			    "$real_file" >| "$target_path"
			
			verbose "Created: $target_path"
		done
		
		# Also process user- prefixed files
		for file_path in "$THEME_DIR/$size/places/user-$base_color"{-*,}.svg; do
			[ -e "$file_path" ] || continue
			
			# Follow symlinks to get the real file
			real_file="$file_path"
			if [ -L "$file_path" ]; then
				real_file=$(readlink -f "$file_path")
			fi
			
			# Skip if not a regular file
			[ -f "$real_file" ] || continue
			
			file_name="${file_path##*/}"
			target_path="${file_path/$base_color/custom}"
			
			sed -e "s/$color1/$light_color/gI" \
			    -e "s/$color2/$target_color/gI" \
			    -e "s/$color3/$dark_color/gI" \
			    "$real_file" >| "$target_path"
			
			verbose "Created: $target_path"
		done
	done
	
	# Now create symlinks to the custom files
	for size in "${sizes[@]}"; do
		for file_path in "$THEME_DIR/$size/places/folder-custom"{-*,}.svg; do
			[ -f "$file_path" ] || continue
			
			file_name="${file_path##*/}"
			symlink_path="${file_path/-custom/}"
			
			ln -sf "$file_name" "$symlink_path" || {
				fatal "Fail to create '$symlink_path' symlink"
			}
		done
		
		for file_path in "$THEME_DIR/$size/places/user-custom"{-*,}.svg; do
			[ -f "$file_path" ] || continue
			
			file_name="${file_path##*/}"
			symlink_path="${file_path/-custom/}"
			
			ln -sf "$file_name" "$symlink_path" || {
				fatal "Fail to create '$symlink_path' symlink"
			}
		done
	done
	
	# Convert to PNG if requested
	if [ "$CONVERT_PNG" -eq 1 ]; then
		convert_custom_to_png
	fi
}

adjust_hex_brightness() {
	local hex="$1"
	local adjust="$2"
	
	# Remove # if present
	hex="${hex#\#}"
	
	# Extract RGB components
	local r=$((16#${hex:0:2}))
	local g=$((16#${hex:2:2}))
	local b=$((16#${hex:4:2}))
	
	# Adjust brightness
	r=$((r + adjust))
	g=$((g + adjust))
	b=$((b + adjust))
	
	# Clamp values to 0-255
	[ $r -lt 0 ] && r=0
	[ $r -gt 255 ] && r=255
	[ $g -lt 0 ] && g=0
	[ $g -gt 255 ] && g=255
	[ $b -lt 0 ] && b=0
	[ $b -gt 255 ] && b=255
	
	# Convert back to hex
	printf "#%02X%02X%02X" "$r" "$g" "$b"
}

bake_to_png() {
	local svg_file="$1"
	local png_file="${svg_file%.svg}.png"
	local size="${2:-48}"
	
	# Check if we have rsvg-convert (preferred) or imagemagick
	if command -v rsvg-convert >/dev/null 2>&1; then
		rsvg-convert -w "$size" -h "$size" "$svg_file" -o "$png_file" 2>/dev/null || true
		return 0
	elif command -v convert >/dev/null 2>&1; then
		convert -background none -size "${size}x${size}" "$svg_file" "$png_file" 2>/dev/null || true
		return 0
	else
		verbose "Warning: Neither rsvg-convert nor ImageMagick found. Skipping PNG conversion."
		return 1
	fi
}

convert_custom_to_png() {
	local size size_num
	local -a sizes=(22x22 24x24 32x32 48x48 64x64)
	local -a size_nums=(22 24 32 48 64)
	local count=0
	
	msg "Converting custom SVG files to PNG for faster loading..."
	
	for i in "${!sizes[@]}"; do
		size="${sizes[$i]}"
		size_num="${size_nums[$i]}"
		
		verbose "Converting $size icons..."
		
		# Convert folder-custom files
		for svg_file in "$THEME_DIR/$size/places/folder-custom"*.svg; do
			[ -f "$svg_file" ] || continue
			[ -L "$svg_file" ] && continue  # Skip symlinks
			
			if bake_to_png "$svg_file" "$size_num"; then
				((count++)) || true
				verbose "  ✓ $(basename "$svg_file")"
			fi
		done
		
		# Convert user-custom files
		for svg_file in "$THEME_DIR/$size/places/user-custom"*.svg; do
			[ -f "$svg_file" ] || continue
			[ -L "$svg_file" ] && continue  # Skip symlinks
			
			if bake_to_png "$svg_file" "$size_num"; then
				((count++)) || true
				verbose "  ✓ $(basename "$svg_file")"
			fi
		done
	done
	
	msg "Converted $count SVG files to PNG format."
}

list_colors() {
	local color='' prefix=''

	eval "$(declare_colors)"
	eval "$(declare_current_color)"

	for color in "${colors[@]}"; do
		if [ "$current_color" == "$color" ]; then
			prefix='>'
		else
			prefix=''
		fi

		printf '%2s %s\n' "$prefix" "$color"
	done
}

do_change_color() {
	_is_valid_color "$SELECTED_COLOR" || {
		fatal "Unable to find '$SELECTED_COLOR' color in '$THEME_NAME'"
	}

	verify_privileges

	msg "Changing color of folders to '$SELECTED_COLOR' for '$THEME_NAME' ..."
	change_color "$SELECTED_COLOR"
	config --new --set "theme=$THEME_NAME" "color=$SELECTED_COLOR"

	case "$THEME_NAME" in
		Papirus-Dark|Papirus-Light)
			update_icon_caches
			;;
		*)
			update_icon_cache
			;;
	esac
}

do_revert_default() {
	verify_privileges

	msg "Restoring default folder color for '$THEME_NAME' ..."
	change_color "${DEFAULT_COLORS[$THEME_NAME]:-blue}"
	config --new

	case "$THEME_NAME" in
		Papirus-Dark|Papirus-Light)
			update_icon_caches
			;;
		*)
			update_icon_cache
			;;
	esac
}

do_restore_color() {
	local saved_color=''

	if config --exists; then
		THEME_NAME="$(config --get theme)"
		saved_color="$(config --get color)"
	else
		_exit "Unable to find config file."
	fi

	THEME_DIR="$(get_theme_dir)" || {
		_exit "Unable to find '$THEME_NAME' icon theme."
	}

	_is_valid_color "$saved_color" || {
		_exit "Unable to find '$saved_color' color in '$THEME_NAME'."
	}

	verify_privileges

	change_color "$saved_color"
	msg "'$saved_color' color of the folders has been restored."
}

delete_icon_caches() {
	local icon_cache real_user='' real_home=''

	real_user="$(get_real_user)"
	real_home="$(get_user_home "$real_user")"

	declare -a icon_caches=(
		# KDE 5 icon caches
		"$real_home/.cache/icon-cache.kcache"
		"/var/tmp/kdecache-$real_user/icon-cache.kcache"
	)

	verbose "Deleting icon caches ..."
	for icon_cache in "${icon_caches[@]}"; do
		[ -e "$icon_cache" ] || continue
		rm -f "$icon_cache"
	done
}

update_icon_cache() {
	[ -z "$DISABLE_UPDATE_ICON_CACHE" ] || return 0

	delete_icon_caches

	verbose "Rebuilding icon cache for '$THEME_NAME' ..."
	gtk-update-icon-cache -qf "$THEME_DIR" || true
}

update_icon_caches() {
	local theme=''

	delete_icon_caches

	for theme in "${!DEFAULT_COLORS[@]}"; do
		[ -f "$THEME_DIR/../$theme/index.theme" ] || continue
		verbose "Rebuilding icon cache for '$theme' ..."
		gtk-update-icon-cache -qf "$THEME_DIR/../$theme" || true
	done
}

verify_privileges() {
	_is_root_user && return 0
	_is_user_dir  && return 0
	_is_writable  && return 0

	verbose "This operation requires root privileges."

	if command -v sudo > /dev/null; then
		exec sudo USER_HOME="$USER_HOME" XDG_DATA_DIRS="$XDG_DATA_DIRS" \
			"$THIS_SCRIPT" "${ARGS[@]}"
	else
		fatal "You need to be root to run this command."
	fi
}

parse_args() {
	local arg='' opt=''
	local -a args=()

	# Show help if no argument is passed
	if [ -z "$1" ]; then
		usage 2
	fi

	# Translate --gnu-long-options to -g (short options)
	for arg; do
		case "$arg" in
			--help)           args+=( -h ) ;;
			--list)           args+=( -l ) ;;
			--once)           args+=( -o ) ;;
			--png)            args+=( -p ) ;;
			--theme)          args+=( -t ) ;;
			--update-caches)  args+=( -u ) ;;
			--verbose)        args+=( -v ) ;;
			--color|--colour) args+=( -C ) ;;
			--default)        args+=( -D ) ;;
			--restore)        args+=( -R ) ;;
			--version)        args+=( -V ) ;;
			--[0-9a-zA-Z]*)
				err "illegal option -- '$arg'"
				usage 2
				;;
			*) args+=("$arg")
		esac
	done

	# Reset the positional parameters to the short options
	set -- "${args[@]}"

	while getopts ":C:DRlopt:uvVh" opt; do
		case "$opt" in
			C ) OPERATIONS+=("change-color")
				SELECTED_COLOR="$OPTARG"
				;;
			D ) OPERATIONS+=("revert-default") ;;
			R ) OPERATIONS+=("restore-color") ;;
			l ) OPERATIONS+=("list-colors") ;;
			o ) ONCE=1 ;;
			p ) CONVERT_PNG=1 ;;
			t ) THEME_NAME="$OPTARG" ;;
			u ) OPERATIONS+=("update-icon-caches") ;;
			v ) VERBOSE=1 ;;
			V ) printf "%s %s\n" "$PROGNAME" "$VERSION"
				exit 0
				;;
			h ) usage 0 ;;
			: ) err "option requires an argument -- '-$OPTARG'"
				usage 2
				;;
			\?) err "illegal option -- '-$OPTARG'"
				usage 2
				;;
		esac
	done

	shift $((OPTIND-1))

	# Return an error if any positional parameters are found
	if [ -n "$1" ]; then
		err "illegal parameter -- '$1'"
		usage 2
	fi
}

main() {
	# default values of options
	declare THEME_NAME="${THEME_NAME:-Papirus}"
	declare -i VERBOSE="${VERBOSE:-0}"
	declare -i ONCE="${ONCE:-0}"
	declare -i CONVERT_PNG="${CONVERT_PNG:-0}"
	declare -A DEFAULT_COLORS=(
		['Papirus']='blue'
		['Papirus-Dark']='blue'
		['Papirus-Light']='blue'
	)

	declare SELECTED_COLOR=''
	declare -a OPERATIONS=()

	parse_args "${ARGS[@]}"

	if [ "$VERBOSE" -eq "1" ]; then
		# open a file descriptor for verbose messages
		exec 4>&1
		# close the file descriptor before exiting
		trap 'exec 4>&-' EXIT HUP INT TERM
	fi

	# set USER_HOME variable instead HOME to prevent changing user's icons
	# when running with sudo
	[ -n "$USER_HOME" ] || USER_HOME="$(get_user_home "$(id -nu)")"

	if [ -f "$THEME_NAME/index.theme" ]; then
		# THEME_NAME is a path to an icon theme
		THEME_DIR="$(readlink -f "$THEME_NAME")"
		THEME_NAME="$(basename "$THEME_DIR")"
		verbose "The path to '$THEME_DIR' theme is specified."
	else
		THEME_DIR="$(get_theme_dir)" || {
			fatal "Fail to find '$THEME_NAME' icon theme."
		}
	fi

	for operation in "${OPERATIONS[@]}"; do
		case "$operation" in
			change-color)
				do_change_color
				;;
			revert-default)
				do_revert_default
				;;
			restore-color)
				do_restore_color
				;;
			list-colors)
				if [ -t 1 ]; then
					cat <<- EOF
					List of available colors:

					$(list_colors)

					EOF
				else
					list_colors
				fi
				;;
			update-icon-caches)
				verify_privileges
				update_icon_caches
				;;
		esac
	done

	verbose "Done!"

	exit 0
}

main

exit 1
