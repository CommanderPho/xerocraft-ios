//
//  BackendApiCommunicator.h
//  Xerocraft
//
//  Created by Adrian Boyko on 8/10/15.
//  Copyright (c) 2015 Adrian Boyko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BackendApiCommunicator : NSObject

typedef void(^ActionBlock)(NSDictionary*);

+ (BackendApiCommunicator*)sharedInstance;

typedef NS_ENUM(UInt8, VisitEventType) {
    VisitTypeArrival   = 'A',
    VisitTypePresent   = 'P',
    VisitTypeDeparture = 'D'
};

- (void)getMemberDetailsForStr:(NSString*)memberCardStr
                    onBehalfOf:(NSString*)staffCardStr
                       success:(ActionBlock)successBlock
                       failure:(ActionBlock)failureBlock;

- (void)getPermitDetailsForNum:(NSUInteger)permitNum
                       success:(ActionBlock)successBlock
                       failure:(ActionBlock)failureBlock;

- (void)notePermitScanOf:(NSUInteger)permitNum atLocation:(NSUInteger)locationNum
                 success:(ActionBlock)successBlock
                 failure:(ActionBlock)failureBlock;

- (void)noteVisitEventFor:(NSString*)visitorCardStr eventType:(VisitEventType)eventType
                  success:(ActionBlock)successBlock
                  failure:(ActionBlock)failureBlock;


@end
