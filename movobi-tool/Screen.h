//
//  Screen.h
//  movobi
//
//  Created by Ed Daly on 30/03/2013.
//  Copyright (c) 2013 Movobi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MovobiImageTransformer.h"

@class Movie;

@interface Screen : NSManagedObject

@property (nonatomic, retain) id image;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) Movie *movie;

@end
