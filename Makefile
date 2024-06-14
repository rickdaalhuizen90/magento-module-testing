.DEFAULT_GOAL := help

include .env

ifeq ($(shell which xmlstarlet),)
    $(error "xmlstarlet is not installed. Please install it before running the Makefile command.")
endif

MODULE_NAME := $(shell xmlstarlet sel -t -v "//module/@name" $(MODULE_PATH)/etc/module.xml)
MODULE := $(shell echo $(MODULE_NAME) | sed 's/_/\//g')
CONTAINER := php-fpm-test

.PHONY: help build static-analysis performance-tests unit-tests integration-tests mtf-tests tests

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
	@echo "🐳 Building Docker Containers (PHP: ${PHP_VERSION}, Magento: ${MAGENTO_VERSION}, OpenSearch: ${OPENSEARCH_VERSION}) "
	sleep 1
	docker-compose down --remove-orphans
	docker-compose up --always-recreate-deps --build --detach
	
install:
	@echo "🚀 Installing Magento ${MAGENTO_VERSION}..."
	sleep 1
	docker compose exec -T --user www-data -w /var/www/html php-fpm bash -c "$$(cat ./bin/install_magento.sh)"

upload:
	@echo "⬆️ Upload module to Magento instance..."
	docker exec --user root $CONTAINER rm -rf /var/www/html/app/code/
	docker exec --user root $CONTAINER mkdir -p /var/www/html/app/code/$(basename ${MODULE} | cut -d/ -f1)
	docker cp ${MODULE_PATH}/. $CONTAINER:/var/www/html/app/code/$(basename ${MODULE})

download:
	@echo "⬇️ Download module from Magento instance..."
	docker cp $CONTAINER:/var/www/html/app/code/$(basename ${MODULE})/. ${MODULE_PATH}

install-module: upload
	@echo "🚀 Installing module... ${MODULE_NAME}"
	docker exec $CONTAINER php -dmemory_limit=-1 bin/magento s:up
	docker exec $CONTAINER php -dmemory_limit=-1 bin/magento mod:status ${MODULE_NAME}

package:
	@echo "📦 Packaging module..."
	@sh ./bin/package.sh ${MODULE_PATH}
	@echo "🎉 Module packaged successfully!"

phpcs:
	@echo "🔍 Running static analysis tests on the module..."
	@docker run --rm -v $(PWD)/${MODULE_PATH}:/app/${MODULE} \
		magento-coding-standard-test \
		php magento-coding-standard/vendor/bin/phpcs \
		--standard=Magento2 \
		--extensions=php,phtml \
		--error-severity=10 \
		--ignore-annotations \
		--report=json \
		--report-file=report.json \
		${MODULE}

phpcbf:
	@echo "🔧 Fixing code issues..."
	@docker run --rm -v $(PWD)/${MODULE_PATH}:/app/${MODULE} \
		magento-coding-standard-test \
		php magento-coding-standard/vendor/bin/phpcbf \
         --standard=Magento2 \
         --extensions=php,phtml \
         --ignore-annotations \
		${MODULE}

rector:
	@echo "🐘 Running Rector..."
	@echo "TODO..."

performance-tests:
	@echo "🚀 Running performance tests on the module..."
	@docker exec $CONTAINER bin/magento dev:tests:run performance app/code/${MODULE}

unit-tests:
	@echo "🧪 Running unit tests on the module..."
	docker compose exec magento bin/magento dev:tests:run unit app/code/${MODULE}

integration-tests:
	@echo "🧪 Running integration tests on the module..."
	docker compose exec magento bin/magento dev:tests:run integration app/code/${MODULE}

mtf-tests:
	@echo "🧪 Running MTF (Magento Testing Framework) tests on the module..."
	docker compose exec magento bin/magento dev:tests:run mtf app/code/${MODULE}

tests: phpcbf performance-tests unit-tests integration-tests mtf-tests
	@echo "🎉 All tests passed!"
