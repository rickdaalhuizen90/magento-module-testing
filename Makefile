.DEFAULT_GOAL := help

include .env

ifeq ($(shell which xmlstarlet),)
    $(error "xmlstarlet is not installed. Please install it before running the Makefile command.")
endif

MODULE_NAME := $(shell xmlstarlet sel -t -v "//module/@name" $(MODULE_PATH)/etc/module.xml | head -n 1)
MODULE := $(shell echo $(MODULE_NAME) | sed 's/_/\//g')
CONTAINER := php-fpm-test

include makefiles/functions.mk

.PHONY: help build install copy-config upload install-module package phpstan psalm phan phpcs phpcbf performance-tests unit-tests integration-tests rector mtf-tests setup format-code static-code-analysis tests all

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "[General]"
	@echo "  build                   - Build the Docker containers"
	@echo "  install                 - Install Magento in the Docker container"
	@echo "  copy-config             - Sync configuration files to the Docker container"
	@echo "  upload                  - Upload the module to the Magento instance"
	@echo "  install-module          - Install the module in the Magento instance"
	@echo "  package                 - Package the module into a zip file"
	@echo "  all                     - Run all targets (build, install, format-code, static-code-analysis, tests)"
	@echo ""
	@echo "[Static Code Analysis]"
	@echo "  phpstan                 - Run PHPStan analysis"
	@echo "  psalm                   - Run Psalm analysis"
	@echo "  phan                    - Run Phan analysis"
	@echo "  phpcs                   - Run PHP CodeSniffer checks"
	@echo "  phpmd                   - Run PHP Mess Detector checks"
	@echo "  static-code-analysis    - Run all static code analysis checks"
	@echo ""
	@echo "[Code Style]"
	@echo "  phpcbf                  - Run PHP Code Beautifier and Fixer"
	@echo "  rector                  - Run Rector code refactoring"
	@echo "  format-code             - Run all code formatting tools"
	@echo ""
	@echo "[Testing]"
	@echo "  performance-tests       - Run performance tests on the module"
	@echo "  unit-tests              - Run unit tests on the module"
	@echo "  integration-tests       - Run integration tests on the module"
	@echo "  mtf-tests               - Run MTF (Magento Testing Framework) tests on the module"
	@echo "  tests                   - Run all tests on the module"


build:
	@echo "🐳 Building Docker Containers (PHP: ${PHP_VERSION}, Magento: ${MAGENTO_VERSION}, OpenSearch: ${OPENSEARCH_VERSION})"
	$(call build_containers)

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

package:
	@echo "📦 Packaging module..."
	$(call package_module)
	@echo "🎉 Module packaged successfully!"

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

phpcbf:
	@echo "🔧 Auto-fixing code (PHPCBF)..."
	$(call run_phpcbf)

performance-tests:
	@echo "🚀 Running performance tests on the module..."
	$(call run_performance_tests)

rector:
	@echo "🔧 Running Rector..."
	$(call upload_module)
	$(call run_rector)
	$(call download_module)

unit-tests:
	@echo "🧪 Running unit tests on the module..."
	$(call run_unit_tests)

integration-tests:
	@echo "🧪 Running integration tests on the module..."
	$(call run_integration_tests)

mtf-tests:
	@echo "🧪 Running MTF (Magento Testing Framework) tests on the module..."
	$(call run_mtf_tests)

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
