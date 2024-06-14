#!/bin/bash
set -e

# Perform any modifications or configurations needed
if [ -n "$COMPOSER_DEV_MODE" ] && [ "$COMPOSER_DEV_MODE" -eq 0 ]; then
    jq '.scripts += {
        "post-install-cmd": [
            "vendor/bin/phpcs --config-set installed_paths ../../magento/magento-coding-standard/"
        ],
        "post-update-cmd": [
            "vendor/bin/phpcs --config-set installed_paths ../../magento/magento-coding-standard/"
        ]
    }' /app/magento-coding-standard/composer.json > /app/magento-coding-standard/composer_temp.json \
    && mv /app/magento-coding-standard/composer_temp.json /app/magento-coding-standard/composer.json
fi

# Start your application or desired command
exec "$@"
