# somewm-gentoo-overlay

[![pkgcheck](https://github.com/shuber2/somewm-gentoo-overlay/actions/workflows/pkgcheck.yml/badge.svg)](https://github.com/shuber2/somewm-gentoo-overlay/actions/workflows/pkgcheck.yml)

A small Gentoo overlay providing ebuilds for [SomeWM](https://somewm.org), an
AwesomeWM-compatible dynamic floating and tiling Wayland compositor.

## Packages

- `gui-wm/somewm`

## Usage

Add this overlay with `eselect-repository`:

```sh
eselect repository add somewm git https://github.com/shuber2/somewm-gentoo-overlay.git
emaint sync -r somewm
```

Then unmask and install as usual, e.g.:

```sh
echo 'gui-wm/somewm ~amd64' >> /etc/portage/package.accept_keywords/somewm
emerge -av gui-wm/somewm
```

## License

Ebuilds are licensed under the GNU General Public License v2, see
[LICENSE](LICENSE).
