//
//  MOCharacter.h
//  movobi-tool
//
//  Created by Ed Daly on 25/04/2013.
//  Copyright (c) 2013 Movobi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MObject.h"

@class MOActor;

@interface MOCharacter : MObject

@property (nonatomic, retain) NSSet *actors;
@end

@interface MOCharacter (CoreDataGeneratedAccessors)

- (void)addActorsObject:(MOActor *)value;
- (void)removeActorsObject:(MOActor *)value;
- (void)addActors:(NSSet *)values;
- (void)removeActors:(NSSet *)values;

@end
