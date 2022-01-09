# Just a Makefile for manual testing
.PHONY: all

ARTIFACT_ID = oes-jenkins
VERSION = v0.1.0-2.319.1-SNAPSHOT

all: clean build

clean:
	rm -rf tmp

build: tmp/output/target/${ARTIFACT_ID}-${VERSION}.war

tmp/output/target/${ARTIFACT_ID}-${VERSION}.war:
	java \
	    -jar $(shell ls ./cwp-*.jar) \
	    -configPath bundle.yml -version ${VERSION}

run: tmp/output/target/${ARTIFACT_ID}-${VERSION}.war
	docker run --rm \
	    -p 8080:8080 \
	    jenkins-experimental/demo-pom-input
