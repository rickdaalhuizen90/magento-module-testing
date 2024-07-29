# Magento Module Testing in Docker

A minimal Docker image for testing Magento 2 modules.

## Usage

1. Copy the environment file:
    ```bash
    cp .env.example .env
    ```
2. Build the Docker image:
    ```bash
    make build PHP_VERSION=8.3 OPENSEARCH_VERSION=2.14
    ```
3. Install your Magento module:
    ```bash
    make install MAGENTO_VERSION=2.4.7
    ```
4. Upload and install the module:
    ```bash
    make upload && make install-module MODULE_PATH=/path/to/Vendor/Module
    ```   

5. Run tests:
    ```bash
    make tests
    ```

Docker will first use the default variables defined in the .env file, but their values can be overridden by passing arguments to the make command.

## Features

- Installs Magento modules
- Runs PHP unit/integration, performance and MTFT tests
- Static code analysis (PHPStan, Psalm, Phan, PHPCS, PHPMD)
- Code formatting (Rector, PHPCBF)

## Known Issues

1. The current `rector.php` configuration is compatible with Rector version ^0.17.60, which does not support Magento 2.4.3. To use Rector with Magento 2.4.3, you need to use a configuration compatible with version 0.11.13.

2. When you encounter the error "the php-ast extension must be loaded in order for Phan to work," execute the following command to install the `ast` extension: 

```bash
docker exec -it --user root php-fpm-test pecl install ast
```

Additionally, make sure to uncomment the `extension=ast.so` line in the `php-fpm/php.ini` configuration file.

## TODO
- [x] Static analysis
- [x] Code formatting
- [x] Unit tests
- [x] Integration tests
- [x] Rector
- [ ] MTFT tests
- [ ] Performance testing
