#
# See ./CONTRIBUTING.rst
#

OS := $(shell uname)
.PHONY: help
.DEFAULT_GOAL := help

HAS_PIP := $(shell command -v pip;)
HAS_PIPENV := $(shell command -v pipenv;)

ifdef HAS_PIPENV
	PIPENV_RUN:=pipenv run
	PIPENV_INSTALL:=pipenv install
else
	PIPENV_RUN:=
	PIPENV_INSTALL:=
endif

TEAM := equipindustry
AWS_VAULT ?= luismayta
PROJECT := tsconfig
PROJECT_PORT := 3000

PYTHON_VERSION=3.8.0
PYENV_NAME="${PROJECT}"

# Configuration.
SHELL ?=/bin/bash
ROOT_DIR=$(shell pwd)
MESSAGE:=🍺️
MESSAGE_HAPPY:="Done! ${MESSAGE}, Now Happy Hacking"
SOURCE_DIR=$(ROOT_DIR)/
PROVISION_DIR:=$(ROOT_DIR)/provision
FILE_README:=$(ROOT_DIR)/README.rst
KEYBASE_VOLUME_PATH ?= /Keybase
KEYBASE_PATH ?= ${KEYBASE_VOLUME_PATH}/team/${TEAM}
KEYS_PEM_DIR:=${KEYBASE_PATH}/pem
KEYS_KEY_DIR:=${KEYBASE_PATH}/key
KEYS_PUB_DIR:=${KEYBASE_PATH}/pub
KEYS_PRIVATE_DIR:=${KEYBASE_PATH}/private/key_file/${PROJECT}
PASSWORD_DIR:=${KEYBASE_PATH}/password

include provision/make/*.mk

help:
	@echo '${MESSAGE} Makefile for ${PROJECT}'
	@echo ''
	@echo 'Usage:'
	@echo '    environment               create environment with pyenv'
	@echo '    setup                     install requirements'
	@echo ''
	@make docs.help
	@make test.help


setup:
	@echo "=====> install packages..."
	pyenv local ${PYTHON_VERSION}
	yarn
	$(PIPENV_INSTALL) --dev --skip-lock
	$(PIPENV_RUN) pre-commit install
	$(PIPENV_RUN) pre-commit install -t pre-push
	@cp -rf provision/git/hooks/prepare-commit-msg .git/hooks/
	@[ -e ".env" ] || cp -rf .env.example .env
	@echo ${MESSAGE_HAPPY}

environment:
	@echo "=====> loading virtualenv ${PYENV_NAME}..."
	pyenv local ${PYTHON_VERSION}
	@pipenv --venv || $(PIPENV_INSTALL) --skip-lock --python=${PYTHON_VERSION}
	@echo ${MESSAGE_HAPPY}
