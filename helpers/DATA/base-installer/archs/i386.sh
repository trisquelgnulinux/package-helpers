arch_get_kernel_flavour () {
	# Should we offer an amd64 kernel?
	if grep -q '^flags.*\blm\b' "$CPUINFO"; then
		echo 686-pae amd64 686 586
	# Should we offer a PAE kernel?
	elif grep -q '^flags.*\bpae\b' "$CPUINFO"; then
		echo 686-pae 686 586
	# Should we offer a 686 kernel?
	elif grep -q '^flags.*\bfpu\b.*\btsc\b.*\bcx8\b.*\bcmov\b' "$CPUINFO"; then
		echo 686 586
	else
		echo 586
	fi
}

arch_check_usable_kernel () {
        if echo "$1" | grep -q -e "signed" -e "edge" -e "hwe-16.04"; then return 1; fi
	local NAME="$1"

	set -- $2
	while [ $# -ge 1 ]; do
		case "$1:$NAME" in
		    *-dbg)
			return 1
			;;
		    *-"$1"-pae)
			# Don't allow -pae suffix, as this requires an
			# extra CPU feature
			;;
		    *:*-"$1" | *:*-"$1"-*)
			# Allow any other hyphenated suffix
			return 0
			;;
		    686-*:*-generic | 686-*:*-generic-*)
			return 0
			;;
		    686-*:*-virtual | 686-*:*-virtual-*)
			return 0
			;;
		esac
		shift
	done
	return 1
}

arch_get_kernel () {
	imgbase="linux-image"

	set -- $1
	while [ $# -ge 1 ]; do
		case $1 in
		    686-*)
			echo "linux-generic"
			echo "linux-image-generic"
			echo "linux-virtual"
			echo "linux-image-virtual"
			break
			;;
		esac
		shift
	done
}
