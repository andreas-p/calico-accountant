all: build

ENVVAR = GOOS=linux GOARCH=amd64
TAG = v0.1.8
APP_NAME = calico-accountant
REPO = andreas-p
IMAGE_TAG = $(REPO)/$(APP_NAME):$(TAG)

clean:
	rm -f $(APP_NAME)

fmt:
	find . -path ./vendor -prune -o -name '*.go' -print | xargs -L 1 -I % gofmt -s -w %

build: clean fmt
	$(ENVVAR) CGO_ENABLED=0 go build -o $(APP_NAME)

test-unit: clean fmt build
	CGO_ENABLED=0 go test -v -cover ./...

# Make the container using docker multi-stage build process
# So you don't necessarily have to install golang to make the container
container:
	docker build -f Dockerfile -t $(IMAGE_TAG) .


binary: container
	docker run --rm $(IMAGE_TAG) cat /calico-accountant >$(APP_NAME)

.PHONY: all clean fmt build container
