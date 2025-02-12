.PHONY: coredns-img

coredns:
	ytt -f config \
		-f values/distro/alpine-3.20.yml \
		-f values/image/coredns.yml \
		-f values/package-sets/common.yml \
		-f values/package-sets/debug.yml

haproxy:
	ytt -f config \
		-f values/distro/ubuntu-noble.yml \
		-f values/image/haproxy.yml \
		-f values/package-sets/common.yml

