# Change Log

All notable changes to this project will be documented in this file. This
project adheres to [Semantic Versioning](http://semver.org/).

## 0.1.0
### Added
- Building images: `docker-template repo repo`.
- The ability to push to Docker hub: `docker-template --push`.
- The ability to store contexts for Docker Hub: `docker-template --sync`.
- Support for building specific tags, specific repos or everything. `docker-template user/name:tag name:tag name`.
- The ability to wrap Docker by symlinking `docker` to `docker-template`.
- The ability to do complex builds with types, tags, and global options.
- The ability to have global and per repo configurations.
- Scratch and simple images for your pleasure.
- On the fly tagging for simple images.
- The ability to alias tags.

#### This release comes with examples:
- https://github.com/envygeeks/docker
- https://github.com/jekyll/docker
