#
# Makefile based on:
# https://github.com/mattcurrie/mealybug-tearoom-tests/blob/master/Makefile
#

SRC_DIR = src
OBJ_DIR = .obj
DEP_DIR = .dep
BIN_DIR = build

SOURCES := $(wildcard $(SRC_DIR)/*.asm) $(wildcard $(SRC_DIR)/*/*.asm)
OBJECTS := $(SOURCES:$(SRC_DIR)/%.asm=$(OBJ_DIR)/%.o)
DEPS    := $(SOURCES:$(SRC_DIR)/%.asm=$(DEP_DIR)/%.d)
ROMS    := $(SOURCES:$(SRC_DIR)/%.asm=$(BIN_DIR)/%.gb)

SRC_PNGS := $(wildcard $(SRC_DIR)/*.png) $(wildcard $(SRC_DIR)/*/*.png)
SRC_PNGS := $(filter-out $(wildcard src/_include/*), $(SRC_PNGS))
BIN_PNGS := $(SRC_PNGS:$(SRC_DIR)/%.png=$(BIN_DIR)/%.png)



all: $(ROMS) $(BIN_PNGS)

$(ROMS): $(BIN_DIR)/%.gb : $(OBJ_DIR)/%.o
	@mkdir -p $(@D)
	rgblink -t -n $(basename $@).sym -m $(basename $@).map -o $@ $<
	rgbfix -v -p 255 $@

$(OBJECTS): $(OBJ_DIR)/%.o : $(SRC_DIR)/%.asm
	@mkdir -p $(@D)
	@mkdir -p $(@D:$(OBJ_DIR)/%=$(DEP_DIR)/%)
	rgbasm -h -Weverything -i $(SRC_DIR) -i $(SRC_DIR)/_include -M $(DEP_DIR)/$*.d -o $@ $<

$(DEPS):

include $(wildcard $(DEPS))

$(BIN_PNGS): $(BIN_DIR)/%.png : $(SRC_DIR)/%.png
	cp $< $@



.PHONY: clean
clean:
	rm -rf $(OBJ_DIR)
	rm -rf $(DEP_DIR)
	rm -rf $(BIN_DIR)
