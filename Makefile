#---------------------------------------------------------------------------------
.SUFFIXES:
#---------------------------------------------------------------------------------
TARGET		:= logfile
SOURCES		:= source
INCLUDES	:= include
OUTDIR		:= dist
DEBUG		:= 0
DEFINES		:= -D__DEBUG__=$(DEBUG)
#---------------------------------------------------------------------------------
# filetypes
#---------------------------------------------------------------------------------
CFILES		:= $(foreach dir,$(SOURCES),$(wildcard $(dir)/*.c))
CPPFILES	:= $(foreach dir,$(SOURCES),$(wildcard $(dir)/*.cpp))
#---------------------------------------------------------------------------------
# files we need
#---------------------------------------------------------------------------------
OUTPUT	:= $(OUTDIR)/$(TARGET)

OFILES 			:= $(CPPFILES:.cpp=.cpp.o) $(CFILES:.c=.c.o)
BUILD_OFILES	:= $(foreach file,$(OFILES),$(addprefix $(BUILD)/,$(file)))
DEPSFILES 		:= $(BUILD_OFILES:.o=.d)

INCLUDE	:= $(foreach dir,$(INCLUDES),-I$(CURDIR)/$(dir))
#---------------------------------------------------------------------------------
# linker and compiler options
#---------------------------------------------------------------------------------
OPTIMIZE 	:= -O2 -flto
DEBUGGIN	:= -g -Og
CXXSTDLIB	:= c++20

RELEASE_FLAGS	:= $(if $(strip $(DEBUG)),$(DEBUGGIN),$(OPTIMIZE))
#---------------------------------------------------------------------------------
CFLAGS		:= -Wall -Wextra $(CFLAGS) $(INCLUDE) $(RELEASE_FLAGS) $(DEFINES)
CXXFLAGS 	:= $(CFLAGS) $(CXXFLAGS) -std=$(CXXSTDLIB) $(RELEASE_FLAGS)
LDFLAGS 	:= $(LDFLAGS) $(RELEASE_FLAGS)
#---------------------------------------------------------------------------------
# use CXX for linking C++ projects, CC for standard C
#---------------------------------------------------------------------------------
LD := $(if $(strip $(CPPFILES)),$(CXX),$(CC))
#---------------------------------------------------------------------------------
.PHONY: all clean
#---------------------------------------------------------------------------------
# makefile rules
#---------------------------------------------------------------------------------
all: $(BUILD) $(OUTPUT)

$(BUILD):
	@mkdir -p $@

clean:
	@echo clean...
	@rm -rf $(BUILD) $(OUTDIR)
#---------------------------------------------------------------------------------
# main targets
#---------------------------------------------------------------------------------
$(OUTPUT): $(BUILD_OFILES)
	@mkdir -p $(dir $@)
	$(LD) $(BUILD_OFILES) $(LDFLAGS) -o $@

$(BUILD)/%.c.o: %.c
	@mkdir -p $(dir $@)
	$(CC) -MMD -MP -MF $(@:.o=.d) $(CFLAGS) -c -o $@ $<

$(BUILD)/%.cpp.o: %.cpp
	@mkdir -p $(dir $@)
	$(CXX) -MMD -MP -MF $(@:.o=.d) $(CXXFLAGS) -c -o $@ $<

-include $(DEPSFILES)
#---------------------------------------------------------------------------------