

.PHONY: all
all: build

.PHONY: build
build: build/jbs build/jahbs


build/jbs:
	@mkdir -p build
	go build -o build/jbs client/jbs/main.go

build/jahbs:
	@mkdir -p build
	go build -o build/jahbs server/jahbs/main.go

.PHONY: clean
clean:
	rm -rf build
