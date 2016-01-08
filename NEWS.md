# Change Log

All notable changes to this project will be documented in this file. This
project adheres to [Semantic Versioning](http://semver.org/).

## [UNRELEASED]
#### Added
- Aliased tags can have their own merged values.
- Allow Excon to be configured inside of opts.yml with excon_timeout.
- Added the ability to do simple copies, no need to care about `copy/{tag,type,all}` anymore.
- Added support for naming a repo different than the folder name.  Use `name` in opts.yml.
- Added a User-Agent so Docker and other stuff can identify our software.
- Complex aliased metadata is not treated like a full build. [#7]
- `--tty` option to enable tty scratch builds.
- Added a default timeout of 1440 to Excon.

#### Changed
- Switch to completely dynamic test fixtures.
- Rewrite specs to be more verbose and easily organized.
- Do inline tagging on build instead of after the build.
- Move alias building back into the main builder class to ease dev.
- Move to using `envygeeks/ubuntu:latest` instead of `envygeeks/ubuntu:tiny`
- Move the secondary logger out of Scratch#build_context and into it's own method.
- Normal sync across the CLI and opts.yml to make things easier to follow and understand.
- Split `Ansi.jump` into `Ansi.jump`, `Ansi.down`, and `Ansi.up` for simpler interaction with the API.
- Move caching to syncing for consistency, on the high level it's "sync" on the low level it uses "cache_dir".
- Change "Simple" type to "Normal" type so it's not confused with "simple copy".
- Correct an issue where pulling the parent_repo of an alias doesn't work.
- Detect if a repo has multiple tags and only segement cache if they do.
- Move `Docker::Template::Common` -> `Docker::Template::Builder`
- Remove `Util#get_context`; we always copy the context anyways.
- Move old coupled CLI stuff into config and off Interface.
- Cleanup Metadata and it's API, making it less fragile.
- Move Alias directly onto builder as a simple method.
- Remove encapsulating auth into a class.
- Fix a few minor bugs.

#### Fixed
- Prevent a double copy with all/* when the repo is the root.
- Detect empty and invalid `opts.yml` and either ship a blank hash or raise.
- Fix detection of directory is repo, it should use the *current directory* not 2 directories back.
- Make sure RSpec helpers is always available first.

#### Hacks
- Work around a Docker/Excon/Docker-API JSON bug.

## 0.2.0
#### Added
- A Git repo with only one repo can now act as repos. [#3]
- Add `Metadata#as_gem_version` which merges the repo name with the version in `Metadata` [#1]
- Use `#from_root` instead of `@root_metadata` so we can fallback. [#4]
- Clean up code in various ways.

#### Changed
- Added CodeClimate platform.
- Added RuboCop to CodeClimate platform.

## 0.1.2
#### Changed
- Make sure bin/docker-template is available in the gem.
- Make sure the CodeClimate link is correct.

## 0.1.0
#### Added
- Building images: `docker-template repo repo`.
- The ability to push to Docker hub: `docker-template --push`.
- The ability to store contexts for Docker Hub: `docker-template --sync`.
- The ability to wrap Docker by symlinking `docker` to `docker-template`.
- The ability to do complex builds with types, tags, and global options.
- Support for building specific tags, specific repos or everything.
- The ability to have global and per repo configurations.
- Scratch and simple images for your pleasure.
- On the fly tagging for simple images.
- The ability to alias tags.

#### This release comes with examples:
- https://github.com/envygeeks/docker
- https://github.com/jekyll/docker
