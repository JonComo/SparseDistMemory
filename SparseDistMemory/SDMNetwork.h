//
//  SDMNetwork.h
//  SparseDistMemory
//
//  Created by Jon Como on 5/29/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SDMNeuron.h"

struct SDMSize {
    int length;
    int depth;
};
typedef struct SDMSize SDMSize;

CG_INLINE SDMSize
SDMSizeMake(int length, int depth)
{
    SDMSize size; size.length = length; size.depth = depth;
    return size;
}

@interface SDMNetwork : NSObject

@property (nonatomic, strong) NSMutableArray *neurons;
@property SDMSize size;

@property BOOL showsPredictions;

@property (nonatomic, assign) int time;

-(id)initWithSize:(SDMSize)size;

-(void)reset;
-(void)processStream:(NSArray *)stream;
-(void)processState;

-(SDMNeuron *)neuronAtLevel:(int)level index:(int)index;

-(UIImage *)imageFromLevel:(int)level;

-(CGPoint)pointForIndex:(NSUInteger)index;

@end