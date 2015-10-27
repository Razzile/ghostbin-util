//
//  Ghostbin.m
//  ghostbin
//
//  Created by callum taylor on 27/10/2015.
//  Copyright © 2015 satori. All rights reserved.
//

#import "Ghostbin.h"

const char *KNRM = "";
const char *KRED = "";
const char *KGRN = "";
const char *KYEL = "";
const char *KBLU = "";
const char *KMAG = "";
const char *KCYN = "";
const char *KWHT = "";


/* nasty shameful global variables */
dispatch_semaphore_t nastySemaphore;
long nastyResponse = 400;
NSString *finalURL = nil;

@implementation Ghostbin

- (instancetype)initWithSettings:(GhostbinSettings)settings {
    if (self = [super init]) {
        self.settings = malloc(sizeof(settings));
        memcpy(self.settings, &settings, sizeof(settings));
    }
    return self;
}

- (BOOL)tryCreatePaste {
    BOOL success = NO;
    char flags = self.settings->flags;
    
    /* create request data */
    NSMutableString *postString = [NSMutableString stringWithString:@""];
    if (flags & kFromString) {
        NSString *contents = [NSString stringWithUTF8String:self.settings->string];
        [postString appendString:[NSString stringWithFormat:@"text=%@", contents]];
    }
    else if (flags & kFromFile) {
        NSError *error = nil;
        NSString *contents = [NSString stringWithContentsOfFile:[NSString stringWithUTF8String:self.settings->file]
                                                                          encoding:NSUTF8StringEncoding error:&error];
        [postString appendString:[NSString stringWithFormat:@"text=%@", contents]];
        if (error) {
            printf("%sfatal error: %s%s\n", KRED, error.localizedDescription.UTF8String, KNRM);
            exit(1);
        }
    }
    else if (flags & kFromPasteboard) {
        NSPasteboard *pasteboard  = [NSPasteboard generalPasteboard];
        NSString *contents = [pasteboard  stringForType:NSPasteboardTypeString];
        [postString appendString:[NSString stringWithFormat:@"text=%@", contents]];
    }
    else {
        printf ("%s fatal error: no data sent%s\n", KRED, KNRM);
        exit(1);
    }
    
    if (self.settings->password) {
        [postString appendString:[NSString stringWithFormat:@"&password=%@", [NSString stringWithUTF8String:self.settings->password]]];
    }
    
    if (self.settings->title) {
        [postString appendString:[NSString stringWithFormat:@"&title=%@", [NSString stringWithUTF8String:self.settings->title]]];
    }
    
    [postString appendString:@"&expire=-1"]; // cba to deal with expiration
    
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    /* make request */
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:@"https://ghostbin.com/paste/new"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    nastySemaphore = dispatch_semaphore_create(0);
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    NSURLSessionTask *task = [session dataTaskWithRequest:request];
    [task resume];
    dispatch_semaphore_wait(nastySemaphore, DISPATCH_TIME_FOREVER);
    
    if (nastyResponse == 400) {
        printf("%s an error has occured creating paste%s\n", KRED, KNRM);
    }
    else if (finalURL) {
        printf("paste created at: %s%s%s\n",KGRN, finalURL.UTF8String, KNRM);
        success = YES;
    }

    return success;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler {
    
    /* incoming vomit material */
    
    completionHandler(nil);
    
    nastyResponse = [response statusCode];
    
    finalURL = [[request URL] absoluteString];
    
    dispatch_semaphore_signal(nastySemaphore);
}

- (void)dealloc {
    free(self.settings);
}

@end
