//
//  MovobiMasterViewController.m
//  movobi-tool
//
//  Created by Ed Daly on 11/04/2013.
//  Copyright (c) 2013 Movobi Ltd. All rights reserved.
//

#import "MovobiMasterViewController.h"
#import "Movie.h"
#import "Screen.h"
#import "Tag.h"

@interface MovobiMasterViewController ()

@end

@implementation MovobiMasterViewController

@synthesize managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {

    }
    
    return self;
}

- (void)loadView
{
    [super loadView];
        
        // Log db (being called twice when set-up by app delegate)
        /*{
            NSManagedObjectContext *context = [self managedObjectContext];
            NSError *error;
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"Movie" inManagedObjectContext:context];
            [fetchRequest setEntity:entity];
            NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
            for (Movie *movie in fetchedObjects) {
                NSLog(@"Name: %@", movie.name);
                NSArray *screens = [movie.screens allObjects];
                for (Screen *screen in screens) {
                    id image = screen.image;
                    NSLog(@"Time: %@ %@", screen.time, image);
                }
                NSArray *tags = [movie.tags allObjects];
                for (Tag *tag in tags) {
                    NSLog(@"Time: %@", tag.desc);
                }
            }
        }*/
    
    [self.moviesTableView setDelegate: self];
    [self.moviesTableView setDataSource: self];
    [self.screensTableView setDelegate: self];
    [self.screensTableView setDataSource: self];
    
    [self.screensTableView setTarget:self];
    [self.screensTableView setDoubleAction: @selector(doubleClick:)];
    
    // Sort array controller (and therefore table) in line with the movies array
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [self.movieArrayController setSortDescriptors: [NSArray arrayWithObject:nameDescriptor]];
    [self.movieArrayController rearrangeObjects];
}

- (Movie*) getSelectedMovie
{
    NSUInteger selIndex = self.movieArrayController.selectionIndex;
    if (selIndex == NSNotFound)
        return nil;
    NSArray *moviesArray = [self.movieArrayController arrangedObjects];
    Movie *movie = [moviesArray objectAtIndex: selIndex];
    return movie;
}

- (NSMutableArray*) getSelectedScreensSorted
{
    Movie *movie = [self getSelectedMovie];

    NSMutableArray *screens = nil;
    if (movie.screens != nil)
    {
        // Note could optimise to avoid unneeded sorting
        NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
        NSArray *screensArray = [movie.screens sortedArrayUsingDescriptors: [NSArray arrayWithObject:nameDescriptor]];
        screens = [NSMutableArray arrayWithArray: screensArray];
    }
    return screens;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    NSInteger count=0;
    if (tableView == self.screensTableView) {
        NSSet *screens = [self getSelectedMovie].screens;
        if (screens != nil) {
            count=[screens count];
        }
    }
    else {
        NSLog (@"ERROR - unexpected tableView");
    }
    return count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    id returnValue = nil;

    if (aTableView == self.screensTableView) {
        if ([self getSelectedMovie].screens != nil) {
            NSString *columnIdentifer = [aTableColumn identifier];
    
            // Get the name at the specified row in the namesArray
            NSArray *screens = [self getSelectedScreensSorted];
            Screen *screen = [screens objectAtIndex:rowIndex];
    
            if ([columnIdentifer isEqualToString:@"time"]) {
                returnValue = screen.time;
            }
            else if ([columnIdentifer isEqualToString:@"image"]) {
                returnValue = screen.image;
            }
        }
    }
    return returnValue;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    if (aTableView == self.screensTableView) {
        
        if ([self getSelectedMovie].screens != nil) {
            NSString *columnIdentifer = [aTableColumn identifier];
    
            if ([columnIdentifer isEqualToString:@"time"]) {
                NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                [f setNumberStyle:NSNumberFormatterDecimalStyle];
                NSNumber * time = [f numberFromString: anObject];
                time = [NSNumber numberWithInt: [time intValue]];
                
                // Update the time
                NSInteger row = [self.screensTableView selectedRow];
                NSArray *screens = [self getSelectedScreensSorted];
                Screen *screen = [screens objectAtIndex: row];
                screen.time = time;
            }
            else if ([columnIdentifer isEqualToString:@"image"]) {
            }
        }
    }
    else if (aTableView == self.moviesTableView) {
        // Renamed a movie
        [self.movieArrayController rearrangeObjects];   // Sort the ArrayController
    }
}

