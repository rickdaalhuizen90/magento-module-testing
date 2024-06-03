.DEFAULT_GOAL := help

MODULE := src/Vendor/Module

MODULE_CLEAN := $(patsubst ~%,%,$(patsubst ./%,%,$(MODULE)))
VENDOR := $(word 2,$(subst /, ,$(MODULE_CLEAN)))

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
	docker compose down --remove-orphans
	docker compose up --always-recreate-deps --build --detach
	
install:
	docker compose exec -T --user www-data -w /var/www/html php-fpm bash -c "$$(cat ./install_magento.sh)"

sync-module:
	docker exec --user root php-fpm-test rm -rf /var/www/html/app/code/
	docker exec --user root php-fpm-test mkdir -p /var/www/html/app/code/${VENDOR}
	docker cp ${MODULE}/ php-fpm-test:/var/www/html/app/code/${VENDOR}/

install-module: sync-module
	docker exec php-fpm-test php -dmemory_limit=-1 bin/magento s:up

static-analysis:
	docker compose exec magento bin/magento dev:tests:run static app/code/$$(basename ${MODULE})

performance-tests:
	docker compose exec magento bin/magento dev:tests:run performance app/code/$$(basename ${MODULE})

unit-tests:
	docker compose exec magento bin/magento dev:tests:run unit app/code/$$(basename ${MODULE})

integration-tests:
	docker compose exec magento bin/magento dev:tests:run integration app/code/$$(basename ${MODULE})

mtf-tests:
	docker compose exec magento bin/magento dev:tests:run mtf app/code/$$(basename ${MODULE})

tests: static-analysis performance-tests unit-tests integration-tests mtf-tests
