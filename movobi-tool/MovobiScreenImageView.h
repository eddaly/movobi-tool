//
//  MovobiScreenImageView.h
//  movobi-tool
//
//  Created by Ed Daly on 14/04/2013.
//  Copyright (c) 2013 Movobi Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MovobiScreenImageView : NSImageView

@property (nonatomic, strong) NSMutableArray *tagRects;
@property (nonatomic, strong) NSNumber *selectedTagIndex;
@property BOOL draggingSelectedTag;
@property CGRect origSelectedTagRect;
@property SEL action;
@property id target;


@end
