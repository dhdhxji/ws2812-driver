SRCS:=$(wildcard src/*.v)
BENCH_SRCS:=$(wildcard bench/*.v)
OUTDIR:="bin/"

all: runbench

net: $(SRCS) $(BENCH_SRCS)
	iverilog -o $@ $^

.PHONY: runbench
runbench: net
	./$<

.PHONY: view
view: runbench
	gtkwave out.vcd