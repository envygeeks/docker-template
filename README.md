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

## Organization

A basic repository (or even repositories in a repository) consists of a master `opt.yml` file that can hold data for all repositories and `opt.yml` files within each Docker repository. With a basic layout:

```
opts.yml
repos/<image>/
  Dockerfile
  README.md
  opt.yml
  copy/
    tag/<name>/
      file1
      file2

    group/<name>/
      file1
      file2
    all/
      file1
      file2
```

## Template Data

Each template can have shared and even master data.  Master data sits below the "repos" folder and is shared across all repositories and shared data sits inside of the repo.  Master data is simple and repo data is queryable (in that it's sorted by tag, group and all,) so that you can have data for specific scenarios.


### Copy Order

1. Master
1. All
2. Group
3. Tag

### Master Data

Master data is stored in the root of your folder, along with the master `opts.yml` file.  This data is copied first and must always use a simple layout as it's simply master data.  Given we are looking at the root of the Git repository holding all our respositories this is where you would place master data.

```
opts.yml
copy/usr/local/share/my-image/
  master-file.txt
```

### Repo Data

Repo data is organized by "all", "group", and "tag".  It to must be laid out how you wish it to be copied onto the file system. Given you have a tag named "my-tag" and this tag has a type of "normal" (the default) then you would organize data the like so:

```
opts.yml
repo/my-image/copy
  tag/my-tag/usr/bin/
    hello
```

## Template Metadata (opts.yml)

All repos have master (parent metadata) and repo metadata that is merged in as the most important metadata.  Anything set globally can be overridden locally because at the end of the day, it all sits in the same spot and is merged in on an importance basis.  A basic `opts.yml` file looks like this:

Repository Metadata<br>
(`opts.yml`)


```yml
tags:
  hello: world
env:
  all:
    HELLO: world

pkgs:
  group:
    world:
      - my-package
  tag:
    hello:
      - my-package
```

Global Metadata<br>
(`opts.yml`)

```yml
tty: false
maintainer: "Thug <person@thug.lyfe>"
push: false
```

**Any metadata found in the global `opts.yml` file can be overridden within the repositories `opts.yml`.  So any data can be both local and globally set on a per respository basis... however you see fit.**

### Queryable Metadata

Querable metadata is the idea that you can query `by_tag`, `by_group` and `for_all` within your template by setting up your metadata to be queryable.  To do this, you add "group", "tag" and "all" keys with all your data grouped under these keys.  A basic example of this:

```yml
pkgs:
  group:
    my-group:
      key: val

  all:
    key: val
```

***USAGE NOTE: You do not need to provide all three keys ("tag", "group", and "all".) You can provide one or all of them as the lack of other keys is what decides whether or not an attribute is queryable.  So if you provide "tag" and "other_key" then data will not be queryable at all, however.. if you provide "tag" only, the data will be queryable.***

## Templates

There are two kinds of templates, "scratch" and "simple".  Scratch templates make it easy to work from a base operating system image and simple templates are based off other Docker images and beheave almost like regular Docker templates.

### Scratch

A scratch template can have anything you wish within the `rootfs.erb` file.  It can be run however you wish and pull whatever base image you wish to pull.  The basic layout of a scratch image:

```
opts.yml
repos/ubuntu/
  rootfs.erb
  opts.yml
  copy/
```

***To read more about scratch templates see https://github.com/envygeeks/docker-template/tree/master/docs/templates/scratch.md***

### Normal

A normal template is structured just like a normal Docker template except it has a queryable copy folder that we create and a context that we setup before we allow Docker to setup it's own context.  The basic layout of a normal image:

```
opts.yml
repos/discourse
  Dockerfile
  opts.yml
  copy/
```

***To read more about normal templates see https://github.com/envygeeks/docker-template/tree/master/docs/templates/normal.md***
