//
//  MObject.h
//  movobi-tool
//
//  Created by Ed Daly on 24/04/2013.
//  Copyright (c) 2013 Movobi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Film, Tag;

@interface MObject : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) id image;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) NSSet *films;
@end

@interface MObject (CoreDataGeneratedAccessors)

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

- (void)addFilmsObject:(Film *)value;
- (void)removeFilmsObject:(Film *)value;
- (void)addFilms:(NSSet *)values;
- (void)removeFilms:(NSSet *)values;

@end
