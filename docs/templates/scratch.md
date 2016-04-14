# Templates: Scratch

Scratch templates are a new take on the complicated way that some people build their scratch images.  They are complicated and hard to follow.  In Docker Template we allow you to build a full scratch image with ease by only knowing what you wish to download to make that scratch image and what you want to add to it.  We do the rest including making the context available to Docker, creating the Dockerfile for the scratch image and making data available.

<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Templates: Scratch](#templates-scratch)
	- [`rootfs.erb`](#rootfserb)
		- [Environment Variables](#environment-variables)
		- [Variables](#variables)
	- [Example](#example)
		- [The Layout](#the-layout)
		- [Opts.yml (Metadata)](#optsyml-metadata)
			- [`/opts.yml`](#optsyml)
			- [`/repos/ubuntu/opts.yml`](#reposprosodyoptsyml)
		- [rootfs.erb](#rootfserb)
		- [Building](#building)
		- [Running](#running)

<!-- /TOC -->

## `rootfs.erb`

All scratch images start with a `rootfs.erb` file.  This file is technically a bash file (or an SH file, we don't really care to be honest.) That is ran through ERB and then written into your context as `copy/usr/local/bin/mkimg` which the rootfs Dockerfile will run on your behalf before using the scratch Dockerfile to make the actual final resulting image on your behalf.

### Environment Variables

We make several environment variables available to your Bash/SH file (these are independently of normal Ruby variables in the ERB file.)  They are also merged with the queryable `env` key in your metadata.  These default environment variables are:

* `$REPO`: The name of the repository.
* `$TAR_GZ`: The tar file you should write the resulting image data to.
* `$COPY_DIR`: Where all your `copy/` data is mounted to.
* `$GROUP`: The current group of the image.
* `$BUILD_TYPE`: Always scratch/rootfs.
* `$TAG`: The images current tag.

### Variables

* `@metadata`: A Metadata class holding all of the opts.yml data.
* You have full access to Ruby and it's context from within ERB as well.

## Example

Lets build a custom Ubuntu image that we clean up and install a few base packages that we want, this image will be ours and only have what we want, and since removing packages from anothers image doesn't actually clean it up this is a better route.

### The Layout

```
opts.yml
repos/ubuntu
  opts.yml
  rootfs.erb
  copy/
```

### Opts.yml (Metadata)
#### `/opts.yml`

```yml
maintainer: Your Name <name@example.com>
user: random
```

#### `/repos/ubuntu/opts.yml`

```yml
tags:
  14.04: trusty
  16.04: xenial

aliases:
  latest: 16.04
  trusty: 14.04
  xenial: 16.04

releases:
  tag:
    14.04: trusty
    16.04: xenial

package_cleanup:
  all:
    - nano
    - vim-tiny
    - vim-common
    - isc-dhcp-common
    - isc-dhcp-client
    - iputils-ping
    - rsyslog
    - eject
    - ed

packages:
  all:
    - sudo
    - ca-certificates
    - tzdata
    - runit
```

### rootfs.erb

Below is an almost wholesale copy of `templates/rootfs.erb` which is a default part of Docker Template, you can see that file at: https://github.com/envygeeks/docker-template/blob/master/templates/rootfs/ubuntu.erb and if you do not wish to deal with all that you can actually use that template by adding the following to your `opts.yml`:

```yaml
rootfs_template: ubuntu
```

```bash
set -e

arch=$(uname -i)
rootfs=$(mktemp -d)
partner_url="https://partner-images.canonical.com/core"
dpkg_arch=$(dpkg --print-architecture)
tmp=$(mktemp -d)

cd $tmp
gpg  --keyserver keyserver.ubuntu.com --recv-keys 7db87c81
sudo apt-get update && sudo apt-get install --no-install-recommends -y wget
wget -nv $partner_url/<%= @metadata.release %>/current/SHA256SUMS.gpg
wget -nv $partner_url/<%= @metadata.release %>/current/SHA256SUMS
gpg --verify SHA256SUMS.gpg SHA256SUMS

img=$(cat SHA256SUMS | grep "$dpkg_arch" | awk -F' *' '{ print $2 }' | sed -r 's/^\*//')
sha=$(cat SHA256SUMS | grep "$dpkg_arch" | awk -F' *' '{ print $1 }')

wget -nv "$partner_url/<%= @metadata.release %>/current/$img"
if [ "$(sha256sum $img | awk '{ print $1 }')" != "$sha" ]; then
	echo "Bailing, the SHA256sum did not match."
fi

tar xzf $img -C $rootfs
cd -> /dev/null

rm -rf $rootfs/etc/hosts
rm -rf $rootfs/etc/resolv.conf
cp /etc/resolv.conf $rootfs/etc/resolv.conf
cp /etc/hosts $rootfs/etc/hosts

chroot "$rootfs" sh -ec "{
	dpkg-divert --local --rename --add /sbin/initctl
	dpkg-divert --local --rename --add /usr/sbin/update-rc.d
	ln -s /bin/true /usr/sbin/update-rc.d
	ln -s /bin/true /sbin/initctl
}"

chroot "$rootfs" sh -ec "{
	sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list
	echo \"debconf debconf/frontend select Noninteractive\" | debconf-set-selections
	echo 'Dpkg::Options { \"--force-confdef\"; \"--force-confold\"; }' > /etc/apt/apt.conf.d/local
	echo \"exit 101\" > /usr/sbin/policy-rc.d policy-rc.d
	sed -ri '/^(deb-src\s+|$|#)/d' /etc/apt/sources.list
	chmod uog+x /usr/sbin/policy-rc.d
	apt-get update
	apt-get dist-upgrade -yf
	apt-get install --no-install-recommends -yf locales deborphan
  <% if @metadata.package_cleanup?  %>apt-get autoremove --purge -y <%= @metadata.package_cleanup %><% end %>
  deborphan --add-keep <%= @metadata.packages %> &&  apt-get autoremove --purge \$(deborphan --guess-all) deborphan -yf
  <% if @metadata.packages?  %>apt-get install --no-install-recommends -y <%= @metadata.packages %><% end %>
  apt-get autoremove --purge
	apt-get autoclean
	apt-get clean
	rm -rf /tmp/remove
}"

cp -R $COPY_DIR/* $rootfs
rm -rf $rootfs/etc/hosts
rm -rf $rootfs/etc/resolv.conf
tar -zf $TAR_GZ --numeric-owner -C $rootfs -c .
```

### Building

Upon building, you will get five images, `random/ubuntu:14.04`, `random/ubuntu:16.04`, `random/ubuntu:xenial`, `random/ubuntu:trusty`, and `random/ubuntu:latest`.

```bash
docker-template build ubuntu
docker-template build ubuntu:tag
```

### Running

```bash
docker-template run --rm -it random/ubuntu:latest bash
```
