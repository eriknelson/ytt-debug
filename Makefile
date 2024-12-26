.PHONY: coredns-img

coredns-manifest:
	ytt \
		-f base/schema/distro.yml \
		-f base/values/alpine.distro.yml \
		-f base/templates/distro.yml \
		-f common/schema/common.yml \
		-f common/values/alpine.common.yml \
		-f common/templates/common.yml

_common-manifest:
	@ytt \
		-f common/schema/common.yml \
		-f common/values/alpine.common.yml \
		-f common/templates/common.yml

_base-manifest:
	@ytt \
		-f base/schema/distro.yml \
		-f base/values/alpine.distro.yml \
		-f base/templates/distro.yml
