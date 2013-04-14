//
//  Movie.h
//  movobi
//
//  Created by Ed Daly on 30/03/2013.
//  Copyright (c) 2013 Movobi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Screen, Tag;

@interface Movie : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * resolutionHeight;
@property (nonatomic, retain) NSNumber * resolutionWidth;
@property (nonatomic, retain) NSMutableSet *tags;
@property (nonatomic, retain) NSMutableSet *screens;
@end

@interface Movie (CoreDataGeneratedAccessors)

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

- (void)addScreensObject:(Screen *)value;
- (void)removeScreensObject:(Screen *)value;
- (void)addScreens:(NSSet *)values;
- (void)removeScreens:(NSSet *)values;

@end
