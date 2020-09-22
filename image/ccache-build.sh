set -e

pkgname=ccache
pkgver=3.5
pkgrel=1
pkgdesc='Compiler cache that speeds up recompilation by caching previous compilations'
url='https://ccache.samba.org/'
arch=('x86_64')
license=('GPL3')
depends=('zlib')
source=(https://www.samba.org/ftp/ccache/ccache-${pkgver}.tar.xz{,.asc})
validpgpkeys=('5A939A71A46792CF57866A51996DDA075594ADB8') # Joel Rosdahl <joel@rosdahl.net>
sha256sums=('bdd44b72ae4506a2e2deef9fefb15c606a474bbca7658cd2be26105155eec012'
            'SKIP')
sha512sums=('92181fb794f06dc231baa4193c37e8f1d844c9281fd64bcb8f4b35c87b4a88dfc9bf36b810b37151ee85699778fcd3783818949a7010e619aeca7e3b33b7a2e3'
            'SKIP')

build() {
  cd ${pkgname}-${pkgver}
  ./configure \
    --prefix=/usr \
    --sysconfdir=/etc
  make
}

check() {
  cd ${pkgname}-${pkgver}
  make check
}

package() {
  cd ${pkgname}-${pkgver}

  install -Dm 755 ccache -t "${pkgdir}/usr/bin"
  install -Dm 644 doc/ccache.1 -t "${pkgdir}/usr/share/man/man1"
  install -Dm 644 doc/{AUTHORS,MANUAL,NEWS}.adoc README.md -t "${pkgdir}/usr/share/doc/${pkgname}"

  install -d "${pkgdir}/usr/lib/ccache/bin"
  local _prog
  for _prog in gcc g++ c++; do
    ln -s /usr/bin/ccache "${pkgdir}/usr/lib/ccache/bin/$_prog"
  done
  for _prog in cc clang clang++; do
    ln -s /usr/bin/ccache "${pkgdir}/usr/lib/ccache/bin/$_prog"
  done
}

mkdir -p ccache-build
for file in "${source[@]}"
do
    wget $file
    if [[ "${file}" == *.tar.xz ]]
    then
        pushd ccache-build
            tar -xf ../"$(basename ${file})"
        popd
    fi          
done

pushd ccache-build
build
popd

#pushd ccache-build
#check
#popd

pushd ccache-build
package
popd
