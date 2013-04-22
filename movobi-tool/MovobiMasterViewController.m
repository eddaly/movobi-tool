//
//  MovobiMasterViewController.m
//  movobi-tool
//
//  Created by Ed Daly on 11/04/2013.
//  Copyright (c) 2013 Movobi Ltd. All rights reserved.
//

#import "MovobiMasterViewController.h"
#import "Film.h"
#import "Screen.h"
#import "Tag.h"
#import "MOProp.h"


@interface MovobiMasterViewController ()

@end

@implementation MovobiMasterViewController

@synthesize managedObjectContext;
@synthesize tags;
@synthesize saveFilmImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        saveFilmImage = FALSE; // Only set this flag if saving to CoreData (self Transformer so save image representation)
    }
    
    return self;
}

// Log db (being called twice when set-up by app delegate)
- (void)logdb
{
    /*NSManagedObjectContext *context = [self managedObjectContext];
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
    }*/
}

- (void)loadView
{
    [super loadView];
    
    //[self logdb];
    
    [self.filmsTableView setDelegate: self];
    [self.filmsTableView setDataSource: self];
    [self.screensTableView setDelegate: self];
    [self.screensTableView setDataSource: self];
    [self.tagsTableView setDelegate: self];
    [self.screensTableView setTarget:self];
    [self.screensTableView setDoubleAction: @selector(doubleClickSelectImage:)];
    [self.screenImageView setTarget: self];
    [self.screenImageView setAction: @selector(mouseUp:)];
    [self.filmsTableView setTarget:self];
    [self.filmsTableView setDoubleAction: @selector(doubleClickSelectImage:)];

    
    // Sort array controllers (and therefore tables)
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [self.filmArrayController setSortDescriptors: [NSArray arrayWithObject:nameDescriptor]];
    [self.filmArrayController rearrangeObjects];
    NSSortDescriptor *nameDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"mobject.name" ascending:YES];
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
    
    NSArray *tagsArray = [self.tagsArrayController arrangedObjects]; // Note, can't use self.tags as order changes on add/remove
    for (Tag *tag in tagsArray)
    {
        if ([self screenImageView].image != nil)
        {
            // Scaled image
            CGRect r = [self frameForImage: [self screenImageView].image inImageViewAspectFit: [self screenImageView]];
            CGRect tagRect = CGRectMake (
                r.origin.x + [tag.rectTopLeftX floatValue] * r.size.width,
                r.origin.y + [tag.rectTopLeftY floatValue] * r.size.height,
                [tag.rectWidth floatValue] * r.size.width,
                [tag.rectHeight floatValue] * r.size.height);
            // Flip Y for NSView
            tagRect.origin.y = r.size.height - ((tagRect.origin.y - r.origin.y) + tagRect.size.height);
            tagRect.origin.y += r.origin.y;
        
            NSValue *tagRectObj = [NSValue valueWithRect:tagRect];
            [array addObject: tagRectObj];
        }
    }
    
    self.screenImageView.tagRects = array;//***is this memory not leaking?
}

- (Film*) getSelectedFilm
{
    // Note not using [self.filmArrayController selection] and KVO accessors as not changing contents
    NSUInteger selIndex = self.filmArrayController.selectionIndex;
    if (selIndex == NSNotFound)
        return nil;
    NSArray *filmsArray = [self.filmArrayController arrangedObjects];
    Film *film = [filmsArray objectAtIndex: selIndex];
    return film;
}

