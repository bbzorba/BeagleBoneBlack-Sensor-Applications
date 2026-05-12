CROSS_COMPILER_DIR = ../ARM_Toolchain/arm-gnu-toolchain-14.2.rel1-x86_64-arm-none-linux-gnueabihf/bin
COMPILE_DIR = Projects/GPIO
BUILD_DIR = $(COMPILE_DIR)/Build

BOARD = beagleboneblack

COMPILE_CMD = $(CROSS_COMPILER_DIR)/arm-none-linux-gnueabihf-gcc
COMPILE_FLAGS = -Wall -Werror -O2
LINKER_FLAGS = -lpthread

help:
	@echo Usage: make [build, clean] [COMPILE_DIR=...] [BOARD=...]
	@echo   build       - Build the selected application
	@echo   clean       - Remove build directory

build: $(BUILD_DIR)/main
$(BUILD_DIR)/main: $(COMPILE_DIR)/src/main.c
	@mkdir -p $(BUILD_DIR)
	$(COMPILE_CMD) $(COMPILE_FLAGS) $< -o $@ $(LINKER_FLAGS)
	@echo Built: $@

clean:
	$(RM) $(BUILD_DIR)

ifeq ($(OS),Windows_NT)
	RM = del /Q
else
	RM = rm -rf
endif
	@echo Cleaned: $(BUILD_DIR)

