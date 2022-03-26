# Just a Makefile for manual testing

include .env

.PHONY: all

all: clean build

clean:
	rm -rf tmp

build: tmp/output/target/${packageName}-${packageVersion}.war

tmp/output/target/${packageName}-${packageVersion}.war:
	./template.sh ./bundle.yml > ./bundle-result.yml
	java \
	    -jar $(shell ls ./cwp-*.jar) \
	    -configPath ./bundle-result.yml -version ${packageVersion}

run: tmp/output/target/${packageName}-${packageVersion}.war
	docker run --rm \
	    -p 8080:8080 \
	    jenkins-experimental/demo-pom-input

debug:
	docker-compose up