- (NSMutableArray*) getSelectedScreensSorted
{
    Film *film = [self getSelectedFilm];

    NSMutableArray *screens = nil;
    if (film.screens != nil)
    {
        // Note could optimise to avoid unneeded sorting
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timeStart" ascending:YES];
        NSArray *screensArray = [film.screens sortedArrayUsingDescriptors: [NSArray arrayWithObject:nameDescriptor]];
        screens = [NSMutableArray arrayWithArray: screensArray];
    }
    return screens;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    NSInteger count=0;
    if (tableView == self.screensTableView) {
        NSSet *screens = [self getSelectedFilm].screens;
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
        if ([self getSelectedFilm].screens != nil) {
            NSString *columnIdentifer = [aTableColumn identifier];
    
            // Get the name at the specified row in the namesArray
            NSArray *screens = [self getSelectedScreensSorted];
            Screen *screen = [screens objectAtIndex:rowIndex];
    
            if ([columnIdentifer isEqualToString:@"timeStart"]) {
                returnValue = screen.timeStart;
            }
            else if ([columnIdentifer isEqualToString:@"timeEnd"]) {
                returnValue = screen.timeEnd;
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
        
        if ([self getSelectedFilm].screens != nil) {
            NSString *columnIdentifer = [aTableColumn identifier];
    
            if ([columnIdentifer isEqualToString:@"timeStart"] || [columnIdentifer isEqualToString:@"timeEnd"])
            {
                NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                [f setNumberStyle:NSNumberFormatterDecimalStyle];
                NSNumber * time = [f numberFromString: anObject];
                
                // Update the time
                NSInteger row = [self.screensTableView selectedRow];
                NSArray *screens = [self getSelectedScreensSorted];
                Screen *screen = [screens objectAtIndex: row];
                if ([columnIdentifer isEqualToString:@"timeStart"])
                    screen.timeStart = time;
                else
                    screen.timeEnd = time;
            }
            else if ([columnIdentifer isEqualToString:@"image"]) {
            }
        }
    }
    else if (aTableView == self.filmsTableView) {
        // Renamed a film
        [self.filmArrayController rearrangeObjects];   // Sort the ArrayController
    }
}

-(void)setScreenImageView
{
    Screen *screen = nil;
    if ([self.screensTableView selectedRow] == -1) // Needed if not selected a screen yet
    {
        if ([[self getSelectedScreensSorted] count] > 0) { // Then select the first (if there is one)
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex: 0];
            [self.screensTableView selectRowIndexes:indexSet byExtendingSelection: FALSE];
            screen = [[self getSelectedScreensSorted] objectAtIndex: 0]; // Not needed as above will result in this called again with a selection
        }
    }
    else { // Select the selected screen
        screen = [[self getSelectedScreensSorted] objectAtIndex: [self.screensTableView selectedRow]];
    }
    if (screen != nil) {
        self.screenImageView.image = screen.image;

        // And set-up the tags (note, this calls tableViewSelectionDidChange which calls setSelectedTagIndex)
        self.tags = [screen mutableSetValueForKey:@"tags"]; //note was getting away with self.tags = screen.tags and not being KVO everywhere
    }
    else {
        self.screenImageView.image = nil;
        self.tags = nil;
    }
    
    // Set up
    [self setupTagRects];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    NSTableView *aTableView = [aNotification object];
    NSInteger row = [aTableView selectedRow];
    if (row == -1)
        return;
    if (aTableView == self.filmsTableView)
    {
        [self.screensTableView reloadData];
    }
    // If change movie or screen, need to update screen image
    if (aTableView == self.filmsTableView || aTableView == self.screensTableView)
    {
        [self setScreenImageView];
    }
    if (aTableView == self.tagsTableView)
    {
        [self.screenImageView setSelectedTagIndex: [NSNumber numberWithInteger: self.tagsArrayController.selectionIndex]];
        [self.screenImageView setNeedsDisplay];
    }
}

- (void)doubleClickSelectImage:(id)object { // Catch click on image cell to pop up box to set it
    
    NSTableView *tableView = object;
    NSInteger rowIndex = [tableView clickedRow];
    NSInteger colIndex = [tableView clickedColumn];
    if (rowIndex != -1 && colIndex != -1) // If clicked on screen table properly
    {
        NSArray *columns = [tableView tableColumns];
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
                        if (object == self.screensTableView)
                        {
                            Screen *screen = [[self getSelectedScreensSorted] objectAtIndex: rowIndex];
                            screen.image = image;
                            [self setScreenImageView]; // And need to reset imageview new screen
                        }
                        else if (object == self.filmsTableView)
                        {
                            [self getSelectedFilm].image = image;
                        }
                    }
                }
                return;
            }
            else if (col.isEditable)
            {   // According to 'people' shouldn't be neccessary as this only called on columns that
                // are not 'editable', but it's call on them all so can't use that as a mask
                // Programmatically trigger edit
                [tableView editColumn:colIndex row:rowIndex withEvent:nil select:TRUE];
            }
        }
    }
}

- (IBAction)addScreen:(id)sender {
    
    if ([self.filmsTableView selectedRow] == -1)
        return;
    
    Screen *screen = [NSEntityDescription
                      insertNewObjectForEntityForName:@"Screen"
                      inManagedObjectContext:managedObjectContext];
    
    // Connect up to movie
    screen.film = [self getSelectedFilm];
    [[self getSelectedFilm] addScreensObject: screen];
    
    // Reload to add to tableview, needed to reset row count
    [self.screensTableView reloadData];
    [self setScreenImageView]; // And need to reset imageview of new, blank, screen
}

- (IBAction)removeScreen:(id)sender {
    
    if ([self.filmsTableView selectedRow] == -1 || [self.screensTableView selectedRow] == -1)
        return;
    
    // Remove from screens array and underlying object (otherwise doesn't 'save')
    Screen *screen = [[self getSelectedScreensSorted] objectAtIndex: [self.screensTableView selectedRow]];
    [[self getSelectedFilm] removeScreensObject: screen];
    [self.managedObjectContext deleteObject: screen];

    // Reload to remove from tableview, note needed to reset row count or will try to fill row out of bound of array
    [self.screensTableView reloadData];
    [self setScreenImageView]; // And need to reset imageview of removed screen
}

