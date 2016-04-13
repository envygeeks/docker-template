# Templates: Normal

A normal template is for the most part exactly like any other Docker template except it has queryable data and a context that we create for that data before allowing Docker to create it's own context.

<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Templates: Normal](#templates-normal)
	- [Dockerfile](#dockerfile)
		- [Variables](#variables)
	- [[Copy](https://github.com/envygeeks/docker-template/tree/master/docs/copy.md)](#copyhttpsgithubcomenvygeeksdocker-templatetreemasterdocscopymd)
	- [[Metadata](https://github.com/envygeeks/docker-template/tree/master/docs/metadata.md)](#metadatahttpsgithubcomenvygeeksdocker-templatetreemasterdocsmetadatamd)
	- [Example](#example)
		- [The Layout](#the-layout)
		- [Opts.yml (Metadata)](#optsyml-metadata)
			- [`/opts.yml`](#optsyml)
			- [`/repos/prosody/opts.yml`](#reposprosodyoptsyml)
		- [The Dockerfile](#the-dockerfile)
			- [The final Dockerfile output as tag: alpine](#the-final-dockerfile-output-as-tag-alpine)
			- [The final Dockerfile output as tag: ubuntu](#the-final-dockerfile-output-as-tag-ubuntu)
		- [`/repos/prosody/copy/etc/startup3.d/prosody/run`](#reposprosodycopyetcstartup3dprosodyrun)
		- [Building](#building)
		- [Running](#running)

<!-- /TOC -->

## Dockerfile

Just like any Docker image, you have a `Dockerfile`, it can be transformed using variables and other stuff on a per-tag/group basis because we run all your Dockerfile's through ERB before creating your context for Docker.

### Variables

* `@metadata`: A Metadata class holding all of the opts.yml data.
* You have full access to Ruby and it's context from within ERB as well.

<!--
## [Copy](https://github.com/envygeeks/docker-template/tree/master/docs/copy.md)
## [Metadata](https://github.com/envygeeks/docker-template/tree/master/docs/metadata.md)
-->

## Example

Lets build an image that installs `prosody` on both Alpine and Ubuntu with each tag respectively having base packages shared across them and one having it's own unique package (bash) because Alpine is an embedded OS driven at simplicity, it has no `bash`.

### The Layout

```
opts.yml
repos/prosody
  opts.yml
  Dockerfile
  copy/
```

### Opts.yml (Metadata)
#### `/opts.yml`

```yml
maintainer: Your Name <name@example.com>
user: random
```

#### `/repos/prosody/opts.yml`

```yml
tags:
  ubuntu: ubuntu
  alpine: alpine

aliases:
	latest: alpine

images:
  tag:
    ubuntu: "envygeeks/ubuntu:latest"
    alpine: "envygeeks/alpine:latest"

packages:
  all:
    - prosody

  group:
    alpine:
      - bash

package_commands:
  group:
    ubuntu: "apt-get update && apt-get install --no-install-recommends -y"
    alpine: "apk --update add"
```

### The Dockerfile


```dockerfile
MAINTAINER <% @metadata.maintainer %>
FROM <%= @metadata.image %>
RUN <%= @metadata.package_command + " " + @metadata.packages %>
COPY copy /
```

#### The final Dockerfile output as tag: alpine

```dockerfile
MAINTAINER Your Name <name@example.com>
FROM envygeeks/alpine:latest
RUN apk --update add prosody bash
COPY copy /
```

#### The final Dockerfile output as tag: ubuntu

```dockerfile
MAINTAINER Your Name <name@example.com>
FROM envygeeks/ubuntu:latest
RUN apt-get update && apt-get install --no-install-recommends -y prosody
COPY copy /
```

### `/repos/prosody/copy/etc/startup3.d/prosody/run`

```bash
sed -ri "s/__HOSTNAME__/$HOSTNAME/" \
  /etc/prosody/prosody.cfg.lua

ssl_lines() {
  grep -nE '\s+-{2}\s+enable:ssl$' /etc/prosody/prosody.cfg.lua | awk -F: '{
    print $1
  }'
}

if [ "$ENABLE_SSL" ]; then
  for v in $(ssl_lines); do
    sed -ri "${v}s/(\s*)-{2}\s+/\1/" /etc/prosody/prosody.cfg.lua
    sed -ri "${v}s/\s+-{2}\s+enable:ssl\$//" \
      /etc/prosody/prosody.cfg.lua
  done
else
  while { l=$(ssl_lines | head -n1); test -n "$l"; } do sed -i "${l}d" /etc/prosody/prosody.cfg.lua; done
  for v in $(grep -nE '\s+-{2}\s+disable:ssl$' /etc/prosody/prosody.cfg.lua | awk -F: '{ print $1 }'); do
    sed -ri "${v}s/(\s*)-{2}\s+/\1/" /etc/prosody/prosody.cfg.lua
    sed -ri "${v}s/\s+-{2}\s+disable:ssl\$//" \
      /etc/prosody/prosody.cfg.lua
  done
fi

exec chpst -u prosody:prosody \
  prosody
```

### Building

Upon building, you will get three images, `random/prosody:ubuntu`, `random/prosody:latest`, and `random/prosody:alpine` and `random/prosody:latest` will point to the image id of `random/prosody:alpine`.

```bash
docker-template build prosody
docker-template build prosody:ubuntu
docker-template build prosody:alpine
```

### Running

```bash
docker-template run --rm -it random/prosody:alpine
docker-template run --rm -it random/prosody:ubuntu
docker-template run --rm -it random/prosody:latest
```
