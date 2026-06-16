#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>

#define SYSFS_LEDS_PATH "/sys/class/leds/"
#define LED0_PATH SYSFS_LEDS_PATH "beaglebone:green:usr0/brightness"

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <on|off>\n", argv[0]);
        return EXIT_FAILURE;
    }
    else
    {
        if (strcmp(argv[1], "trigger") == 0)
        {
            process_trigger_values(argv[2]);
        }
        else if (strcmp(argv[1], "brightness") == 0)
        {
            int brightness_value = atoi(argv[2]);
            process_brightness_values(brightness_value);
        }
        else
        {
            fprintf(stderr, "Invalid argument: %s. Use 'on' or 'off'.\n", argv[1]);
            return EXIT_FAILURE;
        }
    }

}