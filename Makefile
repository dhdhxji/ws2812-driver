SRCS:=$(wildcard src/*.v)
BENCHES:=$(patsubst %.v,%.vvp,$(wildcard bench/*.v))

all: runbench

%.vvp: %.v $(SRCS)
	iverilog -o $@ $^

.PHONY: runbench
runbench: $(BENCHES)
	for vcd in $(BENCHES); do \
		./$$vcd ;\
	done

.PHONY: clean
clean: 
	rm $(BENCHES) *.vcd 