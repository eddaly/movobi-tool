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
@synthesize tags;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {

    }
    
    return self;
}

// Log db (being called twice when set-up by app delegate)
- (void)logdb
{
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
        NSArray *alltags = [movie.tags allObjects];
        for (Tag *tag in alltags) {
            NSLog(@"Time: %@", tag.desc);
        }
    }
}

- (void)loadView
{
    [super loadView];
    
    //[self logdb];
    
    [self.moviesTableView setDelegate: self];
    [self.moviesTableView setDataSource: self];
    [self.screensTableView setDelegate: self];
    [self.screensTableView setDataSource: self];
    [self.tagsTableView setDelegate: self];
    
    [self.screensTableView setTarget:self];
    [self.screensTableView setDoubleAction: @selector(doubleClick:)];
    
    // Sort array controllers (and therefore table) in line with the movies array
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [self.movieArrayController setSortDescriptors: [NSArray arrayWithObject:nameDescriptor]];
    [self.movieArrayController rearrangeObjects];
    
    // And the tags
    NSSortDescriptor *nameDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"timeStart" ascending:YES];
    [self.tagsArrayController setSortDescriptors: [NSArray arrayWithObject:nameDescriptor2]];
    [self.tagsArrayController rearrangeObjects];
}

// Assumes imageScaling NSScaleProportionally
- (CGRect)frameForImage:(NSImage*)image inImageViewAspectFit:(NSImageView*)imageView
{
    float imageRatio = image.size.width / image.size.height;
    float viewRatio = imageView.frame.size.width / imageView.frame.size.height;
    
    if (imageRatio < viewRatio)
    {
        float scale = imageView.frame.size.height / image.size.height;
        float width = scale * image.size.width;
        float topLeftX = (imageView.frame.size.width - width) * 0.5;
        
        return CGRectMake (topLeftX, 0, width, imageView.frame.size.height);
    }
    else
    {
        float scale = imageView.frame.size.width / image.size.width;
        float height = scale * image.size.height;
        float topLeftY = (imageView.frame.size.height - height) * 0.5;
        
        return CGRectMake (0, topLeftY, imageView.frame.size.width, height);
    }
}

// Set-up the tagRect array used by the screen ImageView
- (void)setupTagRects
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity: [tags count]];
    for (Tag *tag in tags) //***are they in order in table?
    {
        if ([self screenImageView].image != nil)
        {
            // Scaled image
            CGRect r = [self frameForImage: [self screenImageView].image inImageViewAspectFit: [self screenImageView]];
        
            //*** Scaled tag (Y may be flipped from iOS coords)
            CGRect tagRect = CGRectMake (
                r.origin.x + [tag.rectTopLeftX floatValue] * r.size.width,
                r.origin.y + [tag.rectTopLeftY floatValue] * r.size.height,
                [tag.rectWidth floatValue] * r.size.width,
                [tag.rectHeight floatValue] * r.size.height);
        
            NSValue *tagRectObj = [NSValue valueWithRect:tagRect];
            [array addObject: tagRectObj];
        }
    }
    
    self.screenImageView.tagRects = array;//***is this memory not leaking?
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
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES];
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
    
    // Here as this is when screen detailed view needs update
    self.tags = [self getSelectedMovie].tags;//***note all in the movie in this dumb model
    
    // Set up and selects default tag (can't unselect as selectiondidchange not called if reselect tag 0)
    [self setupTagRects];
    [self.screenImageView setSelectedTagIndex: [NSNumber numberWithInt: 0]];
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
    if (aTableView == self.tagsTableView)//***not being called for Tag table?
    {
        [self.screenImageView setSelectedTagIndex: [NSNumber numberWithInteger: self.tagsArrayController.selectionIndex]];
        [self.screenImageView setNeedsDisplay];//needed?
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
    
    // Remove from screens array and underlying object (otherwise doesn't 'save')
    Screen *screen = [[self getSelectedScreensSorted] objectAtIndex: [self.screensTableView selectedRow]];
    [[self getSelectedMovie].screens removeObject: screen];
    [self.managedObjectContext deleteObject: screen];

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
    
    // Remove from the arraycontroller (that uses binding to sync with managedobjectcontext)
    // Note, My test showed coredata deals with 'orphan' screens
    [self.movieArrayController removeObject: movie];
    
    // Needed or if no screens on new selection leaves removed movies screens
    [self.screensTableView reloadData];
    
    [self setScreenImageView]; // And need to reset imageview of removed movie's screen
}

// Here as this is when screen detailed view needs update
- (IBAction)addTag:(id)sender {
    
    if ([self.screensTableView selectedRow] == -1) //***Not needed at moment but when linked to screens will need 1 selected
        return;
    
    Tag *tag = [NSEntityDescription
                      insertNewObjectForEntityForName:@"Tag"
                      inManagedObjectContext:managedObjectContext];
    
    // Connect up to movie (should be screen)
    Movie* movie = [self getSelectedMovie];
    tag.movie = movie;
    
    // Add to the controller not [movie.tags addObject: tag] because...
    [self.tagsArrayController addObject: tag];
}

- (IBAction)removeTag:(id)sender {
    
    if (self.tagsArrayController.selectionIndex == NSNotFound)
        return;
    
    // Get tag out of ArrayController
    NSArray *tagsArray = [self.tagsArrayController arrangedObjects];
    Tag *tag = [tagsArray objectAtIndex: self.tagsArrayController.selectionIndex];
    
    // Remove from the arraycontroller (that uses binding to sync with managedobjectcontext)
    // Note, check removes from tags list in movie/screen as well as db
    [self.tagsArrayController removeObject: tag];
    [self.managedObjectContext deleteObject: tag];
}

@end
