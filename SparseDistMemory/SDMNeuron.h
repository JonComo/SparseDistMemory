//
//  SDMNeuron.h
//  SparseDistMemory
//
//  Created by Jon Como on 5/29/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDMNeuron : NSObject

@property BOOL isActive;

//drawing
@property int x, y;

@property (nonatomic, strong) NSMutableArray *active;

@property (nonatomic, strong) NSMutableArray *relationships;

@property float energy;

-(void)setActive:(BOOL)isActive AtTime:(int)time;

-(BOOL)isActiveAtTime:(int)time;

-(void)shouldFireNeurons:(NSArray *)neurons atTime:(int)time;
-(NSArray *)neuronsFiredAtTime:(int)time;

-(void)reset;

@end