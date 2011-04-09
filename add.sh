#!/bin/bash

package="${*:-.}"

[ -d $package ] || die "Not a package directory: $package"
cd $package || die "Package is not accessible: $package"
echo "Testing makefile using a dry-run.."
make -n rpm >/dev/null || die "Package cannot be built using make"
package_dir=`pwd`

mkdir -p $CONFIGDIR/packages/
cd $CONFIGDIR/packages
ln -s $package_dir $CONFIGDIR/packages || die "Failed to create symlink to $package_dir"
