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
    
    for (SDMNeuron *prevNeuron in previousNeurons){
        //create link from previous neuron to current, with reference to time as well
        [prevNeuron shouldFireNeurons:activeNeurons atTime:self.time];
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
    
    for (SDMNeuron *neuron in self.neurons[level])
    {
        gray = !gray;
        if ([self.neurons[level] indexOfObject:neuron] % sideLength == 0) gray = !gray;
        if (gray) { [[UIColor colorWithWhite:.9 alpha:1] setFill]; }else{ [[UIColor whiteColor] setFill]; }
        
        CGContextFillRect(ref, CGRectMake(neuron.x, neuron.y, 1, 1));
    }
    
    if (self.showsPredictions)
    {
        //Render predicitons a few steps ahead
        
        [[UIColor orangeColor] setFill];
        
        for (SDMNeuron *neuron in self.neurons[level]){
            neuron.energy = 0;
        }
        
        for (int pTime = self.time; pTime < self.time + 3; pTime ++)
        {
            for (SDMNeuron *neuron in self.neurons[level])
            {
                if (neuron.isActive || neuron.energy > 0.3){
                    
                    NSArray *neuronsToFire = [neuron neuronsFiredAtTime:pTime+1];
                    for (SDMNeuron *neuron in neuronsToFire){
                        neuron.energy += .1;
                        CGPoint point = [self pointForIndex:[self.neurons[level] indexOfObject:neuron]];
                        CGContextFillRect(ref, CGRectMake(point.x, point.y, 1, 1));
                    }
                }
            }
        }
        
        
    }
    
    for (SDMNeuron *neuron in self.neurons[level])
    {
        if (neuron.isActive){
            [[UIColor blackColor] setFill];
            CGContextFillRect(ref, CGRectMake(neuron.x, neuron.y, 1, 1));
        }
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

-(CGPoint)pointForIndex:(NSUInteger)index
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