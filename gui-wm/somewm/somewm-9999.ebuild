# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LUA_COMPAT=( lua-5.4 luajit )

inherit meson lua-single optfeature

if [[ ${PV} == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/trip-zip/${PN}.git"
else
	KEYWORDS="~amd64"
	SRC_URI="https://github.com/trip-zip/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
fi

DESCRIPTION="An AwesomeWM-compatible dynamic floating and tiling Wayland compositor"
HOMEPAGE="https://somewm.org https://github.com/trip-zip/somewm"

# GPL-3: somewm, ZLIB: bundled clay.h
LICENSE="GPL-3 ZLIB"
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
	>=gui-libs/wlroots-0.20.2:0.20[drm,libinput,session,x11-backend,X]
	media-libs/libglvnd
	sys-apps/dbus
	x11-base/xwayland
	x11-libs/cairo[X]
	x11-libs/gdk-pixbuf:2
	>=x11-libs/libdrm-2.4.129
	>=x11-libs/libxkbcommon-1.8.0
	x11-libs/libxcb:=
	>=x11-libs/pixman-0.46.0
	x11-libs/pango
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
	virtual/pkgconfig
"

pkg_setup() {
	lua-single_pkg_setup
}

src_configure() {
	local emesonargs=(
		-Dlua_pkg="${ELUA}"
		$(meson_feature pam)
	)
	meson_src_configure
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
