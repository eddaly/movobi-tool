//
//  MovobiImageTransformer.m
//  movobi
//
//  Created by Ed Daly on 30/03/2013.
//  Copyright (c) 2013 Movobi Ltd. All rights reserved.
//

@interface MovobiImageTransformer2 : NSValueTransformer

@end

@implementation MovobiImageTransformer2


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
    NSValueTransformer *t = [NSValueTransformer valueTransformerForName: NSKeyedUnarchiveFromDataTransformerName];
    if (t == nil)
        return nil;
    return (NSImage*)[t transformedValue: value];
}

@end
