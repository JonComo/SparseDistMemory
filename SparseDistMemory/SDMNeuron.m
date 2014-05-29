//
//  SDMNeuron.m
//  SparseDistMemory
//
//  Created by Jon Como on 5/29/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "SDMNeuron.h"

@implementation SDMNeuron

-(id)init
{
    if (self = [super init]) {
        //init
        _active = [NSMutableArray array];
        _relationships = [NSMutableArray array];
    }
    
    return self;
}

-(void)setActive:(BOOL)isActive AtTime:(int)time
{
    BOOL foundIndex = NO;
    
    for (NSNumber *index in self.active){
        if ([index intValue] == time){
            foundIndex = YES;
        }
    }
    
    if (foundIndex){
        if (!isActive)
            [self.active removeObjectAtIndex:time];
    }else{
        //Add it if its active
        if (isActive)
            [self.active addObject:@(time)];
    }
}

-(BOOL)isActiveAtTime:(int)time
{
    BOOL foundIndex = NO;
    
    for (NSNumber *index in self.active){
        if ([index intValue] == time){
            foundIndex = YES;
        }
    }
    
    return foundIndex;
}

-(void)reset
{
    [self.active removeAllObjects];
}

-(void)shouldFireIndeces:(NSArray *)indeces atTime:(int)time
{
    BOOL foundRelation = NO;
    
    for (NSMutableDictionary *relation in self.relationships)
    {
        if ([relation[@"time"] intValue] == time){
            foundRelation = YES;
            relation[@"indeces"] = indeces;
        }
    }
    
    if (!foundRelation)
    {
        NSMutableDictionary *relation = [@{@"time": @(time), @"indeces": indeces} mutableCopy];
        [self.relationships addObject:relation];
    }
}

-(NSArray *)indecesFiredAtTime:(int)time
{
    for (NSMutableDictionary *relation in self.relationships)
    {
        if ([relation[@"time"] intValue] == time){
            return relation[@"indeces"];
        }
    }
    
    return nil;
}

@end