# Metadata

In Docker Template metadata is nothing more than a bunch of data that is overriden from the bottom to the top.  Pretty much anything can be overriden, including your repository root, base images, types and well.. anything. By default the order of importance is: ***CLI > repo/repo/opts.yml > opts.yml***

<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Metadata](#metadata)
	- [Default Metadata](#default-metadata)
	- [Master/Repository Metadata](#masterrepository-metadata)
		- [Repository](#repository)
		- [Master](#master)
	- [Queryable Metadata](#queryable-metadata)
	- [Accessing Metadata within the Dockerfile and rootfs.erb](#accessing-metadata-within-the-dockerfile-and-rootfserb)
		- [Indifferent access](#indifferent-access)
		- [Stringify Methods](#stringify-methods)
			- [Mergeable Hashes](#mergeable-hashes)
			- [Mergeable Array's](#mergeable-arrays)
			- [Fallback Values](#fallback-values)
				- [By Tag](#by-tag)
				- [By Group](#by-group)
				- [From All](#from-all)
		- [With `#[]`(like a normal Hash.)](#with-like-a-normal-hash)
		- [`#to_h`, `#to_a`, and `#to_s` raw data.](#toh-toa-and-tos-raw-data)

<!-- /TOC -->

## Default Metadata

```yml
log_filters: []
push: false
cache: false
type: normal
user: envygeeks
local_prefix: local
rootfs_base_img: envygeeks/ubuntu
maintainer: Random User <random.user@example.com>
rootfs_template: alpine
name: docker-template
cache_dir: cache
repos_dir: repos
copy_dir: copy
tag: latest
clean: true
tty: false
tags: {}
```

## Master/Repository Metadata

All repos have master (parent metadata) and repo metadata that is merged in as the most important metadata.  Anything set globally can be overridden locally because at the end of the day, it all sits in the same spot and is merged in on an importance basis.

### Repository

`repos/repo/opts.yml`
```yml
tags:
  hello: world
env:
  all:
    HELLO: world
```

### Master
`opts.yml`

```yml
tty: false
maintainer: "Thug <person@thug.lyfe>"
push: false
```

**Any metadata found in the global `opts.yml` file can be overridden within the repositories `opts.yml`.  So any data can be both local and globally set on a per respository basis... however you see fit.**

## Queryable Metadata

Queryable metadata is the idea that you can query `by_tag`, `by_group` and `for_all` within your template by setting up your metadata to be queryable.  To do this, you add "group", "tag" and "all" keys with all your data grouped under these keys.  A basic example of this:

```yml
pkgs:
  group:
    my-group:
      key: val

  all:
    key: val
```

***USAGE NOTE: You do not need to provide all three keys ("tag", "group", and "all".) You can provide one or all of them as the lack of other keys is what decides whether or not an attribute is queryable.  So if you provide "tag" and "other_key" then data will not be queryable at all, however.. if you provide "tag" only, the data will be queryable.***

## Accessing Metadata within the Dockerfile and rootfs.erb

By default (and always) we run all Dockerfiles and `rootfs.erb` through (well you guessed it) ERB.  We will pass the metadata to you as the `@metadata` instance variable.  This is
a class that has fallback and mergeable methods and indifferent raw access.

### Indifferent access

By default we make all metadata strings and then make it entirely indifferent so you can access your data with symbols, strings and if need be floats/integers just like you would in Rails.  In-fact we use the Rails base code for indifference to do this (well except for the floats -- we do that ourselves.)

```
@metadata[:hello ] # => "world"
@metadata["hello"] # => "world"
```

### Stringify Methods

Pretty much any hash value can be converted into a usable string by accessing the hash key as a method instead of querying with `#[]`.  We do not shell escape these values and you will need to do this yourself with the `.shellescape` method (`@metadata.method.shellescape`).

#### Mergeable Hashes

Given you have `opts.yml` with the following data:

```yml
hello:
  all:
    world: yay

  tag:
    latest:
      person: yay
```

When you do `@metadata.hello` you will get a set of `key=value` that are meant to be environment variables.  Any hashes of those hashes are given back as raw strings (and by default in Ruby this is an inspection of the hash.)  An example:

```ruby
@metadata.hello # => "world=yay person=yay"
```

#### Mergeable Array's

Given you have `opts.yml` with the following data:

```yml
hello:
  all:
    - world

  tag:
    latest:
      - person
```

When you do `@metadata.hello` you will get a string of space separated `key1 key2` that are meant to be sent as argument values into commands.  Any arrays of those array's are flattened into the main array and pushed as part of that value.  An example:

```ruby
@metadata.hello # => "world person"
```

#### Fallback Values

Any value that is queryable but not-consistent (as in a consistent hash/array) will be treated as a fallback value, and you will get the most relevant value.  Starting from the most relevant (tag) to the least relevant (all) with the group sitting between them.  Here are some examples:

##### By Tag

```yml
hello:
  all: world
  # Selected
  tag:
    latest: hello
```

```ruby
@metadata.hello # => "hello"
```

##### By Group

```yml
hello:
  all: world
  # Selected

  group:
    normal: hello

  tag:
    unknown: person
```

```ruby
@metadata.hello # => "hello"
```

##### From All

Anything that cannot fallback to the tag and then the group will fallback to the all tag which is the default for all metadata for that key.

```yml
hello:
  # Selected
  all: world
  group:
    unknown: hello

  tag:
    unknown: person
```

```ruby
@metadata.hello # => "world"
```
### With `#[]`(like a normal Hash.)

All metadata can be accessed via the `#[]` method.  This data is raw and is not transformed until you run `#to_s` on that value (if it's a Hash.)  Any hashes are transformed into a `Metadata` class so they can be queried further and the parent data is shared with the sub-data so that you can still access things like the tag, group and otherwise.  You can transform, merge, fallback and otherwise alter the data the way method querying does by running `#by_tag`, `#by_group`, `#for_all`, `#fallback` and/or running `#to_s`.  As a basic example lets do this with the defacto packages key:

```yml
packages:
  all:
    - ruby2.3

  group:
    normal:
      - libxml2-dev

  tag:
    latest:
      - libyaml-dev
      - libxslt1-dev
      - libssl-dev
```

### `#to_h`, `#to_a`, and `#to_s` raw data.

If you wish to pull out the raw data instead of transforming it, when you run `#to_h`, `#to_a` and `#to_s` you can add the keyword `raw` with a value of true and at that point it will immediately skip all transformation and send you the raw data with those respective methods ran on them.
