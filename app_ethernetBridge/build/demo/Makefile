TARGET ?= XK-XMP-64
BASE_DIR = ../..

DEMO_SOURCE_DIRS = demo

SOURCE_DIRS += $(DEMO_SOURCE_DIRS)

INCLUDE_DIRS += $(DEMO_SOURCE_DIRS) 

XCC_FLAGS += -O3 -g 

EXCLUDE_FILES = 

BINARIES = test1.xe test2.xe test3.xe 


SOURCE_FILES_test1.xe = test1.xc
SOURCE_FILES_test2.xe = test2.xc
SOURCE_FILES_test3.xe = test3.xc

include $(BASE_DIR)/build/mac/Makefile.mac
include $(BASE_DIR)/build/common/Makefile.common

all: $(BIN_DIR)/test1.xe 

clean: clean_common
