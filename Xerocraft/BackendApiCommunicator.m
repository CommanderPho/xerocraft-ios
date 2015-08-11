//
//  BackendApiCommunicator.m
//  Xerocraft
//
//  Created by Adrian Boyko on 8/10/15.
//  Copyright (c) 2015 Adrian Boyko. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BackendApiCommunicator.h"
#import "AppState.h"

@implementation BackendApiCommunicator

+ (id)sharedInstance {
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}

UIAlertView* simpleAlert(NSString *title, NSString *msg) {
    UIAlertView *alert = [UIAlertView alloc];
    return [alert initWithTitle:title
                        message:msg
                       delegate:nil
              cancelButtonTitle:@"Continue"
              otherButtonTitles:nil];
}

- (void)talkToServer:(NSString*)urlStr successAction:(ActionBlock)block{
    
    //TODO: This doesn't deal with 404, etc.
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLSession *session = [NSURLSession sharedSession];
    session.configuration.timeoutIntervalForRequest = 2;
    NSURLSessionDataTask *task =
    [session
     dataTaskWithURL:url
     completionHandler:
     ^(NSData *data, NSURLResponse *urlResponse, NSError *connectError){
         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)urlResponse;
         NSInteger statusCode = httpResponse.statusCode;
         NSString *statusText = [NSHTTPURLResponse localizedStringForStatusCode:statusCode];
         NSError* parseError = nil;
         NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
         NSString *xerocraftError = [json objectForKey:@"error"]; // E.g. would violate Xerocraft business rules.
         dispatch_async(dispatch_get_main_queue(),^{
             UIAlertView *alert = nil;
             if (connectError) {
                 alert = simpleAlert(@"Error", @"Couldn't connect to server.");
             }
             else if (statusCode >= 500) {
                 NSString *alertMsg = [NSString stringWithFormat:@"%ld: %@", (long)statusCode, statusText];
                 alert = simpleAlert(@"Server Error", alertMsg);
             }
             else if (statusCode >= 400) {
                 NSString *alertMsg = [NSString stringWithFormat:@"%ld: %@\nCheck your config.", (long)statusCode, statusText];
                 alert = simpleAlert(@"Client Error", alertMsg);
             }
             else if (parseError) {
                 alert = simpleAlert(@"JSON Error", @"Couldn't parse response.");
             }
             else if (xerocraftError) {
                 if ([xerocraftError isEqualToString:@"Invalid staff card"]) {
                     alert = simpleAlert(@"Config Error", @"This app doesn't have a valid copy of YOUR card (not the one you're scanning).");
                     //AppState.sharedInstance.myCardString = nil;
                 }
                 if ([xerocraftError isEqualToString:@"Invalid member card"]) {
                     alert = simpleAlert(@"Error", @"The card you're scanning isn't a valid membership card.");
                 }
                 if ([xerocraftError isEqualToString:@"Not a staff member"]) {
                     alert = simpleAlert(@"Error", @"You can't scan this card because you are not a staff member.");
                 }
             }
             else {
                 assert(alert == nil);
                 if (block) block(json);
             }
             if (alert) [alert show];
             
         });
     }
     ];
    [task resume];
}

- (void)getMemberDetailsForStr:(NSString*)memberCardStr onBehalfOf:(NSString*)staffCardStr success:(ActionBlock)successBlock {
    NSString *server = AppState.sharedInstance.server;
    NSString *urlPattern = @"http://%@/members/api/member-details/%@_%@/";
    NSString *urlStr = [NSString stringWithFormat:urlPattern, server, memberCardStr, staffCardStr];
    [self talkToServer:urlStr successAction:successBlock];
}

- (void)getPermitDetailsForNum:(NSUInteger)permitNum success:(ActionBlock)successBlock {
    NSString *server = AppState.sharedInstance.server;
    NSString *urlPattern = @"http://%@/inventory/get-permit-details/%lu/";
    NSString *urlStr = [NSString stringWithFormat:urlPattern, server, (UInt32)permitNum];
    [self talkToServer:urlStr successAction:successBlock];
}

- (void)notePermitScanOf:(NSUInteger)permitNum atLocation:(NSUInteger)locationNum success:(ActionBlock)successBlock {
    NSString *server = AppState.sharedInstance.server;
    NSString *urlPattern = @"http://%@/inventory/note-permit-scan/%lu_%lu/";
    NSString *urlStr = [NSString stringWithFormat:urlPattern, server, (UInt32)permitNum, (UInt32)locationNum];
    [self talkToServer:urlStr successAction:successBlock];
}

- (void)noteVisitEventFor:(NSString *)visitorCardStr eventType:(VisitEventType)eventType success:(ActionBlock)successBlock {
    NSString *server = AppState.sharedInstance.server;
    NSString *urlPattern = @"http://%@/members/api/visit-event/%@_%c/";
    NSString *urlStr = [NSString stringWithFormat:urlPattern, server, visitorCardStr, eventType];
    [self talkToServer:urlStr successAction:successBlock];
}

@end












































