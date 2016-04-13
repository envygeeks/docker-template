# Copy

Copy is a set of data that will be copied into the final image.  We do not copy this on your behalf, we simply setup the context and create a `copy/` directory that you copy yourself via your Dockerfile (or in the case of a scratch image from the `$COPY_DIR`.)

<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Copy](#copy)
	- [Organization](#organization)
		- [Layout](#layout)
	- [Access](#access)
	- [Symlinks](#symlinks)

<!-- /TOC -->

## Organization

The `copy/` directory is queryable.  Data is organized for all, by tag, and by group.  So looking at one of your repos it's copy directory would look like this:

```
copy/
  all/
    usr/local/bin
      hello
  tag
    latest/
      usr/local/bin
        world
```

### Layout

Data is laid out how you wish it to be copied.  So if you wish there to be a file inside of `/usr/local/bin` then you lay it out from the queryable folder into that position and it will be copied to `/usr/local/bin` when the Dockerfile or does `COPY copy /`.  ***Technically you can lay out your data any way you wish, we do not enforce any organization on it other than it be queryable, at the end of the day you can setup your copy of copy any way you wish.***

## Access

Inside of a normal Dockerfile you cannot access the data unless you copy it ***before*** you run your commands.  However, within `rootfs.erb` on a scratch image, you can access the data from `$COPY_DIR` environment variable because the data is mounted into the image building your final image so you can copy it.

## Symlinks

You can symlink to any data within the root of your base folder (the folder that holds your `repos/` directory.)  Any data outside of that folder will throw a security error (permission error.)  We do not and have no plans to support data being symlinked from everywhere, we feel that symlinking only allows you to organize your data within your own directory much cleaner without breaking the way Docker currently behaves. ***Symlinks are resolved recursively so if your symlinks have symlinks we will continiously resolve them on your behalf making them real files until we have no more symlinks.***
