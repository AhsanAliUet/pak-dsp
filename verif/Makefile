# design under test
DUT = duc

# directory paths
TOP_DIR         = $(shell pwd)/..
INCLUDE_DIR     = $(TOP_DIR)/include
SRC_DIR         = $(TOP_DIR)/src
DECIM_DIR	    = $(SRC_DIR)/decimators
INTERP_DIR	    = $(SRC_DIR)/interpolators

INTERP_SRCS     = $(SRC_DIR)/interpolators/duc.sv $(SRC_DIR)/interpolators/interpolator_ctrl.sv $(SRC_DIR)/interpolators/interpolator.sv
INTERP_PKGS     = $(SRC_DIR)/interpolators/filter_pkg.sv
DECIM_SRCS      = $(SRC_DIR)/decimators/ddc.sv $(SRC_DIR)/decimators/pp_decimator_2.sv
FFT_8_SRCS      = $(SRC_DIR)/fft_8p/pipeline.sv $(SRC_DIR)/fft_8p/cadd.sv $(SRC_DIR)/fft_8p/bfly_2p.sv $(SRC_DIR)/fft_8p/fft_8p.sv
FFT_N_SRCS      = $(SRC_DIR)/fft_np/sat_pkg.sv $(SRC_DIR)/fft_np/butterfly.sv $(SRC_DIR)/fft_np/fft_np.sv $(SRC_DIR)/fft_np/converters_pkg.sv $(SRC_DIR)/fft_np/tb_fft_np.sv
COMMON_SRCS     = $(SRC_DIR)/common/sat_trunc.sv $(SRC_DIR)/interpolators/fir_filter.sv $(SRC_DIR)/common/sym_even_fir_filter.sv $(SRC_DIR)/common/sym_odd_fir_filter.sv $(SRC_DIR)/fft_8p/cmul.sv
TOP_SRCS        = $(INTERP_PKGS) $(INTERP_SRCS) $(DECIM_SRCS) $(FFT_8_SRCS) $(FFT_N_SRCS) $(COMMON_SRCS) tb_pak_dsp.sv $(SRC_DIR)/top/pak_dsp.sv $(SRC_DIR)/top/memory_map.sv

# dut parameters
ifeq ($(DUT), duc)
	TOPLEVEL  = $(DUT)
	MODULE    = pytests.test_$(DUT)
	_PKGS     = $(SRC_DIR)/interpolators/filter_pkg.sv
	_SRCS     = $(COMMON_SRCS) $(INTERP_SRCS)
	SIM_BUILD = build/build_$(TOPLEVEL)
endif

# dut parameters
ifeq ($(DUT), ddc)
	TOPLEVEL  = $(DUT)
	MODULE    = pytests.test_$(DUT)
	_PKGS     = $(SRC_DIR)/interpolators/filter_pkg.sv
	_SRCS     = $(COMMON_SRCS) $(DECIM_SRCS)
	SIM_BUILD = build/build_$(TOPLEVEL)
endif

# dut parameters
ifeq ($(DUT), pipeline)
	TOPLEVEL  = $(DUT)
	MODULE    = pytests.test_$(DUT)
	_PKGS     = 
	_SRCS     = $(FFT_8_SRCS)
	SIM_BUILD = build/build_$(TOPLEVEL)
endif

# dut parameters
ifeq ($(DUT), cmul)
	TOPLEVEL  = $(DUT)
	MODULE    = pytests.test_$(DUT)
	_PKGS     = 
	_SRCS     = $(FFT_8_SRCS)
	SIM_BUILD = build/build_$(TOPLEVEL)
endif

# dut parameters
ifeq ($(DUT), cadd)
	TOPLEVEL  = $(DUT)
	MODULE    = pytests.test_$(DUT)
	_PKGS     = 
	_SRCS     = $(FFT_8_SRCS)
	SIM_BUILD = build/build_$(TOPLEVEL)
endif

# dut parameters
ifeq ($(DUT), bfly_2p)
	TOPLEVEL  = $(DUT)
	MODULE    = pytests.test_$(DUT)
	_PKGS     = 
	_SRCS     = $(FFT_8_SRCS)
	SIM_BUILD = build/build_$(TOPLEVEL)
endif

# dut parameters
ifeq ($(DUT), fft_8p)
	TOPLEVEL  = $(DUT)
	MODULE    = pytests.test_$(DUT)
	_PKGS     = 
	_SRCS     = $(COMMON_SRCS) $(FFT_8_SRCS)
	SIM_BUILD = build/build_$(TOPLEVEL)
endif

# dut parameters
ifeq ($(DUT), fft_np)
	TOPLEVEL  = tb_$(DUT)
	MODULE    = pytests.test_$(DUT)
	_PKGS     = 
	_SRCS     = $(COMMON_SRCS) $(FFT_N_SRCS)
	SIM_BUILD = build/build_$(TOPLEVEL)
endif

# dut parameters
ifeq ($(DUT), pak_dsp)
	TOPLEVEL  = tb_$(DUT)
	MODULE    = pytests.test_$(DUT)
	_SRCS     = $(TOP_SRCS)
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

