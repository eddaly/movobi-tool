//
//  Film.h
//  movobi-tool
//
//  Created by Ed Daly on 22/04/2013.
//  Copyright (c) 2013 Movobi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Film : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * year;
@property (nonatomic, retain) id image;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSSet *actors;
@property (nonatomic, retain) NSSet *screens;
@property (nonatomic, retain) NSSet *props;
@property (nonatomic, retain) NSSet *locations;
@end

@interface Film (CoreDataGeneratedAccessors)

- (void)addActorsObject:(NSManagedObject *)value;
- (void)removeActorsObject:(NSManagedObject *)value;
- (void)addActors:(NSSet *)values;
- (void)removeActors:(NSSet *)values;

- (void)addScreensObject:(NSManagedObject *)value;
- (void)removeScreensObject:(NSManagedObject *)value;
- (void)addScreens:(NSSet *)values;
- (void)removeScreens:(NSSet *)values;

- (void)addPropsObject:(NSManagedObject *)value;
- (void)removePropsObject:(NSManagedObject *)value;
- (void)addProps:(NSSet *)values;
- (void)removeProps:(NSSet *)values;

- (void)addLocationsObject:(NSManagedObject *)value;
- (void)removeLocationsObject:(NSManagedObject *)value;
- (void)addLocations:(NSSet *)values;
- (void)removeLocations:(NSSet *)values;

@end
