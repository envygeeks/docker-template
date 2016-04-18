# Docker Template

[![Build](https://travis-ci.org/envygeeks/docker-template.svg?branch=master)][travis]
[![Test](https://codeclimate.com/github/envygeeks/docker-template/badges/coverage.svg)][coverage]
[![Code](https://codeclimate.com/github/envygeeks/docker-template/badges/gpa.svg)][codeclimate]
[![Dependency](https://gemnasium.com/envygeeks/docker-template.svg)][gemnasium]

[gemnasium]: https://gemnasium.com/envygeeks/docker-template
[codeclimate]: https://codeclimate.com/github/envygeeks/docker-template
[coverage]: https://codeclimate.com/github/envygeeks/docker-template/coverage
[travis]: https://travis-ci.org/envygeeks/docker-template

Docker Template is an organization and templating system for Docker images. A way to make your life easier and more organized by having repositories within repositories that share data among multiple sets of images.  It is currently used to build all the images for Jekyll and EnvyGeeks.  To see the full docs instead of synapsis and snippets please visit https://github.com/envygeeks/docker-template/tree/master/docs

<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Docker Template](#docker-template)
	- [Installation](#installation)
	- [[Organization](https://github.com/envygeeks/docker-template/tree/master/docs/organization.md)](#organizationhttpsgithubcomenvygeeksdocker-templatetreemasterdocsorganizationmd)
	- [[Metadata](https://github.com/envygeeks/docker-template/tree/master/docs/metadata.md)](#metadatahttpsgithubcomenvygeeksdocker-templatetreemasterdocsmetadatamd)
	- [[Normal](https://github.com/envygeeks/docker-template/tree/master/docs/templates/normal.md)](#normalhttpsgithubcomenvygeeksdocker-templatetreemasterdocstemplatesnormalmd)
	- [[Scratch](https://github.com/envygeeks/docker-template/tree/master/docs/templates/scratch.md)](#scratchhttpsgithubcomenvygeeksdocker-templatetreemasterdocstemplatesscratchmd)
	- [[Copy/](https://github.com/envygeeks/docker-template/tree/master/docs/copy.md)](#copyhttpsgithubcomenvygeeksdocker-templatetreemasterdocscopymd)
	- [Commands](#commands)
		- [Build](#build)
		- [List](#list)

<!-- /TOC -->

## Installation

```bash
sudo gem install docker-template  
```

From Gemfile

```ruby
gem "docker-template", {
  :github => "envygeeks/docker-template"
}
```

<!--
## [Organization](https://github.com/envygeeks/docker-template/tree/master/docs/organization.md)
## [Metadata](https://github.com/envygeeks/docker-template/tree/master/docs/metadata.md)
## [Normal](https://github.com/envygeeks/docker-template/tree/master/docs/templates/normal.md)
## [Scratch](https://github.com/envygeeks/docker-template/tree/master/docs/templates/scratch.md)
## [Copy/](https://github.com/envygeeks/docker-template/tree/master/docs/copy.md)
-->

## Commands

### Build

You can build a template by sending `image`, `user/image`, `image:tag`, or `user/image:tag` to `docker-template build`.<br>
Build supports the following arguments:

```
Usage:
  docker-template build [REPOS [OPTS]]

Options:
  [--cache-only], [--no-cache-only]  # Only cache your repositories, don't build.
  [--clean-only], [--no-clean-only]  # Only clean your repositories, don't build.
  [--push-only], [--no-push-only]    # Only push  your repositories, don't build.
  [--profile], [--no-profile]        # Profile Memory.
  [--tty], [--no-tty]                # Enable TTY Output.
  [--push], [--no-push]              # Push Repo After Building.
  [--cache], [--no-cache]            # Cache your repositories to cache.
  [--mocking], [--no-mocking]        # Disable Certain Actions.
  [--clean], [--no-clean]            # Cleanup your caches.

Build all (or some) of your repositories
```

***You can send as many repos/images as you like, or you can send none, the lack of any repos/images will result in all of the possible images being built from your repos/ folder.  This is good for automated building. NOTE: When building images we sort them, in that scratch images are built first, normal images are built second and aliases are done last, so that if you have dependencies within your dependencies hopefully they will get built first, however this is not always likely if your images rely on another normal image.  In that case you might want to send a manual list for us.***

### List

You can get a list of all the images via `docker-template list`:

```
[user] jekyll
  ├─ [repo] builder
  │  ├─ [tag] 3.1.2
  │  │  ├─ [alias] latest
  │  │  │  ├─ [alias] jekyll:builder
  │  │  ├─ [alias] stable
  │  │  ├─ [alias] 3.1
  │  │  ├─ [alias] 3
  │  ├─ [tag] pages
  ├─ [repo] jekyll
  │  ├─ [tag] 3.1.2
  │  │  ├─ [alias] latest
  │  │  ├─ [alias] stable
  │  │  ├─ [alias] 3.1
  │  │  ├─ [alias] 3
  │  ├─ [tag] pages
  │  ├─ [remote] envygeeks/alpine:latest
  │  │  ├─ [alias] envygeeks
```
