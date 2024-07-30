define run_performance_tests
    @docker exec $(CONTAINER) bin/magento dev:tests:run performance app/code/$(MODULE)
endef

define run_unit_tests
    @docker exec -it --user root $(CONTAINER) ./vendor/bin/phpunit --migrate-configuration -c dev/tests/unit/phpunit.xml app/code/$(MODULE)/Test/Unit
endef

define run_integration_tests
    @docker exec -i --user root -w /var/www/html $(CONTAINER) bash -c ' \
        cd dev/tests/integration && \
        ../../../vendor/bin/phpunit --testsuite "Third Party Integration Tests" --color ../../../app/code/$(MODULE)/Test/Integration \
    '
endef

define run_mtf_tests
    @docker compose exec magento bin/magento dev:tests:run mtf app/code/$(MODULE)
endef