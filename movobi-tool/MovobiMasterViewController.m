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
@synthesize movies;
@synthesize screens;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    
    return self;
}

- (void)loadView
{
    [super loadView];
    
    // Being called twice when set-up by app delegate
    if (self.movies == nil)
    {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
        NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSArray *sortDescriptors = @[nameDescriptor];
        [fetchRequest setSortDescriptors: sortDescriptors];
        NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Movie" inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        NSError *error;
        NSArray *localMovies = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        self.movies = [NSMutableArray arrayWithArray: localMovies];
        
        
        // Log db
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
        
    }
    [self.moviesTableView setDelegate: self];
    [self.moviesTableView setDataSource: self];
    [self.screensTableView setDelegate: self];
    [self.screensTableView setDataSource: self];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    
    NSInteger count=0;
    if (tableView == self.screensTableView) {
        if (screens != nil) {
                count=[self.screens count];
        }
    }
    else {
        NSLog (@"ERROR - unexpected tableView");
    }
    return count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    // the return value is typed as (id) because it will return a string in all cases with the exception of the
    id returnValue=nil;

    if (aTableView == self.screensTableView) {
        if (screens != nil) {
            NSString *columnIdentifer = [aTableColumn identifier];
    
            // Get the name at the specified row in the namesArray
            Screen *screen = [screens objectAtIndex:rowIndex];
            //NSLog (@"t: %@ mg: %@", screen.time, screen.image);
    
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
        if (screens != nil) {
            NSString *columnIdentifer = [aTableColumn identifier];
    
            if ([columnIdentifer isEqualToString:@"time"]) {
                
                NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                [f setNumberStyle:NSNumberFormatterDecimalStyle];
                NSNumber * time = [f numberFromString: anObject];
                time = [NSNumber numberWithInt: [time intValue]];
                
                // Update the time
                NSInteger row = [self.screensTableView selectedRow];
                Screen *screen = [self.screens objectAtIndex: row];
                screen.time = time;
                
                // Re-sort
                NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
                NSArray *sortDescriptors = @[nameDescriptor];
                NSArray *localScreens = [self.screens sortedArrayUsingDescriptors: sortDescriptors];
                self.screens = [NSMutableArray arrayWithArray: localScreens];
            
                // Update the movie (i.e. save change)
                Movie *movie = [movies objectAtIndex: [self.moviesTableView selectedRow]];
                movie.screens = [NSMutableSet setWithArray: self.screens];
                
                // Reload because may have changed sort order
                [self.screensTableView reloadData];
            }
            else if ([columnIdentifer isEqualToString:@"image"]) {

            }
        }
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    NSTableView *aTableView = [aNotification object];
    if (aTableView == self.moviesTableView)
    {
        NSInteger row = [aTableView selectedRow];
        Movie *movie = [movies objectAtIndex: row];
        
        NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"time" ascending:YES];
        NSArray *sortDescriptors = @[nameDescriptor];
        NSArray *localScreens = [movie.screens sortedArrayUsingDescriptors: sortDescriptors];
        self.screens = [NSMutableArray arrayWithArray: localScreens];
        
        [self.screensTableView reloadData];
    }
    else if (aTableView == self.screensTableView)
    {
        NSOpenPanel* openDlg = [NSOpenPanel openPanel];
        
        [openDlg setCanChooseFiles:YES];
        [openDlg setAllowsMultipleSelection:NO];
        [openDlg setCanChooseDirectories:NO];
        NSURL* imageName;
        if ( [openDlg runModal] == NSOKButton )
        {
            NSArray* urls = [openDlg URLs];
            for(int i = 0; i < [urls count]; i++ )
            {
                imageName = [urls objectAtIndex:i];
            }
            Screen *screen = [screens objectAtIndex: [aTableView selectedRow]];
            NSImage *image = [[NSImage alloc] initWithContentsOfURL: imageName];
            screen.image = image;
        }
    }
}

- (IBAction)addScreen:(id)sender {
    
    Screen *screen = [NSEntityDescription
                       insertNewObjectForEntityForName:@"Screen"
                       inManagedObjectContext:managedObjectContext];
    
    // Connect up to movie
    Movie *movie = [movies objectAtIndex: [self.moviesTableView selectedRow]];
    screen.movie = movie;
    
    // Add to the array and to the movie (will then save)
    [screens addObject:screen];
    movie.screens = [NSMutableSet setWithArray: self.screens];
    
    // Reload to add to tableview
    [self.screensTableView reloadData];
}

- (IBAction)removeScreen:(id)sender {
    Screen *screen = [screens objectAtIndex: [self.screensTableView selectedRow]];
    [screens removeObject:screen];
    
    // Update the movie (will then save)
    Movie *movie = [movies objectAtIndex: [self.moviesTableView selectedRow]];
    movie.screens = [NSMutableSet setWithArray: self.screens];
    
    // Reload to remove from tableview
    [self.screensTableView reloadData];
}

@end
