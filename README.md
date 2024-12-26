# Use Case

I'm working to build several different LXC based container images, which are
defined with a yaml spec. Becuase I'll have a library of these images, often
with a lot of shared configuration, I need a solution for building this shared
library and the ultimate manifests while keeping things DRY. I'm used to
kustomize and other templating solutions, but the real need here is just yaml,
and I need something more sophisticated than yq. ytt looks like it is perfect
for my needs.

# Current layout

Project that is stripped down to the core elements of the question with a
reproducible case.

[link](https://github.com/eriknelson/ytt-debug)

`make coredns-manifest` is what I'm hoping to be my complete target.

`make _base-manifest` & `make _common-manifest` will each compile yaml fragments
of each layer independently.

## Templates

I'm having some trouble groking the idiomatic means of doing this with ytt
and determining what the correct features would be to use to accomplish this
(functions, modules, templates, or overlays)?

This is not an issue that really has anything to do with distrobuilder, so
anything to do with that is generally out of scope for this issue. Here's
how I'm thinking about it:

* **Base**: With LXC, there are a handful of base distros that can be utilized as the
base of the image. The schema of its specification is the same, but the values
differ, so I believe this is a natural fit for schema+values files, and
templating.
* **Common**: With each base image, I'm going to want some basic set of packages that are
just my preference for working inside of the container, maybe I have some
scripts I want to install etc.
* **Workload**: This is the layer that brings in the specifics of the purpose
of the image, usually configuration and the specific package. CoreDNS falls
into this bucket.

As i"m putting this together, **each layer is probably going to have templated
fields** that I'd like to keep in a values file, and verify with a values
schema file. Each layer ends up being composed of a schema + values + template
file. Each of these can, and should get rendered independent of one
another. **A lower layer shouldn't have any knowledge of layers that will
be overlayed on top of it**.

## Overlays

The ultimate file is a composition of these layers on top of one another,
ultimately ending up at the final image definition. I'd like to be able to
overlay them with descending precedence:

`workload > common > base`

I will also need the ability to annotate my desired merging behavior sometimes
on an array node basis, i.e. concat array items, concat array items but drop
any duplication (this is effectively a set) etc.

# Problems & Questions

* First of all, am I thinking about this in the correct manner? I do NOT want
to "fight the framework", so I'd like to do this in the idiomatic ytt manner.
* It's not clear to me what order these files should be passed when running
the command; should I be passing all schemas in order, then all values, then
all the templates, or should I be passing schema > values > template in order
of each layer?
* I'm getting errors either way, but currently I'm attempting to render each
"triplicate" in order of least specific to most specific. I'm running into
the following error with this approach:

```
# make coredns-manifest
ytt \
        -f base/schema/distro.yml \
        -f base/values/alpine.distro.yml \
        -f base/templates/distro.yml \
        -f common/schema/common.yml \
        -f common/values/alpine.common.yml \
        -f common/templates/common.yml \
        -f img/coredns/img.yml
ytt: Error: Overlaying data values schema (in following order: distro.yml, common.yml):
  Document on line common.yml:2:
    Map item (key 'common_packages') on line common.yml:3:
      Expected number of matched nodes to be 1, but was 0
make: *** [Makefile:4: coredns-manifest] Error 1

```

The details are in the linked project, but I suspect the issue here is it's
trying to apply the aggregation of all the schemas first, and because the
`distro.yml` file has none of the nodes that the `common.yml` schema declares
it's producing the error. I'm not sure about this though since the error
is really quite opaque. I'm also not certain I have a grasp over the ytt
fundamentals at a depth that's required to accomplish what I'm trying to do.
However, as mentioned before, there's no reason that I should have higher layers
bleed their information into lower layers; the entire point is for a lower
layer to have no knowledge over what's getting layered on top of it.

I'm 99% sure that ytt is the right tool for this job, I'm just hitting a wall
trying to wrap my head around the "right" manner to do it. Is someone able
to point me in the right direction? TYIA.
