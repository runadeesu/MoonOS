.PHONY: deps iso verify clean distclean

deps:
	./scripts/install-build-deps.sh

iso:
	./scripts/build.sh

verify:
	./scripts/verify.sh

clean:
	lb clean --purge || true
	rm -rf .build binary cache chroot

distclean: clean
	rm -rf dist
