
XCC = xcc

ifeq "$(XLOG_JTAG)" "yes"
DEFINES += -D XLOG_JTAG
endif

SWC_COMMON_INC_DIR = ../../sw_comps_common/include
SWC_XLOG_INC_DIR = ../../swc_xlog/include

SWC_ETHR_DRV_COMP_INC_DIR = ../include
SWC_ETHR_DRV_COMP_SRC_DIR = ../src

# Client Component Source files
SWC_ETHR_DRV_CLIENT_COMP_FILES = $(SWC_ETHR_DRV_COMP_SRC_DIR)/ethernet_rx_client.xc \
$(SWC_ETHR_DRV_COMP_SRC_DIR)/ethernet_tx_client.xc

# Server Component Source files
SWC_ETHR_DRV_SERVER_COMP_FILES = $(SWC_ETHR_DRV_COMP_SRC_DIR)/ethernet_server.xc \
$(SWC_ETHR_DRV_COMP_SRC_DIR)/getmac.xc \
$(SWC_ETHR_DRV_COMP_SRC_DIR)/ethernet_rx_server.xc \
$(SWC_ETHR_DRV_COMP_SRC_DIR)/ethernet_tx_server.xc \
$(SWC_ETHR_DRV_COMP_SRC_DIR)/ethernet_rx_filter.xc \
$(SWC_ETHR_DRV_COMP_SRC_DIR)/mii.xc \
$(SWC_ETHR_DRV_COMP_SRC_DIR)/smi.xc

# Include DIR
INCLUDE_DIR = -I$(SWC_COMMON_INC_DIR) -I$(SWC_ETHR_DRV_COMP_INC_DIR) -I$(SWC_ETHR_DRV_COMP_SRC_DIR) \
-I$(SWC_XLOG_INC_DIR)

#User defines
#XCC_FLAGS = -D'_ETHERNET_SERVER_DEBUG_' -O2 -Wall -Xmapper --report
XCC_FLAGS = -O2 -Wall -Xmapper --report -g -Xmapper --retain -DXC2

all: client server

client:
	# Generate lib for client component
	$(XCC) $(XCC_FLAGS) $(INCLUDE_DIR) $(DEFINES) -c $(SWC_ETHR_DRV_CLIENT_COMP_FILES)
	ar rvu ethernet_driver_client.a ethernet_rx_client.o ethernet_tx_client.o
	ranlib ethernet_driver_client.a
	
	
server:
	# Generate lib for server component
	$(XCC) $(XCC_FLAGS) $(INCLUDE_DIR) $(DEFINES) -c $(SWC_ETHR_DRV_SERVER_COMP_FILES)
	ar rvu ethernet_driver_server.a ethernet_server.o ethernet_rx_server.o ethernet_tx_server.o \
	ethernet_rx_filter.o mii.o smi.o getmac.o
	ranlib ethernet_driver_server.a

clean:
	rm -f *.a *.o *.s *.i
