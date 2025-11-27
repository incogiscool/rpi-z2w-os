#include "common.h"
#include "mini_uart.h"

void kernel_main() {
    uart_init();

    uart_send_string("Initializing the bare metal os...\n");
    uart_send_string("HELLO WORKLD !!\n");

    while(1) {
        uart_send(uart_recv());
    };
}
