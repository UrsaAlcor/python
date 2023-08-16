#!/bin/bash

package="python"

set -xe

origin=$(pwd)
version=$(cd cpython && git describe --tags --abbrev=0)

install=$origin/lmod/dist/$(arch)/$package/$version
module=$origin/lmod/modules/$(arch)/$package/

mkdir -p $install
mkdir -p $module

NJ=${NJ:-$(nproc)}
# ===============

# Compile & install python
rm -rf $install/*
cd 'cpython'

# Dependencies
module load bzip2

# ----

./configure --prefix="$install" > /dev/null

make install -j$NJ                          \
    MOREFLAGS="-mtune=haswell -Wl,-z,now"   \
    PREFIX="$install"

cd ..


# Setup the module file
cp $package.lua $module/$version.lua

# Create python link
ln $install/bin/python3 $install/bin/python

sed -i -e "s@\${package}@$package@g" $module/$version.lua
sed -i -e "s@\${version}@$version@g" $module/$version.lua