-(void)setScreenImageView
{
    NSImage* image = nil;
    if ([self.screensTableView selectedRow] != -1) // Needed if not selected a screen yet
    {
        // Force update of new selected screen (tried selecting it but doesn't call tableViewSelectionDidChange)
        if ([[self getSelectedScreensSorted] count] > [self.screensTableView selectedRow])
        {
            Screen *screen = [[self getSelectedScreensSorted] objectAtIndex: [self.screensTableView selectedRow]];
            image = screen.image;
        }
    }
    self.screenImageView.image = image;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    NSTableView *aTableView = [aNotification object];
    NSInteger row = [aTableView selectedRow];
    if (row == -1)
        return;
    if (aTableView == self.moviesTableView)
    {
        [self.screensTableView reloadData];
    }
    // If change movie or screen, need to update screen image
    if (aTableView == self.moviesTableView || aTableView == self.screensTableView)
    {
        [self setScreenImageView];
    }
}

- (void)doubleClick:(id)object { // Catch click on image cell to pop up box to set it
    
    NSInteger rowIndex = [self.screensTableView clickedRow];
    NSInteger colIndex = [self.screensTableView clickedColumn];
    if (rowIndex != -1 && colIndex != -1) // If clicked on screen table properly
    {
        NSArray *columns = [self.screensTableView tableColumns];
        int i = 0;
        for (NSTableColumn *col in columns)
        {
            // If this is the column clicked on (works but not sure reliable assume array in order of 'clickedColumn' indicies) and this is the "image" column
            if (i++ == colIndex && [col.identifier isEqual: @"image"])
            {
                NSOpenPanel* openDlg = [NSOpenPanel openPanel];
                [openDlg setCanChooseFiles:YES];
                [openDlg setAllowsMultipleSelection:NO];
                [openDlg setCanChooseDirectories:NO];
                NSURL* imageName;
                if ([openDlg runModal] == NSOKButton) // Get a new file (not set supported file types yet)
                {
                    NSArray* urls = [openDlg URLs];
                    imageName = [urls objectAtIndex: 0];
                    NSImage *image = [[NSImage alloc] initWithContentsOfURL: imageName];
                    if (image != nil) // If this is an image, update the screen
                    {
                        Screen *screen = [[self getSelectedScreensSorted] objectAtIndex: rowIndex];
                        screen.image = image;
                        [self setScreenImageView]; // And need to reset imageview new screen
                    }
                }
                return;
            }
            else if (col.isEditable)
            {   // According to 'people' shouldn't be neccessary as this only called on columns that
                // are not 'editable', but it's call on them all so can't use that as a mask
                // Programmatically trigger edit
                [self.screensTableView editColumn:colIndex row:rowIndex withEvent:nil select:TRUE];
            }
        }
    }
}

- (IBAction)addScreen:(id)sender {
    
    if ([self.moviesTableView selectedRow] == -1)
        return;
    
    Screen *screen = [NSEntityDescription
                       insertNewObjectForEntityForName:@"Screen"
                       inManagedObjectContext:managedObjectContext];
    
    // Connect up to movie
    screen.movie = [self getSelectedMovie];
    [[self getSelectedMovie].screens addObject: screen];
    
    // Reload to add to tableview, needed to reset row count
    [self.screensTableView reloadData];
    [self setScreenImageView]; // And need to reset imageview of new, blank, screen
}

- (IBAction)removeScreen:(id)sender {
    
    if ([self.moviesTableView selectedRow] == -1 || [self.screensTableView selectedRow] == -1)
        return;
    
    Screen *screen = [[self getSelectedScreensSorted] objectAtIndex: [self.screensTableView selectedRow]];
    [[self getSelectedMovie].screens removeObject: screen];
    
    // Reload to remove from tableview, note needed to reset row count or will try to fill row out of bound of array
    [self.screensTableView reloadData];
    [self setScreenImageView]; // And need to reset imageview of removed screen
}

- (IBAction)addMovie:(id)sender {
    Movie *movie = [NSEntityDescription
                      insertNewObjectForEntityForName:@"Movie"
                      inManagedObjectContext:managedObjectContext];
    
    // Add to the arraycontroller (that uses binding to synch with managedobjectcontext)
    [self.movieArrayController addObject: movie];
}

- (IBAction)removeMovie:(id)sender {
    
    if ([self.moviesTableView selectedRow] == -1)
        return;
    
    Movie *movie = [self getSelectedMovie];
    
    // Remove to the arraycontroller (that uses binding to sync with managedobjectcontext)
    // Note, My test showed coredata deals with 'orphan' screens
    [self.movieArrayController removeObject: movie];
    
    // Needed or if no screens on new selection leaves removed movies screens
    [self.screensTableView reloadData];
    
    [self setScreenImageView]; // And need to reset imageview of removed movie's screen
}

@end
