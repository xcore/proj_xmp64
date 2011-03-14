#include <platform.h>
#include <xs1.h>

on stdcore[60]: out port led_60 = XS1_PORT_1E;

void lightUp(out port led) {
    led <: 0x1;
    while (1) { }
}

int main() {
  par {
    on stdcore[60] : lightUp(led_60);
  }
  return 0;
}
