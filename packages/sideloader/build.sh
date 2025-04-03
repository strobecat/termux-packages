TERMUX_PKG_HOMEPAGE=https://github.com/Dadoum/Sideloader
TERMUX_PKG_DESCRIPTION="Open-source cross-platform iOS app sideloader"
TERMUX_PKG_LICENSE="GPL-3.0"
_COMMIT=2e5c9670b592a2157c18b16244c3b82be838cd8a
_COMMIT_DATE=20250223
TERMUX_PKG_MAINTAINER="@xunmod"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_VERSION=1.0-pre4-p${_COMMIT_DATE}
TERMUX_PKG_SRCURL=git+https://github.com/Dadoum/Sideloader
TERMUX_PKG_SHA256=1e06c1c5d06cef55cb3a2c7731b12839b3d7cb368f2d059b8a11cb43707d5911
TERMUX_PKG_GIT_BRANCH=main
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_DEPENDS="ldc, binutils-cross"
TERMUX_PKG_DEPENDS="libandroid-execinfo, libimobiledevice, libplist, libusbmuxd"
TERMUX_PKG_BLACKLISTED_ARCHES="arm, i686"
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
