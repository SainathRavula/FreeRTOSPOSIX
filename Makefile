verbose = 0
#If verbose is 1 then prints the full path of the source file that being built
SRCROOT         := $(CURDIR)

#print:
#	@echo "Value of SRCROOT: $(SRCROOT)"
.PHONY : print
ODIR		= build

VPATH		+= $(SRCROOT)/FreeRTOS
VPATH		+= $(SRCROOT)/FreeRTOS/portable/MemMang
VPATH		+= $(SRCROOT)/FreeRTOS/portable/GCC/POSIX
VPATH		+= $(SRCROOT)/Project

C_FILES	+= croutine.c
C_FILES	+= event_groups.c
C_FILES	+= list.c
C_FILES	+= queue.c
C_FILES	+= tasks.c
C_FILES	+= timers.c
C_FILES	+= heap_4.c
C_FILES	+= port.c
C_FILES	+= main.c


INCLUDES	+= -I$(SRCROOT)/FreeRTOS/include
INCLUDES	+= -I$(SRCROOT)/FreeRTOS/portable/GCC/POSIX/
INCLUDES	+= -I$(SRCROOT)/Project
INCLUDES	+= -I/usr/include/x86_64-linux-gnu/

OBJS 		= $(patsubst %.c,%.o,$(C_FILES)) 
#creates a list of object files by replacing the ".c" extension with ".o" for each source file listed in the C_FILES variable.This list is then used to track dependencies and to generate rules for compiling each source file into its corresponding object file.

CWARNS 	+= -W
CWARNS 	+= -Wall
CWARNS 	+= -Wextra
CWARNS 	+= -Wformat
CWARNS 	+= -Wmissing-braces
CWARNS 	+= -Wno-cast-align
CWARNS 	+= -Wparentheses
CWARNS 	+= -Wshadow
CWARNS 	+= -Wno-sign-compare
CWARNS 	+= -Wswitch
CWARNS 	+= -Wuninitialized
CWARNS 	+= -Wunknown-pragmas
CWARNS 	+= -Wunused-function
CWARNS 	+= -Wunused-label
CWARNS 	+= -Wunused-parameter
CWARNS 	+= -Wunused-value
CWARNS 	+= -Wunused-variable
CWARNS 	+= -Wmissing-prototypes



CFLAGS 	+= -m32
CFLAGS 	+= -DDEBUG=1
CFLAGS 	+= -g -UUSE_STDIO -D__GCC_POSIX__=1

ifneq ($(shell uname), Darwin)
CFLAGS += -pthread 
endif
#Darwin => macOS ; if not equal to macOS then add pthread flag
#The -pthread flag is typically used to indicate that the program should be linked with the POSIX thread library, necessary for multithreaded programs on Unix-like systems 

CFLAGS 	+= -DMAX_NUMBER_OF_TASKS=300
#preprocessor macro;When you use -D followed by a macro name, you're telling the compiler to define that macro with a specific value before compiling the source code.
 
CFLAGS 	+= $(INCLUDES) $(CWARNS) -O2 
#opt levels=>0-3 and Os,Ofast


.PHONY : all
all: Output

_OBJS 		= $(patsubst %,$(ODIR)/%,$(OBJS)) 
#replaces all .o files names in OBJS as DirName/File.o(obj/main.o,obj/tasks.o,.....) and creates a list of these names 

#print:
#	@echo "$(_OBJS)"


$(ODIR)/%.o: %.c 	 
	@mkdir -p $(dir $@) 
	
#target:dependecies
#$@ is an automatic variable in makefiles that represents the target of the rule.
#for this rule the $@ is name of the object file being built;$(dir $@) extracts the directory portion of the object file's path(ex:-obj/tasks.o,so obj is being extracted),and creates the "obj" directory to keep all the object files


ifeq ($(verbose),1)
	@echo ">> Compiling $<"
	$(CC) $(CFLAGS) -c -o $@ $<
else
	@echo ">> Compiling $(notdir $<)"
	@$(CC) $(CFLAGS) -c -o $@ $<
endif

#The $< and $@ are automatic variables representing the prerequisites (source file) and the target (object file), respectively.
#$(CC): The compiler command (e.g., gcc);$(CFLAGS): Compiler flags.
#-c: Indicates that compilation should stop after the object file is created, without linking.
#-o $@: Specifies the output file, which is the target of the rule (the object file being built).
#$<: Represents the first prerequisite of the target, which is the source file being compiled.
#$(notdir ...) function. This function extracts the file name portion of a path, removing any directory components.

Output: $(_OBJS)
	@echo ">> Linking $@..."
ifeq ($(verbose),1)
	$(CC) $(CFLAGS) $^ $(LINKFLAGS) $(LIBS) -o $@
else
	@$(CC) $(CFLAGS) $^ $(LINKFLAGS) $(LIBS) -o $@
endif
#$@ is the name of the target so in this rule it is Output
#$^ represents prerequisites(i.e dependencies) so in this rule it is names in list _OBJS i.e object files
#-o $@  Specifies the output file
#$(CC) $(CFLAGS) $^ $(LINKFLAGS) $(LIBS) -o $@: This is the #linking command.
#       $(CC): The compiler command (e.g., gcc).
#       $(CFLAGS): Compiler flags (e.g., -Wall -O2).   
#       $(LINKFLAGS): Additional linker flags (e.g., -L/path/to/#libraries).
#       $(LIBS): Libraries to link against (e.g., -lm for the #math library).
	
	
	@echo "-------------------------"
	@echo "BUILD COMPLETE: $@"
	@echo "-------------------------"

.PHONY : clean
clean:
	@-rm -f $(ODIR)/*.o $(ODIR)/*.bin $(ODIR)/*.elf $(ODIR)/*.hex Output
	@echo "--------------"
	@echo "CLEAN COMPLETE"
	@echo "--------------"

#The - before rm suppresses errors if the directories or files don't exist.
#-r (recursive) and -f (force) 

