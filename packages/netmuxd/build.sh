TERMUX_PKG_HOMEPAGE=https://github.com/jkcoxson/netmuxd
TERMUX_PKG_DESCRIPTION="A replacement/addition to usbmuxd which is a reimplementation of Apple's usbmuxd on MacOS"
TERMUX_PKG_LICENSE="LGPL-2.1"
TERMUX_PKG_MAINTAINER="@xunmod"
_COMMIT=4790aff72448929ce1074cdc07c8db79676c2fb6
_COMMIT_DATE=20241114
TERMUX_PKG_VERSION=0.1.4-p${_COMMIT_DATE}
TERMUX_PKG_GIT_BRANCH=master
TERMUX_PKG_SRCURL=git+https://github.com/jkcoxson/netmuxd
TERMUX_PKG_SHA256=146918eb1580458199c9b29e4a3ed31a9e56d020303b4ff4302df18132826410
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_DEPENDS="libimobiledevice, libplist, openssl"

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
