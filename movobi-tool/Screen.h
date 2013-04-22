//
//  Screen.h
//  movobi-tool
//
//  Created by Ed Daly on 22/04/2013.
//  Copyright (c) 2013 Movobi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Film;

@interface Screen : NSManagedObject

@property (nonatomic, retain) id image;
@property (nonatomic, retain) NSNumber * timeStart;
@property (nonatomic, retain) NSNumber * timeEnd;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) Film *film;
@end

@interface Screen (CoreDataGeneratedAccessors)

- (void)addTagsObject:(NSManagedObject *)value;
- (void)removeTagsObject:(NSManagedObject *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
