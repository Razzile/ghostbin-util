//
//  Ghostbin.h
//  ghostbin
//
//  Created by callum taylor on 27/10/2015.
//  Copyright © 2015 satori. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

/* Terminal color placeholder */
extern const char *KNRM;
extern const char *KRED;
extern const char *KGRN;
extern const char *KYEL;
extern const char *KBLU;
extern const char *KMAG;
extern const char *KCYN;
extern const char *KWHT;

/* flags */
#define kFromPasteboard 1
#define kFromFile (1 << 1)
#define kFromString (1 << 2)

typedef struct GhostbinSettings {
    char flags;
    const char *file;
    const char *string;
    const char *title;
    const char *password;
} GhostbinSettings;

@interface Ghostbin : NSObject <NSURLSessionDelegate>

@property GhostbinSettings *settings;

- (instancetype)initWithSettings:(GhostbinSettings)settings;

- (BOOL)tryCreatePaste;

@end
