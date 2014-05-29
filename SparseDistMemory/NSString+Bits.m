//
//  NSString+Bits.m
//  SparseDistMemory
//
//  Created by Jon Como on 5/29/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "NSString+Bits.h"

@implementation NSString (Bits)

+ (NSString *)getBitStringForDouble:(int)value {
    
    NSString *bits = @"";
    
    for(int i = 0; i < 8; i ++) {
        bits = [NSString stringWithFormat:@"%i%@", value & (1 << i) ? 1 : 0, bits];
    }
    
    return bits;
}

@end
