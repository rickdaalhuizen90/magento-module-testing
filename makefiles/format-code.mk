define run_phpcbf
    # TODO: implement ghcr.io/rickdaalhuizen90/magento-coding-standard:latest 
    @docker exec --user root $(CONTAINER) php vendor/bin/phpcbf \
        --standard=Magento2 \
        --extensions=php,phtml \
        --ignore-annotations \
        app/code/$(MODULE)
endef

define run_rector
	@docker exec -it --user root $(CONTAINER) ./vendor/bin/rector process app/code/
endef