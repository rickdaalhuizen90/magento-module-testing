define run_phpcs
    # TODO: implement ghcr.io/rickdaalhuizen90/magento-coding-standard:latest 
    @docker exec --user root $(CONTAINER) php vendor/bin/phpcs \
        --standard=Magento2 \
        --extensions=php,phtml \
        --error-severity=10 \
        --ignore-annotations \
        --report=json \
        --report-file=report.json \
        app/code/$(MODULE)
endef

define run_phpstan
    @docker exec -it --user root $(CONTAINER) \
    php /var/www/html/vendor/bin/phpstan analyse app/code/$(MODULE)
endef

define run_psalm
    @docker exec -it --user root $(CONTAINER) \
        php /var/www/html/vendor/bin/psalm.phar -c psalm.xml app/code/$(MODULE)
endef

define run_phan
    @docker exec -it --user root $(CONTAINER) \
        php /var/www/html/vendor/bin/phan -k phan.php
endef

define run_phpmd
    @docker exec -it --user root $(CONTAINER) \
        php /var/www/html/vendor/bin/phpmd app/code/$(MODULE) ansi ruleset.xml
endef