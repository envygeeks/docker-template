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
		- [Building](#building)

<!-- /TOC -->

## Dockerfile

Just like any Docker image, you have a `Dockerfile`, it can be transformed using variables and other stuff on a per-tag/group basis because we run all your Dockerfile's through ERB before creating your context for Docker.

### Variables

* `@metadata`: A Metadata class holding all of the opts.yml data.

## [Copy](https://github.com/envygeeks/docker-template/tree/master/docs/copy.md)

Please see: https://github.com/envygeeks/docker-template/tree/master/docs/copy.md for more inforamtion on the `copy/` directory. It should provide all that you need to know about `copy/` data in every kind of template.  Thanks!

## [Metadata](https://github.com/envygeeks/docker-template/tree/master/docs/metadata.md)

Please see: https://github.com/envygeeks/docker-template/tree/master/docs/metadata.md for more information on `Metadata` and `opts.yml`.  It should provide all that you need to know about `Metadata` in every kind of template.  Thanks!

## Example

Lets build an image that installs prosody on both Alpine and Ubuntu with each tag respectively having base packages shared across them and one having it's own unique package.

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
```

#### `/repos/prosody/opts.yml`

```yml
tags:
  ubuntu: ubuntu
  alpine: alpine

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

### Building

```bash
docker-template build prosody
docker-template build prosody:ubuntu
docker-template build prosody:alpine
```
