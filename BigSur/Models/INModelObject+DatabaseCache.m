//
//  INModelObject+DatabaseCache.m
//  BigSur
//
//  Created by Ben Gotow on 4/24/14.
//  Copyright (c) 2014 Inbox. All rights reserved.
//

#import "INModelObject+DatabaseCache.h"
#import "INDatabaseManager.h"
#import "INPredicateConverter.h"

@implementation INModelObject (DatabaseCache)

#pragma Database Representation

+ (NSString*)databaseTableName
{
    return NSStringFromClass(self);
}

+ (NSString*)databaseReplaceStatement
{
    NSArray * cols = [[self resourceMapping] allValues];
    NSString * colsStr = [NSString stringWithFormat:@"`%@`", [cols componentsJoinedByString: @"`,`"]];
    NSMutableArray * vals = [NSMutableArray array];
    for (NSString * col in cols)
        [vals addObject: [NSString stringWithFormat:@":%@", col]];
    NSString * valsStr = [vals componentsJoinedByString:@","];
    
    return [NSString stringWithFormat: @"REPLACE INTO %@ (%@) VALUES (%@)", [self databaseTableName], colsStr, valsStr];
}

#pragma Database Retrieval

+ (void)persistedInstancesMatching:(NSPredicate*)wherePredicate sortedBy:(NSArray*)sortDescriptors limit:(int)limit offset:(int)offset withCallback:(ResultsBlock)callback
{
    NSMutableString * query = [[NSMutableString alloc] initWithFormat: @"SELECT * FROM %@", [self databaseTableName]];
    INPredicateConverter * converter = [[INPredicateConverter alloc] init];
    [converter setTargetModelClass: self];
    
    if (wherePredicate) {
        NSString * whereClause = [converter SQLFilterForPredicate: wherePredicate];
        [query appendFormat: @" WHERE %@", whereClause];
    }
    
    if ([sortDescriptors count] > 0) {
        NSMutableArray * sortClauses = [NSMutableArray array];
        for (NSSortDescriptor * descriptor in sortDescriptors) {
            NSString * sql = [converter SQLSortForSortDescriptor: descriptor];
            if (sql) [sortClauses addObject: sql];
        }
        [query appendFormat:@" ORDER BY %@", [sortClauses componentsJoinedByString:@", "]];
    }
    
    [self persistedInstancesForQuery:query withParameters:nil andCallback:callback];
}

+ (void)persistedInstancesForQuery:(NSString*)query withParameters:(NSDictionary*)arguments andCallback:(ResultsBlock)callback
{
    [[INDatabaseManager shared] selectModelsOfClass:self withQuery:query andParameters:arguments andCallback:callback];
}

- (void)persist
{
    [[INDatabaseManager shared] persistModel: self];
}

@end