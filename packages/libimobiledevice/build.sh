TERMUX_PKG_HOMEPAGE=https://libimobiledevice.org/
TERMUX_PKG_DESCRIPTION="A library to communicate with services on iOS devices using native protocols"
TERMUX_PKG_LICENSE="LGPL-2.1-or-later"
_COMMIT=42f25532bd98a3ffe361e719f9c51fb05573deb3
_COMMIT_DATE=20240807
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION=1.3.0-p${_COMMIT_DATE}
TERMUX_PKG_REVISION=2
TERMUX_PKG_SRCURL=git+https://github.com/libimobiledevice/libimobiledevice
TERMUX_PKG_SHA256=f8f5ae0954af626aece81bdcfaed219a2ddeaad1d48d0eb28183d7d4c0272ff3
TERMUX_PKG_GIT_BRANCH=master
TERMUX_PKG_AUTO_UPDATE=false
TERMUX_PKG_DEPENDS="libimobiledevice-glue, libplist, libtatsu, libusbmuxd, openssl"

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

termux_step_pre_configure() {
	autoreconf -fi
}
