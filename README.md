[![Build Status](https://travis-ci.org/envygeeks/docker-template.svg?branch=master)][travis]
[![Test Coverage](https://codeclimate.com/github/envygeeks/docker-template/badges/coverage.svg)][coverage]
[![Code Climate](https://codeclimate.com/github/envygeeks/docker-template/badges/gpa.svg)][codeclimate]
[![Dependency Status](https://gemnasium.com/envygeeks/docker-template.svg)][gemnasium]

[gemnasium]: https://gemnasium.com/envygeeks/docker-template
[codeclimate]: https://codeclimate.com/github/envygeeks/docker-template
[coverage]: https://codeclimate.com/github/envygeeks/docker-template/coverage
[travis]: https://travis-ci.org/envygeeks/docker-template

# Docker Template

`docker-template` is a way to organize your Docker repositories into a single
`git` repo, they can even be templated, have shared data across all all of the
repositories and even template and data by tag, type and local global.

Docker template makes it so that you can facilitate and organize those things
in a clean way and just get work done.  It also makes building "scratch" images
100% easier for anybody by doing most of the work for you and just asking that
you build the file system script that pumps out a tar.gz file.
