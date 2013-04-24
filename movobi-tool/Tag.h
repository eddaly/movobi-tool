//
//  Tag.h
//  movobi-tool
//
//  Created by Ed Daly on 23/04/2013.
//  Copyright (c) 2013 Movobi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MObject, Screen;

@interface Tag : NSManagedObject

@property (nonatomic, retain) NSNumber * rectHeight;
@property (nonatomic, retain) NSNumber * rectTopLeftX;
@property (nonatomic, retain) NSNumber * rectTopLeftY;
@property (nonatomic, retain) NSNumber * rectWidth;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSSet *mobjects;
@property (nonatomic, retain) Screen *screen;
@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addMobjectsObject:(MObject *)value;
- (void)removeMobjectsObject:(MObject *)value;
- (void)addMobjects:(NSSet *)values;
- (void)removeMobjects:(NSSet *)values;

@end
