//
//  MObject.h
//  movobi-tool
//
//  Created by Ed Daly on 22/04/2013.
//  Copyright (c) 2013 Movobi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface MObject : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *referrals;
@property (nonatomic, retain) NSSet *tags;
@end

@interface MObject (CoreDataGeneratedAccessors)

- (void)addReferralsObject:(NSManagedObject *)value;
- (void)removeReferralsObject:(NSManagedObject *)value;
- (void)addReferrals:(NSSet *)values;
- (void)removeReferrals:(NSSet *)values;

- (void)addTagsObject:(NSManagedObject *)value;
- (void)removeTagsObject:(NSManagedObject *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
