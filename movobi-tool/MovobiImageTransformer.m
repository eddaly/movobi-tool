//
//  MovobiImageTransformer.m
//  movobi
//
//  Created by Ed Daly on 30/03/2013.
//  Copyright (c) 2013 Movobi Ltd. All rights reserved.
//

@interface MovobiImageTransformer : NSValueTransformer

@end

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
    if (img != nil)
    {
        CGImageRef CGImage = [img CGImageForProposedRect:nil context:nil hints:nil];
        NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage:CGImage];
        return [rep representationUsingType: NSPNGFileType properties: nil];
    }
    else
        return nil;
}

- (id)reverseTransformedValue:(id)value
{
	if (value != nil)
        return [[NSImage alloc] initWithData:value];
    else
        return nil;
}

@end
