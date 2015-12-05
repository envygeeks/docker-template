[![Build Status](https://travis-ci.org/envygeeks/docker-template.svg?branch=master)][travis]
[![Test Coverage](https://codeclimate.com/github/envygeeks/docker-template/badges/coverage.svg)][coverage]
[![Code Climate](https://codeclimate.com/github/envygeeks/docker-template/badges/gpa.svg)][codeclimate]

[codeclimate]: https://codeclimate.com/github/envygeeks/docker-template
[coverage]: https://codeclimate.com/github/envygeeks/docker-template/coverage
[travis]: https://travis-ci.org/envygeeks/docker-template

# Docker Template

Docker template is a way to organize your Docker repos into multiple types with
multiple templates for multiple tags but those templates aren't actually templates,
they are JSON or YAML files and copy folders with tons of shared or split data.
The idea is that you can have many tags for a single repo and that each tag
can have many different things going on.

Docker template makes it so that you can facilitate and organize those things in
a clean way and just get work done.  It also makes building "scratch" images 100%
easier for anybody by doing most of the work for you and just asking that you
build the file system script that pumps out a tar.gz file.
