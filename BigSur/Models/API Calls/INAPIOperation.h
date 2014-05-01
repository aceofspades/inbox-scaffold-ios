//
//  INAPICall.h
//  BigSur
//
//  Created by Ben Gotow on 4/22/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "INModelObject.h"

static NSString * INAPIOperationCompleteNotification = @"INAPIOperationCompleteNotification";

@interface INAPIOperation : AFHTTPRequestOperation <NSCoding>

@property (nonatomic, strong) Class modelClass;
@property (nonatomic, strong) NSDictionary * modelRollbackDictionary;

+ (INAPIOperation *)operationWithMethod:(NSString *)method forModel:(INModelObject *)model;

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

- (BOOL)invalidatesPreviousQueuedOperation:(AFHTTPRequestOperation *)other;

- (void)rollback;

@end