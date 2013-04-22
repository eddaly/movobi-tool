//
//  Tag.h
//  movobi-tool
//
//  Created by Ed Daly on 22/04/2013.
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
@property (nonatomic, retain) MObject *mobject;
@property (nonatomic, retain) Screen *screen;

@end
