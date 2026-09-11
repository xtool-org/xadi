.PHONY: build
build:
ifeq ($(shell uname), Darwin)
	./macOS/build.sh
else
	./Linux/build.sh
endif

.PHONY: test
test: build
	swift test --package-path test --scratch-path $$PWD/.build

.PHONY: test-docker
test-docker:
	docker build -t xadi-test .
	docker rmi xadi-test
	@echo "Test passed"
