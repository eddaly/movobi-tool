//
//  Tag.m
//  movobi
//
//  Created by Ed Daly on 30/03/2013.
//  Copyright (c) 2013 Movobi Ltd. All rights reserved.
//

#import "Tag.h"
#import "Movie.h"
#import "MovobiAppDelegate.h"


@implementation Tag

@dynamic desc;
@dynamic rectHeight;
@dynamic rectTopLeftX;
@dynamic rectTopLeftY;
@dynamic rectWidth;
@dynamic timeEnd;
@dynamic timeStart;
@dynamic movie;

- (id)init //***No longer need as aborted below and adding programatically, could delete (darn flash it was though!)
{   // Using Cocoa bindings to create Tags automatically, but because Tag needs to use initWithEntity
    // Had to overwrite init
    MovobiAppDelegate *appDelegate = [[NSApplication sharedApplication]delegate];
    NSEntityDescription *entityDesc =  [NSEntityDescription entityForName: @"Tag" inManagedObjectContext: appDelegate.managedObjectContext];
    return [self initWithEntity:entityDesc insertIntoManagedObjectContext:appDelegate.managedObjectContext];
}

@end
