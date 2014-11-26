//
//  DHPostTextView.h
//  Appetizr
//
//  Created by dasdom on 26.08.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface DHPostTextView : UIView {
    CTFramesetterRef _framesetter;
    CTFrameRef _frame;
}

@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) NSArray *linkRangeArray;
@property (nonatomic, strong) NSArray *mentionRangeArray;
@property (nonatomic, strong) NSArray *hashTagRangeArray;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *linkColor;
@property (nonatomic, strong) UIColor *mentionColor;
@property (nonatomic, strong) UIColor *hashTagColor;
@property (nonatomic) BOOL isFocused;

- (void)addLinkRange:(NSRange)linkRange forLink:(NSString*)linkString;
- (void)removeAllLinks;
- (void)addMentionRange:(NSRange)mentionRange forUserId:(NSString*)userId;
- (void)removeAllMentions;
- (void)addHashTagRange:(NSRange)hashTagRange forName:(NSString*)name;
- (void)removeAllHashTags;

- (NSInteger)closestIndexToPoint:(CGPoint)point;
- (NSString*)linkForPoint:(CGPoint)point;
- (NSString*)userIdForPoint:(CGPoint)point;
- (NSString*)hashTagForPoint:(CGPoint)point;
//- (CGFloat)heightOfText;
- (void)setText:(NSString *)text withDefaultColors:(BOOL)useDefaultColors;

@end
