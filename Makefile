.PHONY: all clean
.DEFAULT: all

SRC = src
SRC_DIRS := ${shell find ${SRC} -type d -print}
SRC_FILES := ${filter-out main.c,${notdir ${shell find ${SRC} -type f -name *.c -print}}}
SRC_HEADERS := ${notdir ${shell find ${SRC} -type f -name *.h -print}}

ALL_DIRS := \
	${SRC_DIRS}

MAIN_SOURCE := \
	${SRC_FILES} \
	${SRC_HEADERS}

BUILD := build
INCLUDES := -I. ${addprefix -I,${ALL_DIRS}}
VPATH := . ${ALL_DIRS}

all: ${BUILD}/main.hex

${BUILD}/main.axf: ${MAIN_SOURCE}

${BUILD}:
	mkdir -p ${BUILD}

# The code is compiled "optimized" to the max.
# 
# The weird "-Wl,--undefined=_mmcu,--section-start=.mmcu=0x910000"
# is used to tell the linker not to discard the .mmcu section,
# otherwise the --gc-sections will delete it.

${BUILD}/%.hex: ${BUILD}/%.axf
	@avr-objcopy -j .text -j .data -j .eeprom -O ihex ${<} ${@}

${BUILD}/%.s: ${BUILD}/%.axf
	@avr-objdump -j .text -j .data -j .bss -d  ${<} > ${@}

# --mcall-prologues can be used here, but messes up debugging a little
${BUILD}/%.axf: %.c ${filter-out ${wildcard ${BUILD}},${BUILD}}
	@echo AVR-CC ${<}
	@avr-gcc -Wall -gdwarf-2 -Os -std=gnu99 \
		-mmcu=atmega328p \
		-DF_CPU=8000000 \
		-fno-inline-small-functions \
		-ffunction-sections -fdata-sections \
		-Wl,--relax,--gc-sections \
		-Wl,--undefined=_mmcu,--section-start=.mmcu=0x910000 \
		${INCLUDES} \
		${filter-out ${BUILD},${^}} -o ${@}
	@avr-size ${@}|sed '1d'

clean:
	rm -rf ${BUILD}
