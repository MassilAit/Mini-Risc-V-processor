#-----------------------------------------------------------------------------
# Project  ELE8304 : Circuits intégrés à très grande échelle
#-----------------------------------------------------------------------------
# File     Makefile
# Author   Mickael Fiorentino  <mickael.fiorentino@polymtl.ca>
# Lab      GRM - Polytechnique Montreal
# Date     <2019-08-21 Wed>
#-----------------------------------------------------------------------------
# Brief    Compilation de code assembleur mips32 & rv32i
#-----------------------------------------------------------------------------

#----------------------------------------------------------------------------
# HELP
#----------------------------------------------------------------------------
help:
	@echo
	@echo "Compilation de code assembleur MIPS & RISCV"
	@echo "-------------------------------------------"
	@echo " make help                  : Affiche cette aide"
	@echo " make clean                 : Supprime les fichiers générés par la compilation"
	@echo " make mips BENCHMARK=<f>    : Compilation du benchmark <f> pour mips32"
	@echo " make riscv BENCHMARK=<f>   : Compilation du benchmark <f> pour rv32i"
	@echo "   <f> : Nom du benchmark à compiler. Défaut: fibo.S"
	@echo

#----------------------------------------------------------------------------
# CONFIG
#----------------------------------------------------------------------------
ifndef PROJECT_HOME
$(error "ERREUR: Configurer l'environnement (source setup.csh) avant d'utiliser ce Makefile")
endif

BENCHMARK  ?= fibo.S
BENCH		= $(basename $(BENCHMARK))
HEX			= $(SCRIPTS_DIR)/hex.tcl

mips: CC		= mipsel-elf-gcc
mips: CFLAGS	= -mips32 -static -nostartfiles -O1
mips: COPY		= mipsel-elf-objcopy
mips: DUMP		= mipsel-elf-objdump
mips: LD		= mips.ld
mips: compile

riscv: CC		= riscv32-unknown-elf-gcc
riscv: CFLAGS	= -march=rv32i -static -nostartfiles -O0
riscv: COPY     = riscv32-unknown-elf-objcopy
riscv: DUMP     = riscv32-unknown-elf-objdump
riscv: LD		= riscv.ld
riscv: compile

#----------------------------------------------------------------------------
# TARGETS
#----------------------------------------------------------------------------
.PHONY : clean

compile: $(BENCH).mem $(BENCH).dump

%.elf : %.S
	$(CC) $(CFLAGS) -Wl,-T $(LD) -o $(BENCH).elf $<

%.dump : %.elf
	$(DUMP) -D --disassembler-options=no-aliases $< > $@

%.hex : %.elf
	$(COPY) -O verilog --only-section=.text $< $@

%.mem : %.hex
	$(HEX) $< $@

clean:
	rm -f *.elf *.dump *.hex *.mem
