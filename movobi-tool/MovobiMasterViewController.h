//
//  MovobiMasterViewController.h
//  movobi-tool
//
//  Created by Ed Daly on 11/04/2013.
//  Copyright (c) 2013 Movobi Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MovobiScreenImageView.h"
#import "Film.h"

@interface MovobiMasterViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) Film *_film;
@property (strong, nonatomic) NSSet *screens;
@property (strong, nonatomic) NSSet *tags;
@property (weak) IBOutlet NSTableView *filmsTableView;
@property (weak) IBOutlet NSTableView *screensTableView;
@property (weak) IBOutlet MovobiScreenImageView *screenImageView;
@property (strong) IBOutlet NSArrayController *tagsArrayController;
@property (weak) IBOutlet NSTableView *tagsTableView;
@property (strong) IBOutlet NSArrayController *filmArrayController;
@property (weak) IBOutlet NSTableView *mobjectsTableView;
@property (strong) IBOutlet NSArrayController *mobjectsArrayController;
@property (strong) IBOutlet NSPanel *allMObjectsPanel;
@property (weak) IBOutlet NSTableView *allMObjectsTableView;
@property (strong) IBOutlet NSArrayController *allMObjectsArrayController;
@property (strong) IBOutlet NSPanel *moactorPanel;
@property (strong) IBOutlet NSPanel *mocharacterPanel;
@property (strong) IBOutlet NSPanel *mopropPanel;
@property (strong) IBOutlet NSPanel *molocationPanel;
@property (weak) IBOutlet NSBox *mobjectBox;

@end
