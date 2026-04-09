// morse_vpi.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "vpi_user.h" // This is the main VPI header

// --- 1. The C Logic (same as before) ---

// This is the actual print logic, now in pure C
void print_morse_logic(int pattern, int len) {
    if (len == 0) {
        printf(" "); // Handle spaces
        return;
    }

    // This logic is from the C++ file, but converted to pure C
    char symbols[5][2]; // Array to hold "." or "-"
    int i;
    for (i = 0; i < len; ++i) {
        // Extract 2 bits for the symbol
        int symbol = (pattern >> ((len - 1 - i) * 2)) & 0x3;
        if (symbol == 0x1) { // 01 (DOT)
            strcpy(symbols[i], ".");
        } else if (symbol == 0x2) { // 10 (DASH)
            strcpy(symbols[i], "-");
        }
    }

    // Print in the correct order
    for (i = 0; i < len; i++) {
        printf("%s", symbols[i]);
    }
    printf(" "); // Space between letters
}

// --- 2. The VPI Boilerplate ---

// This is the wrapper function that Verilog actually calls.
// It's responsible for getting the arguments from Verilog.
static int print_morse_vpi(char *user_data) {
    // Get a handle to the simulation task call
    vpiHandle systf_handle = vpi_handle(vpiSysTfCall, NULL);
    
    // Get an iterator for the arguments
    vpiHandle arg_itr = vpi_iterate(vpiArgument, systf_handle);

    // Get the first argument (pattern)
    vpiHandle pattern_handle = vpi_scan(arg_itr);
    // Get the second argument (len)
    vpiHandle len_handle = vpi_scan(arg_itr);

    // Struct to hold the read values
    s_vpi_value val_s;
    val_s.format = vpiIntVal; // We expect integers

    // Read the value from the 'pattern' argument
    vpi_get_value(pattern_handle, &val_s);
    int pattern = val_s.value.integer;

    // Read the value from the 'len' argument
    vpi_get_value(len_handle, &val_s);
    int len = val_s.value.integer;

    // Now call our actual C logic
    print_morse_logic(pattern, len);

    // After processing all characters for an input line, the simulation
    // will pause for the next input. We flush stdout here to make sure
    // the morse code appears on the same line before the next prompt.
    fflush(stdout);
    
    // Clean up
    vpi_free_object(arg_itr); // Not strictly needed but good practice
    return 0;
}

// This function tells iVerilog about our $print_morse task
void register_print_morse_task() {
    s_vpi_systf_data tf_data;
    
    tf_data.type        = vpiSysTask;
    tf_data.tfname      = "$print_morse";
    tf_data.calltf      = print_morse_vpi;
    tf_data.compiletf   = NULL;
    tf_data.sizetf      = NULL;
    tf_data.user_data   = NULL;
    
    vpi_register_systf(&tf_data);
}

// This is the entry point that iVerilog looks for.
// It points to our registration function.
void (*vlog_startup_routines[])() = {
    register_print_morse_task,
    0
};