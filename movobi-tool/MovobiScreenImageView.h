//
//  MovobiScreenImageView.h
//  movobi-tool
//
//  Created by Ed Daly on 14/04/2013.
//  Copyright (c) 2013 Movobi Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MovobiScreenImageView : NSImageView

@property (nonatomic, strong) NSArray *tagRects;
@property (nonatomic, strong) NSNumber *selectedTagIndex;

@end
