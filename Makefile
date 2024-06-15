.DEFAULT_GOAL := help

include .env

ifeq ($(shell which xmlstarlet),)
    $(error "xmlstarlet is not installed. Please install it before running the Makefile command.")
endif

MODULE_NAME := $(shell xmlstarlet sel -t -v "//module/@name" $(MODULE_PATH)/etc/module.xml)
MODULE := $(shell echo $(MODULE_NAME) | sed 's/_/\//g')
CONTAINER := php-fpm-test

include makefiles/functions.mk

.PHONY: help build install upload download install-module package phpcs phpcbf performance-tests unit-tests integration-tests mtf-tests tests

help:
	@echo "This Makefile provides the following commands:"
	@echo "  make build               - Build the Docker containers"
	@echo "  make install             - Install Magento using the install_magento.sh script"
	@echo "  make package             - Package the module into a zip file"
	@echo "  make upload              - Upload the module to the Magento instance"
	@echo "  make download            - Download the module from the Magento instance"
	@echo "  make install-module      - Install the module in the Magento instance"
	@echo "  make phpcs               - Run static analysis tests on the module"
	@echo "  make phpcbf              - Fix code issues in the module"
	@echo "  make performance-tests   - Run performance tests on the module"
	@echo "  make unit-tests          - Run unit tests on the module"
	@echo "  make integration-tests   - Run integration tests on the module"
	@echo "  make mtf-tests           - Run MTF (Magento Testing Framework) tests on the module"
	@echo "  make tests               - Run all tests (static analysis, performance, unit, integration, MTF)"

build:
	@echo "🐳 Building Docker Containers (PHP: ${PHP_VERSION}, Magento: ${MAGENTO_VERSION}, OpenSearch: ${OPENSEARCH_VERSION})"
	$(call build_containers)

install:
	@echo "🚀 Installing Magento ${MAGENTO_VERSION}..."
	$(call install_magento)

upload:
	@echo "⬆️ Upload module to Magento instance..."
	$(call upload_module)

download:
	@echo "⬇️ Download module from Magento instance..."
	$(call download_module)

install-module:
	@echo "🚀 Installing module... ${MODULE_NAME}"
	$(call install_module)

package:
	@echo "📦 Packaging module..."
	$(call package_module)
	@echo "🎉 Module packaged successfully!"

phpcs:
	@echo "🔍 Running static analysis tests on the module..."
	$(call run_phpcs)

phpcbf:
	@echo "🔧 Fixing code issues..."
	$(call run_phpcbf)

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

tests: phpcs performance-tests unit-tests integration-tests mtf-tests
	@echo "🎉 All tests passed successfully!"