//
//  SDMNetwork.m
//  SparseDistMemory
//
//  Created by Jon Como on 5/29/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "SDMNetwork.h"

#import "NSString+Bits.h"

@implementation SDMNetwork

-(id)initWithSize:(SDMSize)size
{
    if (self = [super init]) {
        //init
        _size = size;
        
        _time = 0;
        
        _neurons = [NSMutableArray array];
        
        int sideLength = sqrt(size.length);
        
        for (int i = 0; i<size.depth; i++)
        {
            NSMutableArray *layer = [NSMutableArray arrayWithCapacity:size.length];
            for (int i = 0; i<size.length; i++) {
                SDMNeuron *neuron = [SDMNeuron new];
                neuron.x = i % sideLength;
                neuron.y = (int)(i / sideLength);
                [layer addObject:neuron];
            }
            
            [_neurons addObject:layer];
        }
    }
    
    return self;
}

-(void)reset
{
    self.time = 0;
    
    for (NSMutableArray *layer in self.neurons)
    {
        for (int i = 0; i<layer.count; i++) {
            SDMNeuron *neuron = layer[i];
            [neuron reset];
        }
    }
}

-(void)processStream:(NSArray *)stream
{
    NSLog(@"Processing: %@", [self stringFromStream:stream]);
    
    /*
    for (SDMNeuron *neuron in self.neurons[0]){
        neuron.isActive = NO;
    }
    
    for (NSNumber *index in stream){
        SDMNeuron *neuron = self.neurons[0][[index intValue]];
        neuron.isActive = YES;
    } */
    
    self.time++;
}

-(void)processState
{
    //but really want to form relationships between currently lit neurons and previously lit neurons
    
    NSMutableArray *activeNeurons = [NSMutableArray array];
    for (SDMNeuron *neuron in self.neurons[0]){
        
        [neuron setActive:neuron.isActive AtTime:self.time];
        
        if (neuron.isActive){
            [activeNeurons addObject:neuron];
        }
    }
    
    //link it up to previous neurons
    NSMutableArray *previousNeurons = [NSMutableArray array];
    for (SDMNeuron *previousNeuron in self.neurons[0]){
        if ([previousNeuron isActiveAtTime:self.time-1]){
            [previousNeurons addObject:previousNeuron];
        }
    }
    
    NSLog(@"Previous: %@ Current: %@", previousNeurons, activeNeurons);
    
    for (SDMNeuron *prevNeuron in previousNeurons){
        //create link from previous neuron to current, with reference to time as well
        NSMutableArray *indeces = [NSMutableArray array];
        
        for (SDMNeuron *activeNeuron in activeNeurons){
            int index = [self.neurons[0] indexOfObject:activeNeuron];
            [indeces addObject:@(index)];
        }
        
        [prevNeuron shouldFireIndeces:indeces atTime:self.time];
    }
    
    [self clearLevel:0]; //clear base level
    
    self.time ++;
}

-(void)clearLevel:(int)index
{
    NSMutableArray *level = self.neurons[index];
    for (SDMNeuron *neuron in level){
        neuron.isActive = NO;
    }
}

-(NSString *)stringFromStream:(NSArray *)stream
{
    NSString *string = @"";
    for (int i = 0; i<self.size.length; i++)
    {
        BOOL foundIndex = NO;
        for (NSNumber *index in stream)
        {
            if ([index intValue] == i)
            {
                foundIndex = YES;
            }
        }
        
        string = [NSString stringWithFormat:@"%@%i", string, foundIndex];
    }
    
    return string;
}

-(UIImage *)imageFromLevel:(int)level
{
    int sideLength = sqrt(self.size.length);
    UIGraphicsBeginImageContext(CGSizeMake(sideLength, sideLength));
    
    CGContextRef ref = UIGraphicsGetCurrentContext();
    
    BOOL gray = NO;
    
    for (int i = 0; i < self.size.length; i++) {
        
        SDMNeuron *neuron = self.neurons[level][i];
        
        gray = !gray;
        if (i % sideLength == 0) gray = !gray;
        if (gray) { [[UIColor colorWithWhite:.9 alpha:1] setFill]; }else{ [[UIColor whiteColor] setFill]; }
        
        if (neuron.isActive){
            [[UIColor blackColor] setFill];
        }
        
        CGContextFillRect(ref, CGRectMake(neuron.x, neuron.y, 1, 1));
    }
    
    
    if (self.showsPredictions){
        [[UIColor orangeColor] setFill];
        
        for (SDMNeuron *neuron in self.neurons[level])
        {
            if (neuron.isActive){
                
                NSArray *indecesToFire = [neuron indecesFiredAtTime:self.time+1];
                if (indecesToFire) {
                    for (NSNumber *index in indecesToFire){
                        CGPoint point = [self pointForIndex:[index intValue]];
                        CGContextFillRect(ref, CGRectMake(point.x, point.y, 1, 1));
                    }
                }
            }
        }
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

-(CGPoint)pointForIndex:(int)index
{
    int sideLength = sqrt(self.size.length);
    
    int x = index%sideLength;
    int y = round(index / sideLength);
    
    return CGPointMake(x, y);
}

-(SDMNeuron *)neuronAtLevel:(int)level index:(int)index
{
    if (index > self.size.length) return nil;
    return self.neurons[level][index];
}

-(void)setTime:(int)time
{
    _time = time;
    
    //change state to show saved patterns
    for (SDMNeuron *neuron in self.neurons[0]){
        neuron.isActive = [neuron isActiveAtTime:time];
    }
}

@end