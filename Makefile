# Detect OS
ifeq ($(OS),Windows_NT)
    # Windows: Paths use backslashes, executables have .exe
    CROSS_COMPILER_DIR := C:/Program_Files/Arm_Toolchains/Arm_GNU_Toolchain_arm-none-linux-gnueabihf/14.2_rel1/bin
	CC := $(CROSS_COMPILER_DIR)/arm-none-linux-gnueabihf-gcc.exe
    RM_CMD := rm -rf
else
    # Linux: Paths use forward slashes
    CROSS_COMPILER_DIR := ../ARM_Toolchain/arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-linux-gnueabihf/bin
    CC := $(CROSS_COMPILER_DIR)/arm-none-linux-gnueabihf-gcc
    RM_CMD := rm -rf
endif

COMPILE_DIR := Projects/LED_Control
SRC_DIR := $(COMPILE_DIR)
BUILD_DIR := $(COMPILE_DIR)/Build
TARGET := main

CFLAGS := -Wall -Werror -O2
LDFLAGS := -lpthread

BBB_IP := 192.168.7.2
BBB_USER := root
BBB_DEPLOY_DIR := /root
SSH_OPTS := -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o KexAlgorithms=curve25519-sha256,ecdh-sha2-nistp256,ecdh-sha2-nistp384,diffie-hellman-group14-sha256 -o HostKeyAlgorithms=rsa-sha2-512,rsa-sha2-256,ssh-rsa -o PubkeyAcceptedAlgorithms=+ssh-rsa

SRC := $(SRC_DIR)/main.c
OUTPUT := $(BUILD_DIR)/$(TARGET)

.PHONY: build clean deploy run

build: $(OUTPUT)

$(OUTPUT): $(SRC)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) $< -o $@ $(LDFLAGS)
	@echo "Built: $@"

clean:
	$(RM_CMD) $(BUILD_DIR)
	@echo "Cleaned: $(BUILD_DIR)"

deploy: build
	scp $(SSH_OPTS) $(OUTPUT) $(BBB_USER)@$(BBB_IP):$(BBB_DEPLOY_DIR)/
	@echo "Deployed to BBB"

run: deploy
	ssh $(SSH_OPTS) $(BBB_USER)@$(BBB_IP) "$(BBB_DEPLOY_DIR)/$(TARGET)"
	@echo "Executed on BBB"
