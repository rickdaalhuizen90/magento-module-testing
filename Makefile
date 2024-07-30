.DEFAULT_GOAL := help

include .env

# Ensure necessary tools are installed
ifeq ($(shell which xmlstarlet),)
    $(error "xmlstarlet is not installed. Please install it before running the Makefile command.")
endif

# Extract module details
MODULE_XML := $(MODULE_PATH)/etc/module.xml
MODULE_NAME := $(shell xmlstarlet sel -t -v "//module/@name" $(MODULE_XML))
MODULE := $(subst _,/,$(MODULE_NAME))
CONTAINER := php-fpm-test

include makefiles/format-code.mk
include makefiles/general.mk
include makefiles/static-analysis.mk
include makefiles/tests.mk

.PHONY: help setup format-code static-code-analysis tests all

# ANSI color codes
RESET := \033[0m
BOLD := \033[1m
UNDERLINE := \033[4m
GREEN := \033[32m
YELLOW := \033[33m
BLUE := \033[34m
CYAN := \033[36m

help:
	@echo -e "${BOLD}${CYAN}Usage:${RESET} make ${UNDERLINE}target${RESET}"
	@echo ""
	@echo -e "${BOLD}${GREEN}[General Commands]${RESET}"
	@echo -e "  ${CYAN}setup${RESET}               	- Full setup process: build, install, copy-config, upload, install-module"
	@echo -e "  ${CYAN}build${RESET}               	- Build Docker containers"
	@echo -e "  ${CYAN}install${RESET}             	- Install Magento in the container"
	@echo -e "  ${CYAN}copy-config${RESET}         	- Sync configuration files"
	@echo -e "  ${CYAN}upload${RESET}              	- Upload the module to Magento"
	@echo -e "  ${CYAN}install-module${RESET}      	- Install the module in Magento"
	@echo -e "  ${CYAN}package${RESET}             	- Package the module"
	@echo -e "  ${CYAN}ssh${RESET}                   - SSH into the container as root"
	@echo -e "  ${CYAN}all${RESET}                 	- Full process: setup, format-code, static-code-analysis, tests"
	@echo ""
	@echo -e "${BOLD}${GREEN}[Static Code Analysis]${RESET}"
	@echo -e "  ${CYAN}phpstan${RESET}             	- Run PHPStan"
	@echo -e "  ${CYAN}psalm${RESET}               	- Run Psalm"
	@echo -e "  ${CYAN}phan${RESET}                	- Run Phan"
	@echo -e "  ${CYAN}phpcs${RESET}               	- Run PHPCS"
	@echo -e "  ${CYAN}phpmd${RESET}               	- Run PHPMD"
	@echo -e "  ${CYAN}static-code-analysis${RESET}	- Run all static analysis tools"
	@echo ""
	@echo -e "${BOLD}${GREEN}[Code Formatting]${RESET}"
	@echo -e "  ${CYAN}phpcbf${RESET}              	- Run PHPCBF"
	@echo -e "  ${CYAN}rector${RESET}              	- Run Rector"
	@echo -e "  ${CYAN}format-code${RESET}         	- Format code using all tools"
	@echo ""
	@echo -e "${BOLD}${GREEN}[Testing]${RESET}"
	@echo -e "  ${CYAN}unit-tests${RESET}          	- Run unit tests"
	@echo -e "  ${CYAN}integration-tests${RESET}   	- Run integration tests"
	@echo -e "  ${CYAN}mtf-tests${RESET}           	- Run MTF tests"
	@echo -e "  ${CYAN}performance-tests${RESET}   	- Run performance tests"
	@echo -e "  ${CYAN}tests${RESET}               	- Run all tests"

# High-level commands
setup: build install copy-config upload install-module
	@echo "🎉 Setup completed successfully!"

format-code: phpcbf rector
	@echo "🎉 Code formatting completed successfully!"

static-code-analysis: phpstan phpmd phpcs psalm phan
	@echo "🎉 Static code analysis completed successfully!"

tests: performance-tests unit-tests integration-tests mtf-tests
	@echo "🎉 All tests passed successfully!"

all: setup format-code static-code-analysis tests
	@echo "🎉 All targets completed successfully!"

build:
	@echo "🐳 Building Docker Containers (PHP: ${PHP_VERSION}, Magento: ${MAGENTO_VERSION}, OpenSearch: ${OPENSEARCH_VERSION})"
	$(call build_containers)

# General Commands
install:
	@echo "🚀 Installing Magento ${MAGENTO_VERSION}..."
	$(call install_magento)

copy-config:
	@echo "🔄 Syncing configuration files..."
	$(call copy_config)

upload:
	@echo "⬆️ Upload module to Magento instance..."
	$(call upload_module)

install-module:
	@echo "🚀 Installing module: ${MODULE_NAME}..."
	$(call install_module)

ssh:
	@echo "🔐 SSH into the Docker container as root..."
	@docker exec -it --user root php-fpm-test bash

package:
	@echo "📦 Packaging module..."
	$(call package_module)
	@echo "🎉 Module packaged successfully!"

# Static Analysis
phpstan:
	@echo "🔍 Analyzing with PHPStan..."
	$(call run_phpstan)

psalm:
	@echo "🔍 Checking with Psalm..."
	$(call run_psalm)

phan:
	@echo "🔍 Analyzing with Phan..."
	$(call run_phan)

phpmd:
	@echo "🧹 Running PHPMD..."
	$(call run_phpmd)

phpcs:
	@echo "🔍 Checking code style (PHPCS)..."
	$(call run_phpcs)

# Code Formatting
phpcbf:
	@echo "🔧 Auto-fixing code (PHPCBF)..."
	$(call run_phpcbf)

rector:
	@echo "🔧 Running Rector..."
	$(call upload_module)
	$(call run_rector)
	$(call download_module)

# Testing
performance-tests:
	@echo "🚀 Running performance tests on the module..."
	$(call run_performance_tests)
unit-tests:
	@echo "🧪 Running unit tests on the module..."
	$(call run_unit_tests)

integration-tests:
	@echo "🧪 Running integration tests on the module..."
	$(call run_integration_tests)

mtf-tests:
	@echo "🧪 Running MTF (Magento Testing Framework) tests on the module..."
	$(call run_mtf_tests)
