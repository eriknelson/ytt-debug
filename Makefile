.PHONY: coredns-img

DISTRO := alpine
BUILD_DIR := _build

coredns-manifest: common-manifest
	ytt \
		-f ${BUILD_DIR}/common.yml \
		-f ytt-shared/ \
		-f img/coredns/ \
		> ${BUILD_DIR}/coredns.yml

common-manifest: base-manifest
	ytt \
		-f ${BUILD_DIR}/base.yml \
		-f ytt-shared/ \
		-f common/config \
		-f common/values/$(DISTRO).common.yml \
		> ${BUILD_DIR}/common.yml

base-manifest:
	mkdir -p ${BUILD_DIR}
	ytt \
		-f base/config \
		-f base/values/$(DISTRO).distro.yml \
		> ${BUILD_DIR}/base.yml

clean:
	rm -rf _build
