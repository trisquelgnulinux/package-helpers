arch_get_kernel_flavour () {
	echo amd64
}

arch_check_usable_kernel () {
	if echo "$1" | grep -q -e "signed" -e "edge" -e "hwe-@REVISION@"; then return 1; fi
	if echo "$1" | grep -Eq -- "-(server|generic|virtual|xen|preempt|rt)(-.*)?$"; then return 0; fi

	return 1
}

arch_get_kernel () {

	echo "linux-generic"
	echo "linux-image-generic"

	echo "linux-generic-hwe-@REVISION@"
	echo "linux-image-generic-hwe-@REVISION@"

        echo "linux-lowlatency"
        echo "linux-image-lowlatency"

        echo "linux-lowlatency-hwe-@REVISION@"
        echo "linux-image-lowlatency-hwe-@REVISION@"

        echo "linux-oem-@REVISION@"
        echo "linux-image-oem-@REVISION@"

        echo "linux-virtual"
        echo "linux-image-virtual"

        echo "linux-image-extra-virtual"
	echo "linux-virtual-hwe-@REVISION@"

	echo "linux-image-virtual-hwe-@REVISION@"
	echo "linux-image-extra-virtual-hwe-@REVISION@"
}
