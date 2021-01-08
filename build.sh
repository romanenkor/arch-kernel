ROOT=${PWD}
{
    asp checkout linux
    pushd linux/repos/core-x86_64
    /usr/bin/rm -rf src/archlinux-linux/
    grep -rl linux . | xargs sed -i 's/pkgbase=linux/pkgbase=linux-custom/'
} 2>/dev/null

makepkg -so --skipchecksums
zcat /proc/config.gz > config

# For KVM virtualization performance boost
sed '/CONFIG_NO_HZ_FULL/c CONFIG_NO_HZ_FULL=y' -i'' config

pushd src/archlinux-linux
for src in ${ROOT}/patches/*.patch; do
    echo "Applying patch $src"
    patch -Np1 < "$src"                                                       
done

popd
makepkg -sr --skipchecksums
popd

find . -name '*pkg.tar.xz' | xargs -I{} mv {} .
