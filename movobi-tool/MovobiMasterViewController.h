//
//  MovobiMasterViewController.h
//  movobi-tool
//
//  Created by Ed Daly on 11/04/2013.
//  Copyright (c) 2013 Movobi Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MovobiScreenImageView.h"

@interface MovobiMasterViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSMutableSet *tags;
@property (weak) IBOutlet NSTableView *moviesTableView;
@property (weak) IBOutlet NSTableView *screensTableView;
@property (strong) IBOutlet NSArrayController *movieArrayController;
@property (weak) IBOutlet MovobiScreenImageView *screenImageView;
@property (strong) IBOutlet NSArrayController *tagsArrayController;
@property (weak) IBOutlet NSTableView *tagsTableView;

@end
