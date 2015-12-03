# Change Log

All notable changes to this project will be documented in this file. This
project adheres to [Semantic Versioning](http://semver.org/).

## [UNRELEASED]
### Added

### Planned
- Detect if the user is in a sub-folder and allow building by stepping back.
- Add `Metadata#as_gem_version` which merges the repo name with the version in `Metadata`
- Use docker-template on a single "repo" without a "repos" directory.
- Account for a user not having our specific keys in some places.
- Clean up code in various ways.

### Changed
- Added CodeClimate platform. [[9c0940e][9c0940e]]
- Added RuboCop to CodeClimate platform. [[c332908][c332908]]

## 0.2.0
### Changed
- Make sure bin/docker-template is available in the gem: [[fe24e40][fe24e40]]
- Make sure the CodeClimate link is correct: [[a8b98dc][a8b98dc]]

## 0.1.0
### Added
- Building images: `docker-template repo repo`: [[e8fc4a6][e8fc4a6]]
- The ability to push to Docker hub: `docker-template --push`: [[e8fc4a6][e8fc4a6]]
- The ability to store contexts for Docker Hub: `docker-template --sync`: [[e8fc4a6][e8fc4a6]]
- The ability to wrap Docker by symlinking `docker` to `docker-template`: [[e8fc4a6][e8fc4a6]]
- The ability to do complex builds with types, tags, and global options: [[e8fc4a6][e8fc4a6]]
- Support for building specific tags, specific repos or everything: [[e8fc4a6][e8fc4a6]]
- The ability to have global and per repo configurations: [[e8fc4a6][e8fc4a6]]
- Scratch and simple images for your pleasure: [[e8fc4a6][e8fc4a6]]
- On the fly tagging for simple images: [[e8fc4a6][e8fc4a6]]
- The ability to alias tags: [[e8fc4a6][e8fc4a6]]

#### This release comes with examples:
- https://github.com/envygeeks/docker
- https://github.com/jekyll/docker

[e8fc4a6]: https://github.com/envygeeks/docker-template/commit/e8fc4a6524998d208cf595cf8c64465863548991
[fe24e40]: https://github.com/envygeeks/docker-template/commit/fe24e4062917868d8ea589c490cd5c9b0bf057a2
[a8b98dc]: https://github.com/envygeeks/docker-template/commit/a8b98dc9400d01573f9e333bb0877aa97cb7cf92
[c332908]: https://github.com/envygeeks/docker-template/commit/c3329088c639e5b9469e9ba45048f5123eedac84
[9c0940e]: https://github.com/envygeeks/docker-template/commit/9c0940e4b6db565ed63a669b8104ce907dd9e78c
