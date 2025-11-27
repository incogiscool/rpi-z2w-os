RPI_VERSION ?= rpi-z2w

BOOTMNT ?= /mnt/boot
ARMGNU ?= aarch64-elf

COPS = -DRPI_VERSION=${RPI_VERSION} -Wall -ffreestanding -nostdlib -nostartfiles \
	-Iinclude -mgeneral-regs-only

ASMOPS = -Iinclude

BUILD_DIR = build
SRC_DIR = src

all : kernel8.img
clean :
	rm -rf $(BUILD_DIR) *.img

${BUILD_DIR}/%_s.o: $(SRC_DIR)/%.S
	mkdir -p $(@D)
	$(ARMGNU)-gcc $(COPS) -MMD -c $< -o $@

${BUILD_DIR}/%_c.o: $(SRC_DIR)/%.c
	mkdir -p $(@D)
	$(ARMGNU)-gcc $(COPS) -MMD -c $< -o $@

C_FILES = $(wildcard $(SRC_DIR)/*.c)
ASM_FILES = $(wildcard $(SRC_DIR)/*.S)
OBJ_FILES = $(C_FILES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%_c.o)
OBJ_FILES += $(ASM_FILES:$(SRC_DIR)/%.S=$(BUILD_DIR)/%_s.o)

DEP_FIELS = $(OBJ_FILES:%.o=%.d)
-include $(DEP_FIELS)

kernel8.img: ${SRC_DIR}/linker.ld ${OBJ_FILES}
	@echo "Building for RPI $(value RPI_VERSION)"
	@echo "Deploy to BOOTMNT: $(value BOOTMNT)"
	@echo ""
	$(ARMGNU)-ld -T ${SRC_DIR}/linker.ld -o ${BUILD_DIR}/kernel8.elf ${OBJ_FILES}
	$(ARMGNU)-objcopy ${BUILD_DIR}/kernel8.elf -O binary kernel
			