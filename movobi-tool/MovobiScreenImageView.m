//
//  MovobiScreenImageView.m
//  movobi-tool
//
//  Created by Ed Daly on 14/04/2013.
//  Copyright (c) 2013 Movobi Ltd. All rights reserved.
//

#import "MovobiScreenImageView.h"
#import "Tag.h"

@implementation MovobiScreenImageView

@synthesize tagRects;
@synthesize selectedTagIndex;


- (void)awakeFromNib
{
    // Initialization code here.
    selectedTagIndex = [NSNumber numberWithInt:-1]; //i.e. take to mean no selected tag
}

- (void)drawTagArea:(CGRect) rect  withHighlight: (BOOL) highlighted
{
    NSColor* colour;
    CGBlendMode blendMode;
    if (highlighted)
    {
        blendMode = kCGBlendModePlusLighter;
        colour = [NSColor whiteColor];
    }
    else
    {
        blendMode = kCGBlendModeNormal;
        colour = [NSColor blackColor];
    }
    [colour setStroke];
    //CGContextSetBlendMode ([[NSGraphicsContext currentContext] CIContext] , blendMode);
    [NSBezierPath strokeRect: rect];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect: dirtyRect];
    
    NSGraphicsContext* theContext = [NSGraphicsContext currentContext];
    [theContext saveGraphicsState];
    
    int i = 0;
    CGRect selectedRect;
    for (NSValue *rectObj in tagRects)
    {
        CGRect rect = [rectObj rectValue];
        if (selectedTagIndex.intValue != i)
            [self drawTagArea: rect withHighlight: NO];
        else
            selectedRect = rect;
        i++;
    }
    if (selectedTagIndex.intValue != -1 && tagRects != nil) //draw highlighted tag last in case under others
        [self drawTagArea: selectedRect withHighlight: YES];

    [theContext restoreGraphicsState];
}

@end
