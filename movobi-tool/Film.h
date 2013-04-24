//
//  Film.h
//  movobi-tool
//
//  Created by Ed Daly on 23/04/2013.
//  Copyright (c) 2013 Movobi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MObject, Screen;

@interface Film : NSManagedObject

@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) id image;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * year;
@property (nonatomic, retain) NSSet *screens;
@property (nonatomic, retain) NSSet *mobjects;
@end

@interface Film (CoreDataGeneratedAccessors)

- (void)addScreensObject:(Screen *)value;
- (void)removeScreensObject:(Screen *)value;
- (void)addScreens:(NSSet *)values;
- (void)removeScreens:(NSSet *)values;

- (void)addMobjectsObject:(MObject *)value;
- (void)removeMobjectsObject:(MObject *)value;
- (void)addMobjects:(NSSet *)values;
- (void)removeMobjects:(NSSet *)values;

@end
