# shellcheck shell=bash disable=SC2155
termux_setup_ldc_cross_config() {
	local WIDER_TRIPLE=${TERMUX_LDC_TRIPLE/--/-.*-}
	grep -F "$WIDER_TRIPLE" "$1" &>/dev/null && return;

	cat << EOF >> "$1"
"${WIDER_TRIPLE}":
{
    switches = [
        "-defaultlib=phobos2-ldc,druntime-ldc",
	"-gcc=${CC}",
	"-Xcc=-B",
	"-Xcc=%%ldcbinarypath%%",
	"-L--enable-new-dtags",
	"-L-rpath=${TERMUX_PREFIX}/lib",
    ];
    lib-dirs = [
        "${TERMUX_PREFIX}/lib",
    ];
    rpath = "${TERMUX_PREFIX}/lib";
};
EOF
}

termux_setup_ldc() {
	TERMUX_LDC_TRIPLE=${TERMUX_HOST_PLATFORM/-/--}
	if [ "$TERMUX_ARCH" = "arm" ]; then TERMUX_LDC_TRIPLE=${TERMUX_LDC_TRIPLE/arm-/armv7a-}; fi
	if [ "$TERMUX_ON_DEVICE_BUILD" = "false" ]; then
		local TERMUX_LDC_VERSION=$(. "${TERMUX_SCRIPTDIR}/packages/ldc/build.sh"; echo "${TERMUX_PKG_VERSION}")
		local TERMUX_LDC_PLATFORM=linux-x86_64

		test -f "${TERMUX_PREFIX}/lib/libdruntime-ldc.a" ||
			termux_error_exit "Package 'ldc' is not installed. It is required by LDC cross-compiler." \
			"You should specify it in 'TERMUX_PKG_BUILD_DEPENDS'."
		test -f "${TERMUX_PREFIX}/opt/binutils/cross/bin/${TERMUX_HOST_PLATFORM}-ld" ||
			termux_error_exit "Package 'binutils-cross' is not installed. It is required by LDC cross-compiler." \
			"You should specify it in 'TERMUX_PKG_BUILD_DEPENDS'."

		local TERMUX_BUILDLDC_FOLDER
		if [ "${TERMUX_PACKAGES_OFFLINE-false}" = "true" ]; then
			TERMUX_BUILDLDC_FOLDER=${TERMUX_SCRIPTDIR}/build-tools/ldc2-${TERMUX_LDC_VERSION}
		else
			TERMUX_BUILDLDC_FOLDER=${TERMUX_COMMON_CACHEDIR}/ldc2-${TERMUX_LDC_VERSION}
		fi
		local TERMUX_BUILDLDC_NAME=ldc2-${TERMUX_LDC_VERSION}-${TERMUX_LDC_PLATFORM}
		local TERMUX_BUILDLDC_CONF=${TERMUX_BUILDLDC_FOLDER}/etc/ldc2.conf

		export PATH=${TERMUX_BUILDLDC_FOLDER}/bin:${PATH}

		if [ -d "$TERMUX_BUILDLDC_FOLDER" ]; then
			ln -sf "${TERMUX_PREFIX}/opt/binutils/cross/bin/${TERMUX_HOST_PLATFORM}-ld" "${TERMUX_BUILDLDC_FOLDER}/bin/ld.bfd"
			termux_setup_ldc_cross_config "$TERMUX_BUILDLDC_CONF"
			return
		fi

		local TERMUX_BUILDLDC_TAR=$TERMUX_COMMON_CACHEDIR/${TERMUX_BUILDLDC_NAME}.tar.xz
		rm -Rf "${TERMUX_COMMON_CACHEDIR:?}/$TERMUX_BUILDLDC_NAME" "$TERMUX_BUILDLDC_FOLDER"
		termux_download "https://github.com/ldc-developers/ldc/releases/download/v${TERMUX_LDC_VERSION}/ldc2-${TERMUX_LDC_VERSION}.sha256sums.txt" \
			"${TERMUX_BUILDLDC_TAR}.chksum" \
			SKIP_CHECKSUM
		local TERMUX_LDC_SHA256=$(grep ${TERMUX_LDC_PLATFORM} "${TERMUX_BUILDLDC_TAR}.chksum" | awk -F " " '{print $1}')
		termux_download "https://github.com/ldc-developers/ldc/releases/download/v${TERMUX_LDC_VERSION}/ldc2-${TERMUX_LDC_VERSION}-${TERMUX_LDC_PLATFORM}.tar.xz" \
			"$TERMUX_BUILDLDC_TAR" \
			"${TERMUX_LDC_SHA256}"

		( cd "$TERMUX_COMMON_CACHEDIR"; tar xJf "$TERMUX_BUILDLDC_TAR"; mv "$TERMUX_BUILDLDC_NAME" "$TERMUX_BUILDLDC_FOLDER"; rm "$TERMUX_BUILDLDC_TAR" "${TERMUX_BUILDLDC_TAR}.chksum") || exit 1

		ln -sf "${TERMUX_PREFIX}/opt/binutils/cross/bin/${TERMUX_HOST_PLATFORM}-ld" "${TERMUX_BUILDLDC_FOLDER}/bin/ld.bfd"
		termux_setup_ldc_cross_config "$TERMUX_BUILDLDC_CONF"
	else
		if [[ "$TERMUX_APP_PACKAGE_MANAGER" = "apt" && "$(dpkg-query -W -f '${db:Status-Status}\n' ldc 2>/dev/null)" != "installed" ]] ||
		   [[ "$TERMUX_APP_PACKAGE_MANAGER" = "pacman" && ! "$(pacman -Q ldc 2>/dev/null)" ]]; then
			echo "Package 'ldc' is not installed."
			echo "You can install it with"
			echo
			echo "  pkg install ldc"
			echo
			echo "  pacman -S ldc"
			echo
			exit 1
		fi
	fi
}
