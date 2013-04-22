//
//  Referral.h
//  movobi-tool
//
//  Created by Ed Daly on 22/04/2013.
//  Copyright (c) 2013 Movobi Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MObject;

@interface Referral : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) id image;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * owner;
@property (nonatomic, retain) MObject *mobject;

@end
