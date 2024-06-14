FROM php:8.1-cli

WORKDIR /app

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    jq \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN composer create-project magento/magento-coding-standard --stability=dev magento-coding-standard

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

ENV PATH="/app/magento-coding-standard/vendor/bin:${PATH}"

CMD ["php", "-a"]
