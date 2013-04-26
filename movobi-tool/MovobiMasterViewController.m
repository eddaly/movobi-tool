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
#import "MOActor.h"
#import "MOCharacter.h"
#import "MOLocation.h"
#import "MOProp.h"


@interface MovobiMasterViewController ()

@end

@implementation MovobiMasterViewController

@synthesize managedObjectContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {}
    
    return self;
}

- (void)loadView
{
    [super loadView];
    
    // Delegates to handle changing selection
    [self.tagsTableView setDelegate: self];
    [self.mobjectsTableView setDelegate: self];
    
    // Set-up actions for image selection and synching tags with view
    [self.filmsTableView setTarget:self];
    [self.filmsTableView setDoubleAction: @selector(doubleClickSelectImage:)];
    [self.screensTableView setTarget:self];
    [self.screensTableView setDoubleAction: @selector(doubleClickSelectImage:)];
    [self.mobjectsTableView setTarget:self];
    [self.mobjectsTableView setDoubleAction: @selector(doubleClickSelectImage:)];
    [self.allMObjectsTableView setTarget:self];
    [self.allMObjectsTableView setDoubleAction: @selector(doubleClickSelectImage:)];
    [self.screenImageView setTarget: self];
    [self.screenImageView setMouseUpAction: @selector(mouseUp:)];
    [self.screenImageView setDrawRectAction: @selector(drawRect:)];
    
    // Sort array controllers (and therefore tables)
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [self.filmArrayController setSortDescriptors: [NSArray arrayWithObject:nameDescriptor]];
    NSSortDescriptor *timeStartDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timeStart" ascending:YES];
    [self.screensArrayController setSortDescriptors: [NSArray arrayWithObject:timeStartDescriptor]];
    [self.mobjectsArrayController setSortDescriptors: [NSArray arrayWithObject:nameDescriptor]];
    NSSortDescriptor *descDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"desc" ascending:YES];
    [self.tagsArrayController setSortDescriptors: [NSArray arrayWithObject:descDescriptor]];
    //***what about the other arraycontrollers?
}

- (Film*) selectedFilm
{
    return [self.filmArrayController valueForKeyPath:@"selection.self"];
}

- (void)updateAddMObjectToTagButton
{
    // If have an MObject to add and a Tag to add to
    if (self.mobjectsArrayController.selectionIndex != NSNotFound && self.tagsArrayController.selectionIndex != NSNotFound)
        [self.addMObjectToTagButton setEnabled:YES];
    else
        [self.addMObjectToTagButton setEnabled:NO];
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    [self updateAddMObjectToTagButton]; // Check whether can enable this button now
    
    NSTableView *aTableView = [aNotification object];
    NSInteger row = [aTableView selectedRow];
    if (row == -1)
        return;
    
    // If change tag selection update the screen view
    if (aTableView == self.tagsTableView)
    {
        [self.screenImageView setSelectedTagIndex: [NSNumber numberWithInteger: self.tagsArrayController.selectionIndex]];
        [self.screenImageView setNeedsDisplay];
        
    }
    // If it's the MObject's table then update then switch in the 'detail view'
    else if (aTableView == self.mobjectsTableView)
    {
        MObject *mobject = [self.mobjectsArrayController valueForKeyPath:@"selection.self"];
        
        [self.moactorPanel orderOut: (aTableView)];
        [self.mocharacterPanel orderOut: (aTableView)];
        [self.mopropPanel orderOut: (aTableView)];
        [self.molocationPanel orderOut:(aTableView)];
        NSPoint point = [self.view.window convertRectToScreen:[self.mobjectBox frame]].origin;
        
        if ([mobject isMemberOfClass:[MOActor class]]) {
            [self.view.window addChildWindow: self.moactorPanel ordered:NSWindowAbove];
            [self.moactorPanel setFrameOrigin: point];
        }
        else if ([mobject isMemberOfClass:[MOCharacter class]]) {
            [self.view.window addChildWindow: self.mocharacterPanel ordered:NSWindowAbove];
            [self.mocharacterPanel setFrameOrigin: point];
        }
        else if ([mobject isMemberOfClass:[MOProp class]]) {
            [self.view.window addChildWindow: self.mopropPanel ordered:NSWindowAbove];
            [self.mopropPanel setFrameOrigin: point];
        }
        else if ([mobject isMemberOfClass:[MOLocation class]]) {
            [self.view.window addChildWindow: self.molocationPanel ordered:NSWindowAbove];
            [self.molocationPanel setFrameOrigin: point];
        }
    }
}

