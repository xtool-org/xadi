.PHONY: build
build:
ifeq ($(shell uname), Darwin)
	./macOS/build.sh
else
	./Linux/build.sh
endif

.PHONY: test
test: build tmp/adi-lib
	swift test --package-path test --scratch-path $$PWD/.build

.PHONY: libs
libs:
	@+$(MAKE) -B tmp/adi-lib

tmp/adi-lib:
	@rm -rf tmp/adi-lib tmp/adi-lib-stage
	@mkdir -p tmp/adi-lib-stage/out
	curl https://apps.mzstatic.com/content/android-apple-music-apk/applemusic.apk -o tmp/adi-lib-stage/applemusic.apk
	unzip -oq tmp/adi-lib-stage/applemusic.apk -d tmp/adi-lib-stage \
		"lib/*/libCoreADI.so" \
		"lib/*/libstoreservicescore.so"
	@mv tmp/adi-lib-stage/lib tmp/adi-lib
	@rm -rf tmp/adi-lib-stage

.PHONY: test-docker
test-docker:
	docker build -t xadi-test .
	docker rmi xadi-test
	@echo "Test passed"
