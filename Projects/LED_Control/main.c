#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>

#define SYSFS_LEDS_PATH "/sys/class/leds/"
#define LED0_PATH SYSFS_LEDS_PATH "beaglebone:green:usr0/brightness"

int main() {
    int fd;
    char buffer[16];

    // Open the LED brightness file
    fd = open(LED0_PATH, O_WRONLY);
    if (fd < 0) {
        perror("Failed to open LED brightness file");
        return EXIT_FAILURE;
    }

    // Turn the LED on (set brightness to 1)
    snprintf(buffer, sizeof(buffer), "%d", 1);
    if (write(fd, buffer, strlen(buffer)) < 0) {
        perror("Failed to write to LED brightness file");
        close(fd);
        return EXIT_FAILURE;
    }
    printf("LED turned ON\n");

    sleep(2); // Keep the LED on for 2 seconds

    // Seek back to beginning before writing again
    lseek(fd, 0, SEEK_SET);

    // Turn the LED off (set brightness to 0)
    snprintf(buffer, sizeof(buffer), "%d", 0);
    if (write(fd, buffer, strlen(buffer)) < 0) {
        perror("Failed to write to LED brightness file");
        close(fd);
        return EXIT_FAILURE;
    }
    printf("LED turned OFF\n");

    close(fd);
    return EXIT_SUCCESS;
}