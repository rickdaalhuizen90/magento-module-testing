#!/bin/bash

composer create-project --repository-url=https://mirror.mage-os.org/ magento/project-community-edition:${MAGENTO_VERSION} .
composer install --no-interaction --prefer-dist --optimize-autoloader

php -d memory_limit=-1 bin/magento setup:install \
    --base-url=http://localhost/ \
    --db-host=mysql-test \
    --db-name=magento \
    --db-user=magento \
    --db-password=magento \
    --admin-firstname=admin \
    --admin-lastname=admin \
    --admin-email=admin@admin.com \
    --admin-user=admin \
    --admin-password=admin123 \
    --language=en_US \
    --currency=USD \
    --timezone=Europe/Amsterdam \
    --use-rewrites=1 \
    --session-save=db \
    --cleanup-database \
    --search-engine=opensearch \
    --opensearch-host=opensearch-test \
    --opensearch-port=9200

php bin/magento deploy:mode:set developer