// Catch click on image cell to pop up box to set it
- (void)doubleClickSelectImage:(id)object
{
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
            if (i++ == colIndex) {
                if ([col.identifier isEqual: @"image"])
                {
                    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
                    [openDlg setCanChooseFiles:YES];
                    [openDlg setAllowsMultipleSelection:NO];
                    [openDlg setCanChooseDirectories:NO];
                    if ([openDlg runModal] == NSOKButton) // Get a new file (not set supported file types yet)
                    {
                        NSURL* imageName = [[openDlg URLs] objectAtIndex: 0];
                        NSImage *image = [[NSImage alloc] initWithContentsOfURL: imageName];
                        if (image != nil) // If this is an image, update the screen
                        {
                            if (tableView == self.screensTableView)
                            {
                                Screen *screen = [self.screensArrayController valueForKeyPath:@"selection.self"];
                                screen.image = image;
                            }
                            else if (tableView == self.filmsTableView)
                            {
                                [self selectedFilm].image = image;
                            }
                            else if (tableView == self.mobjectsTableView)
                            {
                                MObject *mobject = [self.mobjectsArrayController valueForKeyPath:@"selection.self"];
                                mobject.image = image;
                            }
                            else if (tableView == self.allMObjectsTableView)
                            {
                                MObject *mobject = [self.allMObjectsArrayController valueForKeyPath:@"selection.self"];
                                mobject.image = image;
                         
                            }
                        }
                    }
                }
                else if (col.isEditable && ![col.identifier isEqual: @"type"]) //*** isEditable despite flagged not to be
                {   // According to 'people' shouldn't be neccessary as this only called on columns that
                    // are not 'editable', but it's call on them all so can't use that as a mask
                    // Programmatically trigger edit
                    [tableView editColumn:colIndex row:rowIndex withEvent:nil select:TRUE];
                }
                return;
            }
        }
    }
}

- (IBAction)addMOCharacterToMOActorButton:(id)sender
{
    // Populate array controller used by modal window table with characters only
    NSArray *mobjectsArray = [self.mobjectsArrayController arrangedObjects];
    [self.filmMOCharacterArrayController removeObjects: [self.filmMOCharacterArrayController arrangedObjects]];
    for (MObject *mobject in mobjectsArray)
    {
        if ([mobject isMemberOfClass:[MOCharacter class]])
        {
            MOCharacter *mocharacter = (MOCharacter*)mobject;
            [self.filmMOCharacterArrayController addObject:mocharacter];
        }
    }
    [[NSApplication sharedApplication] runModalForWindow:self.filmMOCharactersPanel];
}

- (IBAction)filmMOCharactersPanelCancel:(id)sender {
    [[NSApplication sharedApplication] stopModal];
    [self.filmMOCharactersPanel close];
}

- (IBAction)removeFilm:(id)sender {
    
    if ([self.filmsTableView selectedRow] == -1)
        return;
    
    // Remove from the arraycontroller (that uses binding to sync with managedobjectcontext)
    [self.filmArrayController removeObject: [self selectedFilm]];
}


- (IBAction)addScreen:(id)sender {
    
    if ([self.filmsTableView selectedRow] == -1)
        return;
    
    Screen *screen = [NSEntityDescription
                      insertNewObjectForEntityForName:@"Screen"
                      inManagedObjectContext:managedObjectContext];
    
    // Connect up to film (note, only need set-up one way core data does inverse)
    screen.film = [self selectedFilm];
}

- (IBAction)removeScreen:(id)sender {
    
    if ([self.filmsTableView selectedRow] == -1 || [self.screensTableView selectedRow] == -1)
        return;
    
    // Remove from CoreData (automatically removes from controller arrays and from owning film)
    Screen *screen = [self.screensArrayController valueForKeyPath:@"selection.self"];
    [self.managedObjectContext deleteObject: screen];// Also need as IB's 'delete object on remove not working'
}

