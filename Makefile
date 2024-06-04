.DEFAULT_GOAL := help

include .env

ifeq ($(shell which xmlstarlet),)
    $(error "xmlstarlet is not installed. Please install it before running the Makefile command.")
endif

MODULE_NAME := $(shell xmlstarlet sel -t -v "//module/@name" $(MODULE_PATH)/etc/module.xml)
MODULE := $(shell echo $(MODULE_NAME) | sed 's/_/\//g')

.PHONY: help build static-analysis performance-tests unit-tests integration-tests mtf-tests tests

help:
	@echo "This Makefile provides the following commands:"
	@echo "  make build               - Build the Docker containers"
	@echo "  make install             - Install Magento using the install_magento.sh script"
	@echo "  make sync-module         - Sync the module to the Magento instance"
	@echo "  make install-module      - Install the module in the Magento instance"
	@echo "  make static-analysis     - Run static analysis tests on the module"
	@echo "  make performance-tests   - Run performance tests on the module"
	@echo "  make unit-tests          - Run unit tests on the module"
	@echo "  make integration-tests   - Run integration tests on the module"
	@echo "  make mtf-tests           - Run MTF (Magento Testing Framework) tests on the module"
	@echo "  make tests               - Run all tests (static analysis, performance, unit, integration, MTF)"

build:
	@echo "🐳 Building Docker Containers (PHP: ${PHP_VERSION}, Magento: ${MAGENTO_VERSION}, OpenSearch: ${OPENSEARCH_VERSION}) "
	sleep 1
	docker-compose down --remove-orphans
	docker-compose up --always-recreate-deps --build --detach
	
install:
	@echo "🚀 Installing Magento ${MAGENTO_VERSION}..."
	sleep 1
	docker compose exec -T --user www-data -w /var/www/html php-fpm bash -c "$$(cat ./bin/install_magento.sh)"

sync-module:
	@echo "🔄 Syncing module to Magento instance..."
	docker exec --user root php-fpm-test rm -rf /var/www/html/app/code/
	docker exec --user root php-fpm-test mkdir -p /var/www/html/app/code/$(basename ${MODULE} | cut -d/ -f1)
	docker cp ${MODULE_PATH}/. php-fpm-test:/var/www/html/app/code/$(basename ${MODULE})

install-module: sync-module
	@echo "🚀 Installing module... ${MODULE_NAME}"
	docker exec php-fpm-test php -dmemory_limit=-1 bin/magento s:up
	docker exec php-fpm-test php -dmemory_limit=-1 bin/magento mod:status ${MODULE_NAME}

static-analysis:
	@echo "🔍 Running static analysis tests on the module..."
	docker compose exec magento bin/magento dev:tests:run static app/code/${MODULE}

performance-tests:
	@echo "🚀 Running performance tests on the module..."
	docker compose exec magento bin/magento dev:tests:run performance app/code/${MODULE}

unit-tests:
	@echo "🧪 Running unit tests on the module..."
	docker compose exec magento bin/magento dev:tests:run unit app/code/${MODULE}

integration-tests:
	@echo "🧪 Running integration tests on the module..."
	docker compose exec magento bin/magento dev:tests:run integration app/code/${MODULE}

mtf-tests:
	@echo "🧪 Running MTF (Magento Testing Framework) tests on the module..."
	docker compose exec magento bin/magento dev:tests:run mtf app/code/${MODULE}

tests: static-analysis performance-tests unit-tests integration-tests mtf-tests
	@echo "🎉 All tests passed!"
