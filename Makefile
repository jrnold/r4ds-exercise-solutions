RSCRIPT ?= Rscript

export GIT_DEPLOY_DIR=_build

# empty step to avoid accidental deployment
.PHONY: all
all:

.PHONY: build
build:
	$(RSCRIPT) bin/render.R

.PHONY: test
test:
	npm test
	$(RSCRIPT) bin/check-spelling.R

.PHONY: deploy
deploy:
	./bin/deploy.sh

.PHONY: docker-build
docker-build: Dockerfile
	docker build -t r4ds-exercise-solutions .

.PHONY: docker-run
docker-render:
	docker --rm -v $(PWD):/r4ds-exercise-solutions
