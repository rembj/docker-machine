SELF_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

machine-import:
	chmod +x $(SELF_DIR)/machine-import.sh
	$(SELF_DIR)/machine-import.sh --host-name=$(HOST_NAME) --host-key=$(HOST_KEY) --host-user=$(HOST_USER) 
machine-export:
	@chmod +x $(SELF_DIR)/machine-export.sh
	@$(SELF_DIR)/machine-export.sh --host-name=$(HOST_NAME)

