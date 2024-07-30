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

.PHONY: help setup build install copy-config upload install-module package ssh all phpstan psalm phan phpcs phpmd static-code-analysis phpcbf rector format-code unit-tests integration-tests mtf-tests performance-tests tests

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  setup                Full setup: build, install, config, upload, install-module"
	@echo "  build                Build Docker containers"
	@echo "  install              Install Magento in the container"
	@echo "  copy-config          Sync configuration files"
	@echo "  upload               Upload the module to Magento"
	@echo "  install-module       Install the module in Magento"
	@echo "  package              Package the module"
	@echo "  ssh                  SSH into the container as root"
	@echo "  all                  Full process: setup, format-code, static-code-analysis, tests"
	@echo ""
	@echo "Static Code Analysis:"
	@echo "  phpstan              Run PHPStan"
	@echo "  psalm                Run Psalm"
	@echo "  phan                 Run Phan"
	@echo "  phpcs                Run PHPCS"
	@echo "  phpmd                Run PHPMD"
	@echo "  static-code-analysis Run all static analysis tools"
	@echo ""
	@echo "Code Formatting:"
	@echo "  phpcbf               Run PHPCBF"
	@echo "  rector               Run Rector"
	@echo "  format-code          Format code using all tools"
	@echo ""
	@echo "Testing:"
	@echo "  unit-tests           Run unit tests"
	@echo "  integration-tests    Run integration tests"
	@echo "  mtf-tests            Run MTF tests"
	@echo "  performance-tests    Run performance tests"
	@echo "  tests                Run all tests"

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
