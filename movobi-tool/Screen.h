//
//  Screen.h
//  movobi-tool
//
//  Created by Ed Daly on 25/04/2013.
//  Copyright (c) 2013 Movobi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Film, Tag;

@interface Screen : NSManagedObject

@property (nonatomic, retain) id image;
@property (nonatomic, retain) NSNumber * timeEnd;
@property (nonatomic, retain) NSNumber * timeStart;
@property (nonatomic, retain) NSNumber * flags;
@property (nonatomic, retain) NSData * data;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) Film *film;
@property (nonatomic, retain) NSSet *tags;
@end

@interface Screen (CoreDataGeneratedAccessors)

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
