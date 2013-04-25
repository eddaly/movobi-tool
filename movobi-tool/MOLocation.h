//
//  MOLocation.h
//  movobi-tool
//
//  Created by Ed Daly on 25/04/2013.
//  Copyright (c) 2013 Movobi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MObject.h"


@interface MOLocation : MObject

@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;

@end
