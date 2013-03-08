# =======================================================
#  Directory Management
# =======================================================

# Project Hosted at
PROJECT_SRC=$(shell pwd)

# Where to find user code.
CONF_DIR = $(PROJECT_SRC)/conf
TEST_DIR = $(PROJECT_SRC)/tests
TEST_BUILD_DIR = $(PROJECT_SRC)/tests/build
BUILD_DIR = $(PROJECT_SRC)/build
SRC_DIR = $(PROJECT_SRC)/src
LINKER_DIR = $(PROJECT_SRC)/ld
INCLUDE_DIR = $(PROJECT_SRC)/include

# Points to the root of Google Test, relative to where this file is.
GTEST_DIR=$(PROJECT_SRC)/tests/gtest-1.6.0

# =======================================================
#  File Management MCU
# =======================================================
MCU = LPC17xx

#  List of the objects files to be compiled/assembled
OBJECTS_ARM_$(MCU)=startup_$(MCU).o core_cm3.o system_$(MCU).o main_$(MCU).o
LSCRIPT_ARM_$(MCU)= $(LINKER_DIR)/$(MCU)/ldscript_rom_gnu.ld


# =======================================================
#  File Management TEST
# =======================================================
# TEST
OBJECTS_TEST=gtest_main.o gtest-all.o sample1_unittest.o sample1.o
BUILDLIB_TEST=gtest_main.a

# All Google Test headers.  Usually you shouldn't change this
# definition.
GTEST_HEADERS = $(GTEST_DIR)/include/gtest/*.h \
                $(GTEST_DIR)/include/gtest/internal/*.h

# Builds gtest.a and gtest_main.a.

# Usually you shouldn't tweak such internal variables, indicated by a
# trailing _.
GTEST_SRCS_ = $(GTEST_DIR)/src/*.cc $(GTEST_DIR)/src/*.h $(GTEST_HEADERS)


# =======================================================
#  Build Flags Management MCU
# =======================================================
OPTIMIZATION = 0
DEBUG = -g
#LISTING = -ahls

CPPFLAGS_$(MCU) = -Wall -fno-common -mcpu=cortex-m3 -mthumb -I./ -O$(OPTIMIZATION) $(DEBUG)
CPPFLAGS_$(MCU) += -D__RAM_MODE__=0

LDFLAGS_$(MCU) = -mcpu=cortex-m3 -mthumb -O$(OPTIMIZATION) -nostartfiles -Wl,-Map=$(PROJECT_SRC).map -T$(LSCRIPT_ARM_$(MCU))
ASFLAGS_$(MCU) = $(LISTING) -mcpu=cortex-m3 --defsym RAM_MODE=0

# =======================================================
#  Build Flags Management TEST
# =======================================================
# Flags passed to the preprocessor.
# Set Google Test's header directory as a system directory, such that
# the compiler doesn't generate warnings in Google Test headers.
CPPFLAGS_TEST += -isystem $(GTEST_DIR)/include

# Flags passed to the C++ compiler.
CXXFLAGS_TEST += -g -Wall -Wextra -pthread

# =======================================================
#  Compiler/Assembler/Linker Management for ARM Cortex-M3
# =======================================================
GCC_$(MCU) = arm-none-eabi-gcc
AS_$(MCU) = arm-none-eabi-as
LD_$(MCU) = arm-none-eabi-ld
OBJCOPY_$(MCU) = arm-none-eabi-objcopy
REMOVE = rm -f
SIZE_$(MCU) = arm-none-eabi-size

# =======================================================
#  Compiler/Assembler/Linker Management for TEST
# =======================================================
# GCC_TEST = arm-none-eabi-gcc
# AS_TEST = arm-none-eabi-as
# LD_TEST = arm-none-eabi-ld
# OBJCOPY_TEST = arm-none-eabi-objcopy
# REMOVE = rm -f
# SIZE_TEST = arm-none-eabi-size


# Creating a standard make file

all:
	gcc main.c -o main

test: sample1_unittest
	./sample1_unittest


# For simplicity and to avoid depending on Google Test's
# implementation details, the dependencies specified below are
# conservative and not optimized.  This is fine as Google Test
# compiles fast and for ordinary users its source rarely changes.
gtest-all.o : $(GTEST_SRCS_)
	$(CXX) $(CPPFLAGS_TEST) -I$(GTEST_DIR) $(CXXFLAGS_TEST) -c \
            $(GTEST_DIR)/src/gtest-all.cc

gtest_main.o : $(GTEST_SRCS_)
	$(CXX) $(CPPFLAGS_TEST) -I$(GTEST_DIR) $(CXXFLAGS_TEST) -c \
            $(GTEST_DIR)/src/gtest_main.cc

gtest.a : gtest-all.o
	$(AR) $(ARFLAGS) $@ $^

gtest_main.a : gtest-all.o gtest_main.o
	$(AR) $(ARFLAGS) $@ $^

	
# Builds a sample test.  A test should link with either gtest.a or
# gtest_main.a, depending on whether it defines its own main()
# function.

sample1.o : $(TEST_DIR)/sample1.cc $(TEST_DIR)/sample1.h $(GTEST_HEADERS)
	$(CXX) $(CPPFLAGS_TEST) $(CXXFLAGS_TEST) -c $(TEST_DIR)/sample1.cc

sample1_unittest.o : $(TEST_DIR)/sample1_unittest.cc \
                     $(TEST_DIR)/sample1.h $(GTEST_HEADERS)
	$(CXX) $(CPPFLAGS_TEST) $(CXXFLAGS_TEST) -c $(TEST_DIR)/sample1_unittest.cc

sample1_unittest : sample1.o sample1_unittest.o gtest_main.a
	$(CXX) $(CPPFLAGS_TEST) $(CXXFLAGS_TEST) -lpthread $^ -o $@


clean:
	$(REMOVE) $(OBJECTS_TEST)
	$(REMOVE) $(BUILDLIB_TEST)
	$(REMOVE) $(OBJECTS_ARM_$(MCU))
