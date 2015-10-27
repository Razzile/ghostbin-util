//
//  main.m
//  ghostbin
//
//  Created by callum taylor on 27/10/2015.
//  Copyright © 2015 satori. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <stdio.h>
#import "Ghostbin.h"


void print_help(const char *name) {
    printf("ghostbin util created by %sSatori%s\n", KCYN, KNRM);
    printf("usage: %s %s-s [string] or -f [file]%s |%s -t [title] (optional) | -p [password] (optional) %s|%s -h (help)%s\n",
            name, KGRN, KNRM, KBLU, KNRM, KYEL, KNRM);
}

int main(int argc, char * const*argv) {
    /* check if ran from terminal so we can output colors */
    if (isatty(fileno(stdout))) {
        KNRM = "\x1B[00m";
        KRED = "\x1B[31m";
        KGRN = "\x1B[32m";
        KYEL = "\x1B[33m";
        KBLU = "\x1B[34m";
        KMAG = "\x1B[35m";
        KCYN = "\x1B[36m";
        KWHT = "\x1B[37m";
    }
    
    GhostbinSettings settings;
    @autoreleasepool {
        /* get args */
        if (argc == 1) {
            settings.flags |= kFromPasteboard;
        }
        int c;
        while ((c = getopt(argc, argv, "hf:s:p:t:")) != -1) {
            switch (c) {
                case 'f': {
                    settings.flags |= kFromFile;
                    settings.file = optarg;
                    break;
                }
                case 's': {
                    settings.flags |= kFromString;
                    settings.string = optarg;
                    break;
                }
                case 'p': {
                    settings.password = optarg;
                    break;
                }
                case 't': {
                    settings.title = optarg;
                    break;
                }
                case 'h':
                default: {
                    print_help(argv[0]);
                    return 0;
                }
            }
        }
        printf("%s creating paste...%s\n", KYEL, KNRM);
        /* try and create paste */
        Ghostbin *gb = [[Ghostbin alloc] initWithSettings:settings];
        return [gb tryCreatePaste];
    }
    return 0;
}
