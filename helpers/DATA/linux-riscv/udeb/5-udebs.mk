# Avoid running udeb if the current architecture is not defined in kernel-versions
ifneq ($(arch),)
  ifeq ($(shell grep -c '^$(arch)[[:space:]]' $(DEBIAN)/d-i/kernel-versions 2>/dev/null),0)
    disable_d_i := true
  endif
endif

# Do udebs if not disabled in the arch-specific makefile
binary-udebs: binary-debs
	@echo Debug: $@
ifeq ($(disable_d_i),)
	@$(MAKE) --no-print-directory -f debian/rules DEBIAN=$(DEBIAN) \
		do-binary-udebs
endif

# Hook into Ubuntu's architecture build process without modifying their files
binary-arch: binary-udebs

# Prefer DEB_SOURCE when available; fallback to src_pkg_name; otherwise "linux"
do-binary-udebs: linux_udeb_name=$(if $(DEB_SOURCE),$(DEB_SOURCE),$(if $(src_pkg_name),$(src_pkg_name),linux))
do-binary-udebs: debian/control
	@echo Debug: $@
	dh_testdir
	dh_testroot

	# unpack the kernels into a temporary directory
	mkdir -p debian/d-i-${arch}

	outdir="$${DPKG_BUILDPACKAGE_OUTPUT_DIR:-..}" && \
	imagelist=$$(cat $(CURDIR)/$(DEBIAN)/d-i/kernel-versions | grep ^${arch} | gawk '{print $$3}') && \
	for flavour in $$imagelist; do \
	  i=$(or $(DEB_VERSION_UPSTREAM),$(release))-$(abinum)-$$flavour; \
	  found=0; \
	  for deb in \
	    "$$outdir"/linux-image-$$i\_*_${arch}.deb \
	    "$$outdir"/linux-image-unsigned-$$i\_*_${arch}.deb \
	    "$$outdir"/linux-modules-$$i\_*_${arch}.deb \
	    "$$outdir"/linux-modules-extra-$$i\_*_${arch}.deb; \
	  do \
	      if [ -f "$$deb" ]; then \
	        found=1; \
	        dpkg -x "$$deb" debian/d-i-${arch}; \
	      fi; \
	  done; \
	  if [ "$$found" = 0 ]; then \
	    echo "E: missing .deb for $$i in $$outdir (DPKG_BUILDPACKAGE_OUTPUT_DIR)." >&2; \
	    ls -1 "$$outdir"/linux-image-$$i\_*_${arch}.deb \
	          "$$outdir"/linux-image-unsigned-$$i\_*_${arch}.deb \
	          "$$outdir"/linux-modules-$$i\_*_${arch}.deb \
	          "$$outdir"/linux-modules-extra-$$i\_*_${arch}.deb 2>/dev/null >&2 || true; \
	    exit 1; \
	  fi; \
	  rm -rf debian/d-i-${arch}/DEBIAN; \
	  if [ ! -e debian/d-i-${arch}/lib/modules ] && [ -d debian/d-i-${arch}/usr/lib/modules ]; then \
	    mkdir -p debian/d-i-${arch}/lib; \
	    ln -s ../usr/lib/modules debian/d-i-${arch}/lib/modules; \
	  fi; \
	  if [ ! -d debian/d-i-${arch}/lib/modules/$$i ]; then \
	    echo "E: missing debian/d-i-${arch}/lib/modules/$$i" >&2; \
	    exit 1; \
	  fi; \
	  /sbin/depmod -b debian/d-i-${arch} -- $$i; \
	  if [ "$(filter true,$(do_dtbs))" ]; then \
	    if [ -d debian/d-i-${arch}/lib/firmware/$$i/device-tree ]; then \
	      echo ">> Trisquel: Extracting dtbs for $$i..."; \
	      mkdir -p $(CURDIR)/$(DEBIAN)/d-i/firmware/${arch}; \
	      ( cd debian/d-i-${arch}/lib/firmware/$$i/ && find device-tree -print 2>/dev/null || true ) | \
	      while read dtb_file; do \
	        echo "$$dtb_file ?" >> $(CURDIR)/$(DEBIAN)/d-i/firmware/${arch}/kernel-image; \
	      done; \
	    fi; \
	  fi; \
	done

	# kernel-wedge will error if no modules unless this is touched
	touch $(DEBIAN)/d-i/no-modules

	touch $(CURDIR)/$(DEBIAN)/d-i/ignore-dups
	export KW_DEFCONFIG_DIR=$(CURDIR)/$(DEBIAN)/d-i && \
	export KW_CONFIG_DIR=$(CURDIR)/$(DEBIAN)/d-i && \
	export SOURCEDIR=$(CURDIR)/debian/d-i-${arch} && \
	  kernel-wedge install-files $(DEB_VERSION_UPSTREAM)-$(abinum) && \
	  for pkg in $$(dh_listpackages -a 2>/dev/null); do mkdir -p debian/$$pkg; done && \
	  kernel-wedge check || true # TODO: # Prevent build failure due to upstream Debian/Ubuntu d-i modules desyncs

	# Build just the udebs
	dilist=$$(dh_listpackages -a | grep "\-di$$") && \
	[ -z "$$dilist" ] || \
	for i in $$dilist; do \
	  dh_fixperms -p$$i; \
	  $(lockme) dh_gencontrol -p$$i; \
	  dh_builddeb -p$$i; \
	done

	# Generate the meta-udeb dependancy lists.
	mkdir -p $(builddir)
	touch $(builddir)/udeb-meta-packages.list
	@gawk ' \
	    /^Package:/ { \
	        package=$$2; flavour=""; match_arch=0 } \
	    (/Package-Type: udeb/ && package !~ /^$(linux_udeb_name)-udebs-/) { \
	        match(package, "$(DEB_VERSION_UPSTREAM)-$(abinum)-(.*)-di", bits); \
	        flavour = bits[1]; \
	    } \
	    /^Architecture:/ { \
	        match_arch=0; \
	        for (i=2; i<=NF; i++) if ($$i=="$(arch)") match_arch=1; \
	    } \
	    (flavour != "" && match_arch) { \
	        udebs[flavour] = udebs[flavour] package ", "; \
	        flavour=""; match_arch=0; \
	    } \
	    END { \
	        for (flavour in udebs) { \
	            package="$(linux_udeb_name)-udebs-" flavour; \
	            file="debian/" package ".substvars"; \
	            print("udeb:Depends=" udebs[flavour]) > file; \
	            metas="$(builddir)/udeb-meta-packages.list"; \
	            print(package) >>metas \
	        } \
	    } \
	' <$(CURDIR)/debian/control
	@while read i; do \
	    mkdir -p debian/$$i; \
	    if [ -n "$$i" ]; then \
	        $(lockme) dh_gencontrol -p$$i; \
	        dh_builddeb -p$$i; \
	    fi; \
	done <$(builddir)/udeb-meta-packages.list
