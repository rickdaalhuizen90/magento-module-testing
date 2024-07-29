#!/bin/bash

composer config -g http-basic.repo.magento.com ${MAGENTO_PUBLIC_KEY} ${MAGENTO_PRIVATE_KEY}
composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition:${MAGENTO_VERSION} .
composer install --no-interaction --prefer-dist --optimize-autoloader --no-suggest

MAGENTO_CLEAN_VERSION=$(echo "$MAGENTO_VERSION" | sed 's/-.*//') 

if [[ "${MAGENTO_CLEAN_VERSION}" < "2.4.3" ]]; then
    SEARCH_ENGINE="elasticsearch7"
    SEARCH_ENGINE_FLAGS="--elasticsearch-host=opensearch --elasticsearch-port=9200"
else
    SEARCH_ENGINE="opensearch"
    SEARCH_ENGINE_FLAGS="--${SEARCH_ENGINE}-host=opensearch --${SEARCH_ENGINE}-port=9200"
fi

php -d memory_limit=-1 bin/magento setup:install \
    --base-url=http://localhost/ \
    --db-host=mysql-test \
    --db-name=${MYSQL_DATABASE} \
    --db-user=${MYSQL_USER} \
    --db-password=${MYSQL_PASSWORD} \
    --backend-frontname=admin \
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
    --search-engine=${SEARCH_ENGINE} ${SEARCH_ENGINE_FLAGS}

php bin/magento deploy:mode:set developer

COMPOSER_MEMORY_LIMIT=-1 composer require --dev psalm/phar \
    phan/phan \
    phpstan/extension-installer \
    phpstan/phpstan-beberlei-assert \
    phpstan/phpstan-strict-rules

jq '.autoload."psr-4"."PhpStanRules\\" = "dev/tests/phpstan-rules/"' "composer.json" > tmp.$$.json && mv tmp.$$.json "composer.json"

composer dump-autoload