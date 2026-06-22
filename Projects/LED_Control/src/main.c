#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>

#define SYSFS_LEDS_PATH "/sys/class/leds"

#define USR_LED_NUMBER 3
#define SOME_BYTES 100

int write_trigger_values(uint8_t led_no, char *value){
    int fd, ret = 0;
    char buf[SOME_BYTES];

    snprintf(buf, sizeof(buf), SYSFS_LEDS_PATH "/beaglebone:green:usr%d/trigger", led_no);
    
    fd = open(buf, O_WRONLY);
    if (fd <= 0) {
        perror("Write trigger error: Failed to open LED trigger file");
        return -1;
    }
    ret = write(fd, value, sizeof(value));
    if (ret <= 0) {
        perror("Write trigger error: Failed to write LED trigger value");
        close(fd);
        return -1;
    }
    close(fd);
    return 0;
}

void process_trigger_value(char *value){
    if(strcmp(value, "none") == 0 || \
       strcmp(value, "timer") == 0 || \
       strcmp(value, "heartbeat") == 0 || \
       strcmp(value, "mmc0") == 0 || \
       strcmp(value, "mmc1") == 0 || \
       strcmp(value, "default-on") == 0 || \
       strcmp(value, "gpio") == 0 || \
       strcmp(value, "pwm") == 0 || \
       strcmp(value, "transient") == 0 || \
       strcmp(value, "oneshot") == 0){
        write_trigger_values(USR_LED_NUMBER, value);
    }
    else {
        printf("Invalid trigger value. Valid values are: none, timer, heartbeat, mmc0, mmc1, default-on, gpio, pwm, transient, or oneshot\n");
    }
}

int write_brightness_value(uint8_t led_no, int value){
    int fd, ret = 0;
    char buf[SOME_BYTES];
    
    snprintf(buf, sizeof(buf), SYSFS_LEDS_PATH "/beaglebone:green:usr%d/brightness", led_no);

    fd = open(buf, O_WRONLY);
    if (fd <= 0) {
        perror("Write brightness error");
        return -1;
    }

    ret = write(fd, &value, sizeof(value));
    if (ret <= 0) {
        perror("Write brightness error");
        close(fd);
        return -1;
    }

    close(fd);
    return 0;
}

void process_brightness_value(int value){
    switch(value){
        case 0:
            write_brightness_value(USR_LED_NUMBER, value);
            break;
        case 1:
            write_brightness_value(USR_LED_NUMBER, value);
            break;
        default:
            printf("Invalid brightness value. Valid values are: 0 or 1\n");
    }           
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf("Usage: %s <control_option> <value>\n", argv[0]);
        printf("valid control options: brightness, trigger\n");
        printf("value for brightness: 0 or 1\n");
        printf("value for trigger: none, timer, heartbeat, mmc0, mmc1, default-on, gpio, pwm, transient, or oneshot\n");
    }
    else {
        if(strcmp(argv[1], "trigger") == 0){
            process_trigger_value(argv[2]);
        }
        else if(strcmp(argv[1], "brightness") == 0){
            int value = atoi(argv[2]);
            process_brightness_value(value);
        }
        else {
            printf("Invalid control option. Valid options are: brightness, trigger\n");
        }
    }

    return 0;
}
