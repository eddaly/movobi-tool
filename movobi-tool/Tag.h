//
//  Tag.h
//  movobi
//
//  Created by Ed Daly on 30/03/2013.
//  Copyright (c) 2013 Movobi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Movie;

@interface Tag : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * rectHeight;
@property (nonatomic, retain) NSNumber * rectTopLeftX;
@property (nonatomic, retain) NSNumber * rectTopLeftY;
@property (nonatomic, retain) NSNumber * rectWidth;
@property (nonatomic, retain) NSNumber * timeEnd;
@property (nonatomic, retain) NSNumber * timeStart;
@property (nonatomic, retain) Movie *movie;

@end
