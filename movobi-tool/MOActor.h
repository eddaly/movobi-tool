//
//  MOActor.h
//  movobi-tool
//
//  Created by Ed Daly on 23/04/2013.
//  Copyright (c) 2013 Movobi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MObject.h"

@class MOCharacter;

@interface MOActor : MObject

@property (nonatomic, retain) NSSet *characters;
@end

@interface MOActor (CoreDataGeneratedAccessors)

- (void)addCharactersObject:(MOCharacter *)value;
- (void)removeCharactersObject:(MOCharacter *)value;
- (void)addCharacters:(NSSet *)values;
- (void)removeCharacters:(NSSet *)values;

@end
