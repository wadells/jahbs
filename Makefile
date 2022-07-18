

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

proto/api.pb.go: api.proto
	protoc --go_opt=Mapi.proto=github.com/wadells/jahbs/proto --go_opt=paths=source_relative --go_out=proto api.proto

.PHONY: clean
clean:
	rm -rf build
