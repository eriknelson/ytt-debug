# LXC Images (using ytt Libraries)

## Overview

This library produces YAML documents in the shape of LXC image manifests.

This is done by invoking a Makefile target:

```
make <target>
```

Each target invokes `ytt` that...

1. renders an "image" (see `config/schema.yml:/image`)
2. overlays a "distro" configuration (see `config/schema.yml:/distro`)
3. overlays zero or more "package sets" (see `config/schema.yml:/package_sets`)

The target identifies configuration for each layer by including the corresponding `ytt` Data Values file:

- `values/image/`
- `values/distro/`
- `values/package-sets/`  

For example:

```Makefile
coredns:
	ytt -f config \
		-f values/distro/alpine-3.20.yml \
		-f values/image/coredns.yml \
		-f values/package-sets/common.yml
```
where:
- `-f config` includes the `ytt` library that templates and overlays the YAML fragments
- `-f values/` entries name Data Values files that set the configuration for each layer

## How to ...

### How to declare a new LXC image manifest

1. Define image-specific details in a Data Values file: 

   Add a new `ytt` Data Values file in `values/image/` (see `config/schema.yml:/image` for the schema).

   For example, to define the base manifest for an Nginx server:
   ```yaml
   #! values/image/nginx.yml
   #@data/values
   ---
   image:
     name: nginx
     description: Defacto standard web server
     packages:
       - nginx
   ```

2. Define a new build target, using the new image:

   Add a new **Makefile target** that names the new image **Data Value**s file.

   ```Makefile
   nginx:
     ytt -f config \
       -f values/distro/alpine-3.20.yml \
       -f values/image/nginx.yml
   ```
   _(Stating the obvious: we need to include a distribution must in order to produce a complete LXC image manifest; in this example, Alpine Linux 3.20 is used.)_

### How to add a brand new distro

1. Define the distro in the "distro" `ytt` Library:

   Add a new `ytt` Data Values file in `config/_ytt_lib/distro/definitions/` (see `.../distro/schema.yml:/distro_definitions` for the schema)

   For example, to define Linux 21:
   ```yaml
   #! config/_ytt_lib/distro/definitions/mint.yml
   #@data/values
   ---
   distro_definitions:
     - distribution: mint
       source:
         downloader: debian
         url: http://packages.linuxmint.com/
         keys:
           - 9F8A7B6C5D4E3F2A1B0C9D8E7F6A5B4C3D2E1F0A
       package_manager: apt
   ```

2. For each version you would want to reference, add a Data Values file selecting the distro and giving the version.

   Add a new `ytt` Data Values file in `values/distro/` (see `config/schema.yml:/distro` for the schema):

   ```yaml
   #! values/distro/mint-21.yml
   #@data/values
   ---
   distro:
    name: mint
    release: "21"
   ```

3. In a build target, reference the new distro:

   ```Makefile
   nginx:
     ytt -f config \
       -f values/distro/mint-21.yml \
       -f values/image/nginx.yml
   ```

### How to add a new version of an existing distro

1. Add a new Data Values file in `values/distro/` (see `config/schema.yml:/distro` for the schema):

   ```yaml
   #! values/distro/mint-20.yml
   #@data/values
   ---
   distro:
     name: mint
     release: "20"
   ```

2. In a build target, reference the new distro:

   ```Makefile
   nginx:
     ytt -f config \
       -f values/distro/mint-20.yml \
       -f values/image/nginx.yml
   ```

### How to add a new package set

1. Define the package set in the "package-sets" `ytt` Library:

   Add a new `ytt` Data Values file in `config/_ytt_lib/package-sets/definitions/` (see `.../package-sets/schema.yml:/package_set_definitions` for the schema)

   For example, to define a package set for network debugging tools:
   ```yaml
   #! config/_ytt_lib/package-sets/definitions/network-debugging.yml
   #@data/values
   ---
   package_set_definitions:
     - name: network-debugging
       description: Network debugging tools
       packages:
         - tcpdump
         - wireshark
   ```

2. Add a new Data Values file in `values/package-sets/` (see `config/schema.yml:/package_sets` for the schema):

   ```yaml
   #! values/package-sets/network-debugging.yml
   #@data/values
   ---
   package_sets:
     - name: network-debugging
   ```

3. In a build target, reference the new package set:

   ```Makefile
   nginx:
     ytt -f config \
       -f values/distro/mint-21.yml \
       -f values/image/nginx.yml \
       -f values/package-sets/network-debugging.yml
   ```

