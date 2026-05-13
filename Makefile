CROSS_COMPILER_DIR := ../ARM_Toolchain/arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-linux-gnueabihf/bin

COMPILE_DIR := Projects/GPIO
SRC_DIR := $(COMPILE_DIR)/src
BUILD_DIR := $(COMPILE_DIR)/Build

TARGET := main

BOARD := beagleboneblack

CC := $(CROSS_COMPILER_DIR)/arm-none-linux-gnueabihf-gcc

CFLAGS := -Wall -Werror -O2
LDFLAGS := -lpthread

BBB_IP := 192.168.7.2
BBB_USER := root
BBB_DEPLOY_DIR := /root

# SSH options for BBB:
#  - Skip host-key verification (BBB regenerates keys on every boot)
#  - Exclude sntrup761x25519 KEX: crashes sshd on ARM32 Cortex-A8
#  - Allow ssh-rsa host key and user-key algorithms (OpenSSH 9 defaults exclude them)
SSH_OPTS := -o StrictHostKeyChecking=no \
            -o UserKnownHostsFile=/dev/null \
            -o KexAlgorithms=curve25519-sha256,ecdh-sha2-nistp256,ecdh-sha2-nistp384,diffie-hellman-group14-sha256 \
            -o HostKeyAlgorithms=rsa-sha2-512,rsa-sha2-256,ssh-rsa \
            -o PubkeyAcceptedAlgorithms=+ssh-rsa

SRC := $(SRC_DIR)/main.c

OUTPUT := $(BUILD_DIR)/$(TARGET)

.PHONY: help build clean deploy run

help:
	@echo "Usage: make [build|clean|deploy|run]"
	@echo ""
	@echo " build   - Build application"
	@echo " clean   - Remove build directory"
	@echo " deploy  - Copy executable to BBB"
	@echo " run     - Build + deploy + run on BBB"

build: $(OUTPUT)

$(OUTPUT): $(SRC)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) $< -o $@ $(LDFLAGS)
	@echo "Built: $@"

clean:
	rm -rf $(BUILD_DIR)
	@echo "Cleaned: $(BUILD_DIR)"

deploy: build
	scp $(SSH_OPTS) $(OUTPUT) $(BBB_USER)@$(BBB_IP):$(BBB_DEPLOY_DIR)/
	@echo "Deployed to BBB"

run: deploy
	ssh $(SSH_OPTS) $(BBB_USER)@$(BBB_IP) "$(BBB_DEPLOY_DIR)/$(TARGET)"
	@echo "Executed on BBB"
