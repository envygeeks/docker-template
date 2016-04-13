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
