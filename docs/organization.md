# Organization

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
