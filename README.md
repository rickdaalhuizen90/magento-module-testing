# Magento Module Testing in Docker

A minimal Docker image for testing Magento 2 modules.

## Usage

1. Copy the environment file:
    ```bash
    cp .env.example .env
    ```
2. Build the Docker image:
    ```bash
    make build MAGENTO=2.4.7 PHP=8.3 COMPOSER=2.3 OPENSEARCH=2.14
    ```
3. Install your Magento module:
    ```bash
    make install && make install-module MODULE=/path/to/Vendor/Module
    ```
4. Run tests:
    ```bash
    make tests
    ```

## Features

- Installs a Magento module from the specified path
- Runs PHP unit tests, integration tests, and MTFT tests for the module

## TODO
- [ ]  Implement testing configuration.