- (IBAction)removeFilm:(id)sender {
    
    if ([self.filmsTableView selectedRow] == -1)
        return;
    
    Film *film = [self getSelectedFilm];
    
    // Remove from the arraycontroller (that uses binding to sync with managedobjectcontext)
    // Note, My test showed coredata deals with 'orphan' screens
    [self.filmArrayController removeObject: film];
    
    // Needed or if no screens on new selection leaves removed movies screens
    [self.screensTableView reloadData];
    
    [self setScreenImageView]; // And need to reset imageview of removed movie's screen
}

// Here as this is when screen detailed view needs update
- (IBAction)addTag:(id)sender {
    
    if ([self.screensTableView selectedRow] == -1)
        return;
    
    Tag *tag = [NSEntityDescription
                insertNewObjectForEntityForName:@"Tag"
                inManagedObjectContext:managedObjectContext];
    
    // Connect up to movie (should be screen)
    Screen *screen = [[self getSelectedScreensSorted] objectAtIndex: [self.screensTableView selectedRow]];
    tag.screen = screen;
    tag.rectTopLeftX = [NSNumber numberWithFloat: 0.4f];
    tag.rectTopLeftY = [NSNumber numberWithFloat: 0.4f];
    tag.rectWidth = [NSNumber numberWithFloat: 0.2f];
    tag.rectHeight = [NSNumber numberWithFloat: 0.2f];
    
    //***need to choose type etc.
    MOProp *prop = [NSEntityDescription
                insertNewObjectForEntityForName:@"MOProp"
                inManagedObjectContext:managedObjectContext];
    //prop.name = [NSString stringWithString:""];
    [prop addFilmsObject: [self getSelectedFilm]];
    [prop addTagsObject: tag];
    
    // Add to the controller which will update the tags array via bindings and select (as select inserted objects is on)
    [self.tagsArrayController addObject: tag];
    [self setupTagRects];
}

- (IBAction)removeTag:(id)sender {
    
    if (self.tagsArrayController.selectionIndex == NSNotFound)
        return;
    
    // Get tag out of ArrayController
    NSArray *tagsArray = [self.tagsArrayController arrangedObjects];
    Tag *tag = [tagsArray objectAtIndex: self.tagsArrayController.selectionIndex];  //***should I be using [self.tagsArrayController selection]?
    
    // Remove from the arraycontroller (that uses binding to sync with self.tags array) and CoreData context (not automatic)
    [self.tagsArrayController removeObject: tag]; //*** this (sometimes!?) calls tableViewSelectionDidChange which calls setSelectedTagIndex
    [self.managedObjectContext deleteObject: tag];
    
    // Set up and selects default tag (can't unselect as selectiondidchange not called if reselect tag 0)
    // Note can't just call setScreenImageView as will reset the tags list from the movie (not sure why this isn't updated anyway)
    [self setupTagRects];
    if ([self.tags count] == 0)
        [self.screenImageView setSelectedTagIndex: [NSNumber numberWithInt: -1]];
    [self.screenImageView setNeedsDisplay];
}

// Sent from the ScreenImageView to tell controller selected tag rect has changed
- (void)mouseUp:(NSEvent *)theEvent
{
    if (self.tagsArrayController.selectionIndex == NSNotFound)
        return;
    
    // Get tag out of ArrayController
    NSArray *tagsArray = [self.tagsArrayController arrangedObjects];
    Tag *tag = [tagsArray objectAtIndex: self.tagsArrayController.selectionIndex];
    
    // Get the rect out of the view
    NSInteger index = [self.screenImageView.selectedTagIndex integerValue];
    CGRect tagRect = [[self.screenImageView.tagRects objectAtIndex: index] rectValue];
    
    // Update it in scale independent co-ords used in Tag model
    CGRect r = [self frameForImage: [self screenImageView].image inImageViewAspectFit: [self screenImageView]];
    
    // Flip Y
    tagRect.origin.y -= r.origin.y;
    tagRect.origin.y = -(tagRect.origin.y - r.size.height) - tagRect.size.height;
    tagRect.origin.y += r.origin.y;

    tag.rectTopLeftX = [NSNumber numberWithFloat: (tagRect.origin.x - r.origin.x) / r.size.width];
    tag.rectTopLeftY = [NSNumber numberWithFloat: (tagRect.origin.y - r.origin.y) / r.size.height];
    tag.rectWidth = [NSNumber numberWithFloat: tagRect.size.width / r.size.width];
    tag.rectHeight = [NSNumber numberWithFloat: tagRect.size.height / r.size.height];
}

@end
