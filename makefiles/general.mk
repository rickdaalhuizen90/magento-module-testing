define download_module
    @docker cp --quiet $(CONTAINER):/var/www/html/app/code/$(basename $(MODULE))/. $(MODULE_PATH)
endef

define build_containers
    @docker compose down --remove-orphans
    @docker compose up --always-recreate-deps --build --detach
endef

define install_magento
    @docker exec -it --user root -w /var/www/html php-fpm-test bash -c "$$(cat ./bin/install_magento.sh)"
endef

define copy_config
	@docker cp --quiet tests/unit/phpunit.xml.dist $(CONTAINER):/var/www/html/dev/tests/unit/phpunit.xml
	@docker cp --quiet tests/integration/phpunit.xml.dist $(CONTAINER):/var/www/html/dev/tests/integration/phpunit.xml
    @docker cp --quiet tests/integration/etc/install-config-mysql.php $(CONTAINER):/var/www/html/dev/tests/integration/etc/install-config-mysql.php
    @docker cp --quiet tests/integration/etc/config-global.php $(CONTAINER):/var/www/html/dev/tests/integration/etc/config-global.php
    @docker cp --quiet tests/phan.php $(CONTAINER):/var/www/html/phan.php
    @docker cp --quiet tests/phpstan.neon $(CONTAINER):/var/www/html/phpstan.neon
    @docker cp --quiet tests/psalm.xml $(CONTAINER):/var/www/html/psalm.xml
    @docker cp --quiet tests/phpstan-rules $(CONTAINER):/var/www/html/dev/tests/phpstan-rules
    @docker cp --quiet tests/ruleset.xml $(CONTAINER):/var/www/html/ruleset.xml
    @docker cp --quiet tests/rector-$(RECTOR_VERSION).php $(CONTAINER):/var/www/html/rector.php
endef

define upload_module
    @docker exec --user root $(CONTAINER) rm -rf /var/www/html/app/code/
    @docker exec --user root $(CONTAINER) mkdir -p /var/www/html/app/code/$(basename $(MODULE) | cut -d/ -f1)
    @docker cp --quiet $(MODULE_PATH)/. $(CONTAINER):/var/www/html/app/code/$(basename $(MODULE))
endef

define install_module
    $(call upload_module)
    @docker exec --user root $(CONTAINER) php -dmemory_limit=-1 bin/magento s:up
    @docker exec --user root $(CONTAINER) php -dmemory_limit=-1 bin/magento mod:status $(MODULE_NAME)
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
