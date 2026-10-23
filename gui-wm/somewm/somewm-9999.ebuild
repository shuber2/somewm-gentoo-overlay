# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LUA_COMPAT=( lua-5.4 luajit )

inherit meson lua-single optfeature

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/trip-zip/${PN}.git"
else
	# somewm links a patched wlroots statically (subprojects/wlroots.wrap)
	WLROOTS_PV="0.20.2"

	KEYWORDS="~amd64"
	SRC_URI="
		https://github.com/trip-zip/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
		https://gitlab.freedesktop.org/wlroots/wlroots/-/releases/${WLROOTS_PV}/downloads/wlroots-${WLROOTS_PV}.tar.gz
	"
fi

DESCRIPTION="An AwesomeWM-compatible dynamic floating and tiling Wayland compositor"
HOMEPAGE="https://somewm.org https://github.com/trip-zip/somewm"

# GPL-3: somewm, MIT: bundled wlroots, ZLIB: bundled clay.h
LICENSE="GPL-3 MIT ZLIB"
SLOT="0"
IUSE="+pam"

REQUIRED_USE="${LUA_REQUIRED_USE}"

RDEPEND="
	${LUA_DEPS}
	$(lua_gen_cond_dep 'dev-lua/lgi[${LUA_USEDEP}]')
	>=dev-libs/wayland-1.24.0
	dev-libs/glib:2
	dev-libs/libffi
	>=dev-libs/libinput-1.19.0:=
	>=gnome-base/librsvg-2.52:2
	>=media-libs/libdisplay-info-0.2.0:=
	media-libs/libglvnd
	>=media-libs/mesa-24.1.0_rc1[opengl]
	sys-apps/dbus
	sys-auth/seatd:=
	virtual/libudev
	x11-base/xwayland
	x11-libs/cairo[X]
	x11-libs/gdk-pixbuf:2
	>=x11-libs/libdrm-2.4.129
	>=x11-libs/libxkbcommon-1.8.0
	x11-libs/libxcb:=
	>=x11-libs/pixman-0.46.0
	x11-libs/pango
	x11-libs/xcb-util-renderutil
	x11-libs/xcb-util-wm
	pam? ( sys-libs/pam )
"
DEPEND="
	${RDEPEND}
"
BDEPEND="
	${LUA_DEPS}
	>=dev-libs/wayland-protocols-1.47
	dev-build/meson
	dev-build/ninja
	dev-util/wayland-scanner
	sys-apps/hwdata
	virtual/pkgconfig
"

pkg_setup() {
	lua-single_pkg_setup
}

src_unpack() {
	# meson runs with --wrap-mode nodownload, so the wlroots wrap has to be
	# provided here; meson verifies the tarball and applies the wrap's
	# diff_files itself
	if [[ ${PV} == *9999* ]]; then
		git-r3_src_unpack
		meson subprojects download --sourcedir "${S}" wlroots || die
	else
		unpack ${P}.tar.gz
		mkdir -p "${S}"/subprojects/packagecache || die
		cp "${DISTDIR}"/wlroots-${WLROOTS_PV}.tar.gz "${S}"/subprojects/packagecache/ || die
	fi
}

src_configure() {
	local emesonargs=(
		-Dlua_pkg="${ELUA}"
		$(meson_feature pam)
		# avoid automagic deps in the bundled wlroots
		-Dwlroots:color-management=disabled
		-Dwlroots:libliftoff=disabled
		-Dwlroots:xcb-errors=disabled
	)
	meson_src_configure
}

src_install() {
	# keep the static wlroots, its headers and .pc files out of the image
	meson_src_install --skip-subprojects
}

pkg_postinst() {
	einfo "Migration check from AwesomeWM:"
	einfo "  somewm --check ~/.config/awesome/rc.lua"
	einfo ""
	einfo "Launching somewm from a TTY:"
	einfo "  somewm-session"
	einfo ""
	einfo "Further details at: https://somewm.org/docs/intro"

	optfeature_header "There are optional packages that may be useful with somewm:"
	optfeature "desktop portal backend" sys-apps/xdg-desktop-portal-gtk
	optfeature "screenshot/screencast portal backend" gui-libs/xdg-desktop-portal-wlr
}
