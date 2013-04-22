//
//  MOProp.h
//  movobi-tool
//
//  Created by Ed Daly on 22/04/2013.
//  Copyright (c) 2013 Movobi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MObject.h"

@class Film;

@interface MOProp : MObject

@property (nonatomic, retain) NSSet *films;
@end

@interface MOProp (CoreDataGeneratedAccessors)

- (void)addFilmsObject:(Film *)value;
- (void)removeFilmsObject:(Film *)value;
- (void)addFilms:(NSSet *)values;
- (void)removeFilms:(NSSet *)values;

@end
