#---------------------------------------------------------------------------------
.SUFFIXES:
#---------------------------------------------------------------------------------
TARGET		:= logfile
SOURCES		:= source
INCLUDES	:= include
OUTDIR		:= dist
DEBUG		:= 0
DEFINES		:= -D__DEBUG__=$(DEBUG)
BUILD		:= build
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
ifeq ($(DEBUG),0)
RELEASE_FLAGS	:= -O2 -flto
else
RELEASE_FLAGS	:= -g -Og
endif
CXXSTDLIB	:= c++20

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
