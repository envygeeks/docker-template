# Change Log

All notable changes to this project will be documented in this file. This
project adheres to [Semantic Versioning](http://semver.org/).

## [UNRELEASED]
#### Added
- Added a User-Agent so Docker and other stuff can identify our software. [[8dde7fa][8dde7fa]]
- Move `dockerhub_copy` to `dockerhub_cache`; add `dockerhub_cache_dir` so you can set the folder name. [[c8ead9e][c8ead9e]]
- Added support for naming a repo different than the folder name.  Use `name` in opts.yml. [[70eee80][70eee80]]
- Added a default timeout of 480 to Excon. [[8dde7fa][8dde7fa]]

#### Changed
- Move to using `envygeeks/ubuntu:latest` instead of `envygeeks/ubuntu:tiny` [[7a53643][7a53643]]
- Remove `Util#get_context` because we always copy the context anyways. [[f998d11][f998d11]]

#### Fixed
- Make sure RSpec helpers is always available first. [[f42bcf0][f42bcf0]]
- Fix detection of directory is repo, it should use the *current directory* not 2 directories back. [[53b720e][53b720e]]

## 0.2.0
#### Added
- A Git repo with only one repo can now act as repos. [[0b2ce57][0b2ce57]]
- Add `Metadata#as_gem_version` which merges the repo name with the version in `Metadata` [[35df281][35df281]]
- Account for a user not having our specific keys in some places. [[9a0e4fb][9a0e4fb]]
- Clean up code in various ways. [[4d39ad7][4d39ad7]]

#### Changed
- Added CodeClimate platform. [[9c0940e][9c0940e]]
- Added RuboCop to CodeClimate platform. [[c332908][c332908]]

## 0.1.2
#### Changed
- Make sure bin/docker-template is available in the gem: [[fe24e40][fe24e40]]
- Make sure the CodeClimate link is correct: [[a8b98dc][a8b98dc]]

## 0.1.0
#### Added
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
[0b2ce57]: https://github.com/envygeeks/docker-template/commit/0b2ce5723d04112ba389831770c6ecd3e7f2dbce
[35df281]: https://github.com/envygeeks/docker-template/commit/35df281accd797afca1d6aafc6b82409d179dd01
[4d39ad7]: https://github.com/envygeeks/docker-template/commit/4d39ad7d95cde33aaf8f01178dbe73a9f1f14e73
[9a0e4fb]: https://github.com/envygeeks/docker-template/commit/9a0e4fb79405966f0fae288d6c9e7f38a80d764a
[53b720e]: https://github.com/envygeeks/docker-template/commit/53b720e1c6e8af6db65e6af7e5c59c86e2bd1d66
[8dde7fa]: https://github.com/envygeeks/docker-template/commit/8dde7fa9fd0867abf6602b87c28ff261adc2d06b
[70eee80]: https://github.com/envygeeks/docker-template/commit/70eee80907daec1a8b45207e3029b95c042204e6
[c8ead9e]: https://github.com/envygeeks/docker-template/commit/c8ead9e365e7dfc98555b1dedd7a5330790aec0c
[f42bcf0]: https://github.com/envygeeks/docker-template/commit/f42bcf097b03ccaf8f00dd09beb63c5bd84f1c93
[7a53643]: https://github.com/envygeeks/docker-template/commit/7a536431264dd726e087c860a05d0fdedb6a7410
[f998d11]: https://github.com/envygeeks/docker-template/commit/f998d11287365b236ef1f31634cc2661b529ba9f
