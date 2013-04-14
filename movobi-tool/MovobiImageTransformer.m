//
//  MovobiImageTransformer.m
//  movobi
//
//  Created by Ed Daly on 30/03/2013.
//  Copyright (c) 2013 Movobi Ltd. All rights reserved.
//

#import "MovobiImageTransformer.h"

@implementation MovobiImageTransformer


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
    NSImage *img = (NSImage *)value;
    CGImageRef CGImage = [img CGImageForProposedRect:nil context:nil hints:nil];
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage:CGImage];
    NSData *data = [rep representationUsingType: NSPNGFileType properties: nil];
	return data;
}

- (id)reverseTransformedValue:(id)value
{
	NSImage *image = [[NSImage alloc] initWithData:value];
    return image;
}

@end
