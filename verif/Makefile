# design under test
DUT = duc

# directory paths
TOP_DIR         = $(shell pwd)/..
INCLUDE_DIR     = $(TOP_DIR)/include
SRC_DIR         = $(TOP_DIR)/src
DECIM_DIR	    = $(SRC_DIR)/decimators
INTERP_DIR	    = $(SRC_DIR)/interpolators

INTERP_SRCS     = $(SRC_DIR)/interpolators/duc.sv $(SRC_DIR)/interpolators/fir_filter.sv $(SRC_DIR)/interpolators/interpolator_ctrl.sv $(SRC_DIR)/interpolators/interpolator.sv $(SRC_DIR)/interpolators/sat_trunc.sv
INTERP_PKGS     = filter_pkg.sv
DECIM_SRCS      = $(SRC_DIR)/decimators/ddc.sv $(SRC_DIR)/decimators/pp_decimator_2.sv $(SRC_DIR)/interpolators/fir_filter.sv $(SRC_DIR)/interpolators/sat_trunc.sv

# dut parameters
ifeq ($(DUT), duc)
	TOPLEVEL  = $(DUT)
	MODULE    = pytests.test_duc
	_PKGS     = $(SRC_DIR)/interpolators/filter_pkg.sv
	_SRCS     = $(INTERP_SRCS)
	SIM_BUILD = build/build_$(TOPLEVEL)
endif

# dut parameters
ifeq ($(DUT), ddc)
	TOPLEVEL  = $(DUT)
	MODULE    = pytests.test_ddc
	_PKGS     = $(SRC_DIR)/interpolators/filter_pkg.sv
	_SRCS     = $(DECIM_SRCS)
	SIM_BUILD = build/build_$(TOPLEVEL)
endif

# dut parameters
ifeq ($(DUT), fft)
	TOPLEVEL  = $(DUT)
	MODULE    = pytests.test_fft
	_PKGS     = $(FFT_PKGS)
	PKGS      = $(patsubst %,$(FFT_DIR)/%,$(_PKGS))
	_SRCS     = $(FFT_SRCS)
	SRCS      = $(patsubst %,$(FFT_DIR)/%,$(_SRCS))
	SIM_BUILD = build/build_$(TOPLEVEL)
endif

# dut parameters
ifeq ($(DUT), pak_dsp)
	TOPLEVEL  = $(DUT)
	MODULE    = pytests.test_pak_dsp
	_PKGS     = $(INTERP_PKGS) $(DECIM_PKGS) $(FFT_PKGS)
	_SRCS     = $(INTERP_SRCS) $(DECIM_SRCS) $(FFT_SRCS)
	SIM_BUILD = build/build_$(TOPLEVEL)
endif

# path substitution
# SRCS  = $(patsubst %,$(SRC_DIR)/%,$(_SRCS))

# debug/trace settings
ifeq ($(DEBUG), on)
	SETTINGS = --trace --trace-structs --timing
endif

# cocotb variables
EXTRA_ARGS      = vconfig.vlt $(SETTINGS) -I$(INCLUDE_DIR)
VERILOG_SOURCES = $(_PKGS) $(_SRCS)
TOPLEVEL_LANG   = verilog
SIM             = verilator

include $(shell cocotb-config --makefiles)/Makefile.sim

clean_all: clean
	rm -f results.xml
	rm -f -r pytests/__pycache__
	cd gen_machine_codes && make clean