// Here as this is when screen detailed view needs update
- (IBAction)addTag:(id)sender {
    
    if ([self.screensTableView selectedRow] == -1)
        return;
    
    Tag *tag = [NSEntityDescription
                insertNewObjectForEntityForName:@"Tag"
                inManagedObjectContext:managedObjectContext];
    
    // Connect up to screen
    Screen *screen = [self.screensArrayController valueForKeyPath:@"selection.self"];
    tag.screen = screen;
    tag.rectTopLeftX = [NSNumber numberWithFloat: 0.4f];
    tag.rectTopLeftY = [NSNumber numberWithFloat: 0.4f];
    tag.rectWidth = [NSNumber numberWithFloat: 0.2f];
    tag.rectHeight = [NSNumber numberWithFloat: 0.2f];
    
    // Add to the controller which will update the tags array via bindings and select (as select inserted objects is on)
    [self.tagsArrayController addObject: tag];
}

- (IBAction)removeTag:(id)sender {
    if (self.tagsArrayController.selectionIndex == NSNotFound)
        return;
    
    // Get tag out of ArrayController
    Tag *tag = [self.tagsArrayController valueForKeyPath:@"selection.self"];
    
    // Remove from CoreData (automatically removes from controller arrays and from owning screen)
    // Note, will also trigger tableViewSelectionDidChange if needed which calls setSelectedTagIndex
    [self.managedObjectContext deleteObject: tag];  // Also need as IB's 'delete object on remove not working'

    [self.screenImageView setNeedsDisplay];
}

- (IBAction)addMObject:(id)sender {
    NSMenuItem* menuItem = sender;
    
    MObject *mobject = [NSEntityDescription
                        insertNewObjectForEntityForName:menuItem.title // Note setting type from menu title string
                        inManagedObjectContext:managedObjectContext];
    
    [self.allMObjectsArrayController addObject: mobject];
}

- (IBAction)addMObjectToFilm:(id)sender
{    
    if ([self.filmsTableView selectedRow] == -1)
        return;
    NSMenuItem* menuItem = sender;
    
    MObject *mobject = [NSEntityDescription
                insertNewObjectForEntityForName:menuItem.title // Note setting type from menu title string
                inManagedObjectContext:managedObjectContext];
    
    [mobject addFilmsObject: [self selectedFilm]];// Seems no need to add to ArrayController, they synch themselves just fine
}

- (IBAction)addExistingMObjectToFilm:(id)sender
{
    if ([self.allMObjectsTableView selectedRow] == -1 || [self.filmsTableView selectedRow] == -1)
        return;
    MObject *mobject = [self.allMObjectsArrayController valueForKeyPath:@"selection.self"];
    [mobject addFilmsObject: [self selectedFilm]];// Seems no need to add to ArrayController, they synch themselves just fine
}

- (IBAction)addMOCharacterToMOActor:(id)sender {
    
    if ([self.filmMOCharacterArrayController selection] == NSNoSelectionMarker)
        return;
    MOCharacter *mocharacter = [self.filmMOCharacterArrayController valueForKeyPath:@"selection.self"];
    MOActor *moactor = [self.mobjectsArrayController valueForKeyPath:@"selection.self"];
    
    [moactor addCharactersObject:mocharacter];
}
- (IBAction)addMObjectToTag:(id)sender {

    // Note relying on button enabling to ensure MObject types are correct
    MObject *mobject = [self.mobjectsArrayController valueForKeyPath:@"selection.self"];
    Tag *tag = [self.tagsArrayController valueForKeyPath:@"selection.self"];
    
    [tag addMobjectsObject:mobject];
}

// Note, assumes imageScaling NSScaleProportionally
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

// Sent from the ScreenImageView to tell controller prepare the tags array for drawing
- (void)drawRect:(NSEvent *)theEvent
{
    NSArray *tagsArray = [self.tagsArrayController arrangedObjects];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity: [tagsArray count]];
    for (Tag *tag in tagsArray)
    {
        if ([self screenImageView].image != nil)
        {
            // Scaled image
            CGRect r = [self frameForImage: [self screenImageView].image inImageViewAspectFit: [self screenImageView]];
            CGRect tagRect = CGRectMake (r.origin.x + [tag.rectTopLeftX floatValue] * r.size.width,
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
    
    self.screenImageView.tagRects = array;// Assume the setter manages memory properly!
}

// Sent from the ScreenImageView to tell controller selected tag rect has changed
- (void)mouseUp:(NSEvent *)theEvent
{
    if (self.tagsArrayController.selectionIndex == NSNotFound)
        return;
    
    // Get tag out of ArrayController
    Tag *tag = [self.tagsArrayController valueForKeyPath:@"selection.self"];
    
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
