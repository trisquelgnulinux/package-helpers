arch_get_kernel_flavour () {
	echo amd64
}

arch_check_usable_kernel () {
	if echo "$1" | grep -q -e "signed" -e "edge" -e "hwe-16.04"; then return 1; fi
	if echo "$1" | grep -Eq -- "-(server|generic|virtual|xen|preempt|rt)(-.*)?$"; then return 0; fi

	return 1
}

arch_get_kernel () {

	echo "linux-generic"
	echo "linux-image-generic"

	echo "linux-server"
	echo "linux-image-server"

	echo "linux-virtual"
	echo "linux-image-virtual"

	echo "linux-xen"
	echo "linux-image-xen"

	echo "linux-preempt"
	echo "linux-image-preempt"

	echo "linux-rt"
	echo "linux-image-rt"
}
