verbose = 0
#If verbose is 1 then prints the full path of the source file that being built
SRCROOT         := $(CURDIR)

#print:
#	@echo "Value of SRCROOT: $(SRCROOT)"
.PHONY : print
ODIR		= build


vpath %.c $(SRCROOT)/FreeRTOS
vpath %.c $(SRCROOT)/FreeRTOS/portable/MemMang
vpath %.c $(SRCROOT)/FreeRTOS/portable/GCC/POSIX
vpath %.c $(SRCROOT)/Project

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
#x86_64-linux-gnu typically contains architecture-specific libraries and header files for the x86_64 (64-bit) architecture on Linux systems. 

OBJS 		= $(patsubst %.c,%.o,$(C_FILES)) 
#creates a list of object files by replacing the ".c" extension with ".o" for each source file listed in the C_FILES variable.
#This list is then used to track dependencies and to generate rules for compiling each source file into its corresponding object file.

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
#-g: This flag tells the compiler to generate debug information, which is used by debuggers to map machine code instructions back to the original source code.

#-UUSE_STDIO: This flag undefines the macro USE_STDIO. If the macro was defined elsewhere, this flag removes its definition, 
#effectively excluding code that depends on it.
#Undefining a macro like USE_STDIO can help tailor your code to specific requirements, reduce code size, avoid conflicts, and customize 
#library behavior.

#-D__GCC_POSIX__=1: This defines a macro named __GCC_POSIX__ with the value 1. 
#It indicates that the code should be compiled with POSIX compatibility features provided by the GCC compiler.

ifneq ($(shell uname), Darwin)
CFLAGS += -pthread 
endif
#Darwin => macOS ; if not equal to macOS then add pthread flag
#The -pthread flag is typically used to indicate that the program should be linked with the POSIX thread library, necessary for 
#multithreaded programs on Unix-like systems 

CFLAGS 	+= -DMAX_NUMBER_OF_TASKS=300
#preprocessor macro;When you use -D followed by a macro name, you're telling the compiler to define that macro with a specific value 
#before compiling the source code.
 
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
#for this rule the $@ is name of the object file being built;$(dir $@) extracts the directory portion of the object 
#file's path(ex:-obj/tasks.o,so obj is being extracted),and creates the "obj" directory to keep all the object files


ifeq ($(verbose),1)
	@echo  [CC] "$<"	
	$(CC) $(CFLAGS) -c -o $@ $<
else
	@echo [CC] "$(notdir $<)"
	@$(CC) $(CFLAGS) -c -o $@ $<
endif
#"@" in front of $(CC) will supress the printing of command on terminal
#The $< and $@ are automatic variables representing the prerequisites (source file) and the target (object file), respectively.
#$(CC): The compiler command (e.g., gcc);$(CFLAGS): Compiler flags.
#-c: Indicates that compilation should stop after the object file is created, without linking.
#-o $@: Specifies the output file, which is the target of the rule (the object file being built).
#$<: Represents the first prerequisite of the target, which is the source file being compiled.
#$(notdir ...) function. This function extracts the file name portion of a path, removing any directory components.

LIBS = -lpthread
#pthread library should be linked with the executable during the linking phase of the compilation process.

LINKFLAGS += -L/usr/local/lib      # Default system library search path
LINKFLAGS += -Wl,-rpath,/usr/local/lib  # Default runtime library search path
LINKFLAGS += -static                   # Request static linking
#Static linking is a process where all the library code that your program depends on is copied into the final executable file

Output: $(_OBJS)
	@echo [LD] "$@"
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
#       $(LIBS): Libraries to link against (e.g., lpthread).
	
	
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

