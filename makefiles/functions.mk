define download_module
    @docker cp --quiet $(CONTAINER):/var/www/html/app/code/$(basename $(MODULE))/. $(MODULE_PATH)
endef

define build_containers
    @docker-compose down --remove-orphans
    @docker-compose up --always-recreate-deps --build --detach
endef

define install_magento
    @docker compose exec -T --user www-data -w /var/www/html php-fpm bash -c "$$(cat ./bin/install_magento.sh)"
endef

define copy_config
	@docker cp --quiet tests/unit/phpunit.xml.dist $(CONTAINER):/var/www/html/dev/tests/unit/phpunit.xml
	@docker cp --quiet tests/integration/phpunit.xml.dist $(CONTAINER):/var/www/html/dev/tests/integration/phpunit.xml
    @docker cp --quiet tests/integration/etc/install-config-mysql.php $(CONTAINER):/var/www/html/dev/tests/integration/etc/install-config-mysql.php
    @docker cp --quiet tests/integration/etc/config-global.php $(CONTAINER):/var/www/html/dev/tests/integration/etc/config-global.php
    @docker cp --quiet tests/rector.php $(CONTAINER):/var/www/html/rector.php
endef

define upload_module
    @docker exec --user root $(CONTAINER) rm -rf /var/www/html/app/code/
    @docker exec --user root $(CONTAINER) mkdir -p /var/www/html/app/code/$(basename $(MODULE) | cut -d/ -f1)
    @docker cp --quiet $(MODULE_PATH)/. $(CONTAINER):/var/www/html/app/code/$(basename $(MODULE))
endef

define install_module
    $(call upload_module)
    @docker exec $(CONTAINER) php -dmemory_limit=-1 bin/magento s:up
    @docker exec $(CONTAINER) php -dmemory_limit=-1 bin/magento mod:status $(MODULE_NAME)
endef

define package_module
    zip -r out/$$( \
        jq -r '.name + "-" + .version + ".zip"' "$(MODULE_PATH)/composer.json" \
        | sed 's/\//-/g' \
    ) "$(MODULE_PATH)" -x "$(MODULE_PATH)/.git/*"
    @echo "\033[32mPackage: out/$$( \
        jq -r '.name + "-" + .version + ".zip"' "$(MODULE_PATH)/composer.json" \
        | sed 's/\//-/g' \
    )\033[0m"
endef

define run_phpcs
    @docker run --rm -v $(PWD)/$(MODULE_PATH):/app/$(MODULE) \
        ghcr.io/rickdaalhuizen90/magento-coding-standard:latest \
        php magento-coding-standard/vendor/bin/phpcs \
        --standard=Magento2 \
        --extensions=php,phtml \
        --error-severity=10 \
        --ignore-annotations \
        --report=json \
        --report-file=report.json \
        $(MODULE)
endef

define run_phpcbf
    @docker run --rm -v $(PWD)/$(MODULE_PATH):/app/$(MODULE) \
        ghcr.io/rickdaalhuizen90/magento-coding-standard:latest \
        php magento-coding-standard/vendor/bin/phpcbf \
        --standard=Magento2 \
        --extensions=php,phtml \
        --ignore-annotations \
        $(MODULE)
endef

define run_performance_tests
    @docker exec $(CONTAINER) bin/magento dev:tests:run performance app/code/$(MODULE)
endef

define run_unit_tests
    @docker exec -it --user root $(CONTAINER) ./vendor/bin/phpunit --migrate-configuration -c dev/tests/unit/phpunit.xml app/code/$(MODULE)/Test/Unit
endef

define run_integration_tests
    @docker exec -it --user root $(CONTAINER) ./vendor/bin/phpunit --testsuite "Third Part Integration Tests" app/code/$(MODULE)/Test/Integration
endef

define run_rector
	@docker exec -it --user root $(CONTAINER) ./vendor/bin/rector process app/code/
endef

define run_mtf_tests
    @docker compose exec magento bin/magento dev:tests:run mtf app/code/$(MODULE)
endef
