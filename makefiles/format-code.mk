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

	# if Magento < 4.3.2 then use rector-0.11.60.php else use rector-0.17.13.php
endef