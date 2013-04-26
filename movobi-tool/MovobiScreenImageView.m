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
@synthesize draggingSelectedTag;
@synthesize scalingSelectedTag;
@synthesize origSelectedTagRect;
@synthesize mouseUpAction;
@synthesize drawRectAction;
@synthesize target;

- (void)awakeFromNib
{
    // Initialization code here.
    selectedTagIndex = [NSNumber numberWithInt:-1]; //i.e. take to mean no selected tag
    draggingSelectedTag = scalingSelectedTag = FALSE;
}

- (void)drawTagArea:(CGRect) rect  withHighlight: (BOOL) highlighted
{
    NSColor* colour;
    CGBlendMode blendMode;
    if (highlighted)
    {
        blendMode = kCGBlendModePlusLighter;
        colour = [NSColor greenColor];
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
    
    // Unless dragging/scaling, tell controller I'm about to draw (so it can prepare tags)
    if (!draggingSelectedTag && !scalingSelectedTag)
        [NSApp sendAction:[self drawRectAction] to:[self target] from:self];
    
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

- (void)mouseDown:(NSEvent *)theEvent
{
    if ([self.selectedTagIndex intValue] == -1)
        return; // Could allow select for first click
    
    origSelectedTagRect = [[tagRects objectAtIndex: [selectedTagIndex integerValue]] rectValue];
    draggingSelectedTag = NSPointInRect([self convertPoint:[theEvent locationInWindow] fromView:nil], origSelectedTagRect);
    if (!draggingSelectedTag)
        scalingSelectedTag = TRUE;
}

-(void)mouseDragged:(NSEvent *)theEvent
{
    CGRect selectedTagRect = [[tagRects objectAtIndex: [selectedTagIndex integerValue]] rectValue];
    
    if (draggingSelectedTag)
    {
        selectedTagRect.origin.x += [theEvent deltaX];
        selectedTagRect.origin.y -= [theEvent deltaY];
    }
    else
    {
        selectedTagRect.size.width += [theEvent deltaX];
        selectedTagRect.size.height -= [theEvent deltaY];
    
    }
    [self setNeedsDisplay];
    NSValue *tagRectObj = [NSValue valueWithRect: selectedTagRect];
    [tagRects replaceObjectAtIndex: [selectedTagIndex integerValue] withObject: tagRectObj];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    draggingSelectedTag = scalingSelectedTag = FALSE;
    
    // CODE TO RESET BUT NEEDS TO BE CALLED SOME OTHER TIME OR NOT AT ALL
    /*{
        NSValue *tagRectObj = [NSValue valueWithRect: origSelectedTagRect];
        [tagRects replaceObjectAtIndex: [selectedTagIndex integerValue] withObject: tagRectObj];
        [self setNeedsDisplay];
    }*/
    // Send to controller to handle
    [NSApp sendAction:[self mouseUpAction] to:[self target] from:self];
}

@end