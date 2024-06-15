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
    make install MAGENTO_VERSION=2.4.7 && make install-module MODULE_PATH=/path/to/Vendor/Module
    ```
4. Run tests:
    ```bash
    make tests
    ```

Docker will first use the default variables defined in the .env file, but their values can be overridden by passing arguments to the make command.

## Features

- Installs a Magento module from the specified path
- Runs PHP unit tests, integration tests, and MTFT tests for the module

## TODO
- [X] Static analysis
- [X] Code formatting
- [x] Unit tests
- [ ] Integration tests
- [ ] Rector
- [ ] MTFT tests
- [ ] Performance testing