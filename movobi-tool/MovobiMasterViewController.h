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
@property (weak) IBOutlet NSTableView *filmsTableView;
@property (weak) IBOutlet NSTableView *screensTableView;
@property (weak) IBOutlet NSTableView *tagsTableView;
@property (weak) IBOutlet MovobiScreenImageView *screenImageView;
@property (weak) IBOutlet NSTableView *mobjectsTableView;
@property (weak) IBOutlet NSTableView *allMObjectsTableView;

@property (strong) IBOutlet NSArrayController *filmArrayController;
@property (strong) IBOutlet NSArrayController *screensArrayController;
@property (strong) IBOutlet NSArrayController *tagsArrayController;
@property (strong) IBOutlet NSArrayController *mobjectsArrayController;
@property (strong) IBOutlet NSArrayController *allMObjectsArrayController;
@property (strong) IBOutlet NSArrayController *moactorCharacterArrayController;
@property (strong) IBOutlet NSArrayController *filmMOCharacterArrayController;

@property (strong) IBOutlet NSPanel *allMObjectsPanel;
@property (weak) IBOutlet NSBox *mobjectBox;
@property (strong) IBOutlet NSPanel *moactorPanel;
@property (strong) IBOutlet NSPanel *mocharacterPanel;
@property (strong) IBOutlet NSPanel *mopropPanel;
@property (strong) IBOutlet NSPanel *molocationPanel;
@property (strong) IBOutlet NSPanel *filmMOCharactersPanel;

@property (weak) IBOutlet NSButton *addMObjectToTagButton;

@end
