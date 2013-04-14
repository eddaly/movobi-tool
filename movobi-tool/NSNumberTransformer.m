//
//  NSNumberTransformer.m
//  movobi
//
//  Created by Ed Daly on 30/03/2013.
//  Copyright (c) 2013 Movobi Ltd. All rights reserved.
//

#import "NSNumberTransformer.h"

@implementation NSNumberTransformer


+ (BOOL)allowsReverseTransformation
{
    return YES;
}

+ (Class)transformedValueClass
{
    return [NSData class];
}

- (id)transformedValue:(id)value
{
    return value;
}

- (id)reverseTransformedValue:(id)value
{   // For when strings sent from table cell
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * number = [f numberFromString: value];
	return number;
}

@end
