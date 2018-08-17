export GIT_DEPLOY_DIR=_build

# empty step to avoid accidental deployment
.PHONY: all
all:

.PHONY: deploy
deploy:
	./bin/deploy.sh
