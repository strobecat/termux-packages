TERMUX_PKG_HOMEPAGE=https://github.com/Dadoum/Sideloader
TERMUX_PKG_DESCRIPTION="Open-source cross-platform iOS app sideloader"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_LICENSE_FILE="LICENSE"
_COMMIT=3f38490c04bc5fd991adbe2d86c9e7e07319d7ea
_COMMIT_DATE=20241222
TERMUX_PKG_MAINTAINER="@xunmod"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_VERSION=1.0-pre4-p${_COMMIT_DATE}
TERMUX_PKG_SRCURL=git+https://github.com/Dadoum/Sideloader
TERMUX_PKG_SHA256=766447a0afad1a2dc5f6081b4ee4ed2c3cab5a4303e4687ba64bc61290db935d
TERMUX_PKG_GIT_BRANCH=main
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_DEPENDS="ldc, binutils-cross"
TERMUX_PKG_DEPENDS="libandroid-execinfo, libimobiledevice, libplist, libusbmuxd"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS=":cli-frontend"

termux_step_configure() {
	termux_setup_ldc
}

termux_step_post_get_source() {
	git fetch --unshallow
	git checkout $_COMMIT

	local pdate="p$(git log -1 --format=%cs | sed 's/-//g')"
	if [[ "$TERMUX_PKG_VERSION" != *"${pdate}" ]]; then
		echo -n "ERROR: The version string \"$TERMUX_PKG_VERSION\" is"
		echo -n " different from what is expected to be; should end"
		echo " with \"${pdate}\"."
		return 1
	fi

	local s=$(find . -type f ! -path '*/.git/*' -print0 | xargs -0 sha256sum | LC_ALL=C sort | sha256sum)
	if [[ "${s}" != "${TERMUX_PKG_SHA256}  "* ]]; then
		termux_error_exit "Checksum mismatch for source files."
	fi
}


termux_step_make_install() {
	install -Dm700 -t $TERMUX_PREFIX/bin bin/sideloader
}
