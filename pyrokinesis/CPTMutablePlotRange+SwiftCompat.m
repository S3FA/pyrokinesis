//
//  CPTMutablePlotRange+SwiftCompat.m
//  pyrokinesis
//
//  Created by Callum Hay on 2015-06-24.
//  Copyright (c) 2015 s3fa. All rights reserved.
//

#import "CPTMutablePlotRange+SwiftCompat.h"

@implementation CPTMutablePlotRange (SwiftCompat)

- (void)setLengthFloat:(float)lengthFloat
{
    NSNumber *number = [NSNumber numberWithFloat:lengthFloat];
    [self setLength:number];
}

@end
