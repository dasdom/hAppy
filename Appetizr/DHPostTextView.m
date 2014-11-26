//
//  DHPostTextView.m
//  Appetizr
//
//  Created by dasdom on 26.08.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import "DHPostTextView.h"
#import <QuartzCore/QuartzCore.h>
//#import "DHGlobalObjects.h"

@implementation DHPostTextView {
    CTFontRef _ctFont;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    self.layer.geometryFlipped = YES;
    self.text = @"";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _font = [UIFont fontWithName:[userDefaults objectForKey:kFontName] size:[[userDefaults objectForKey:kFontSize] floatValue]];
    _ctFont = CTFontCreateWithName((__bridge CFStringRef) self.font.fontName, self.font.pointSize, NULL);
//    self.backgroundColor = [UIColor whiteColor];
    self.linkRangeArray = @[];
    self.mentionRangeArray = @[];
}

- (void)dealloc {
    if (_framesetter != NULL) {
        CFRelease(_framesetter);
        _framesetter = NULL;
    }
    
    if (_frame != NULL) {
        CFRelease(_frame);
        _frame = NULL;
    }
    
    if (_ctFont != NULL) {
        CFRelease(_ctFont);
        _ctFont = NULL;
    }
}

- (void)clearPreviousLayoutInformation
{
    if (_framesetter != NULL) {
        CFRelease(_framesetter);
        _framesetter = NULL;
    }
    
    if (_frame != NULL) {
        CFRelease(_frame);
        _frame = NULL;
    }
}

- (void)setFont:(UIFont *)font {
    _font = font;

    CFRelease(_ctFont);
    _ctFont = CTFontCreateWithName((__bridge CFStringRef) self.font.fontName, self.font.pointSize, NULL);
}

- (void)addLinkRange:(NSRange)linkRange forLink:(NSString*)linkString {
    NSMutableArray *mutableArray = [self.linkRangeArray mutableCopy];
//    [mutableArray addObject:[NSValue valueWithRange:linkRange]];
    NSDictionary *linkDict = @{ @"range" : [NSValue valueWithRange:linkRange], @"link" : linkString };
    [mutableArray addObject:linkDict];
    self.linkRangeArray = [mutableArray copy];
}

- (void)removeAllLinks {
    self.linkRangeArray = @[];
}

- (void)addMentionRange:(NSRange)mentionRange forUserId:(NSString*)userId {
    NSMutableArray *mutableArray = [self.mentionRangeArray mutableCopy];
    NSDictionary *linkDict = @{@"range" : [NSValue valueWithRange:mentionRange], @"id": userId };
    [mutableArray addObject:linkDict];
    self.mentionRangeArray = [mutableArray copy];
}

- (void)removeAllMentions {
    self.mentionRangeArray = @[];
}

- (void)addHashTagRange:(NSRange)hashTagRange forName:(NSString*)name {
    NSMutableArray *mutableArray = [self.hashTagRangeArray mutableCopy];
    NSDictionary *linkDict = @{@"range" : [NSValue valueWithRange:hashTagRange], @"name": name};
    [mutableArray addObject:linkDict];
    self.hashTagRangeArray = [mutableArray copy];
}

- (void)removeAllHashTags {
    self.hashTagRangeArray = @[];
}

- (void)textChanged
{
//    self.accessibilityValue = self.text;
    [self clearPreviousLayoutInformation];
   
//    CTFontRef sysUIFont = CTFontCreateUIFontForLanguage(kCTFontSystemFontType, 15.0f, NULL);
    
    NSString *string = self.text;
    if (string.length < 1) {
        return;
    }
    
//    UIColor *linkColor;
//    UIColor *mentionColor;
//    UIColor *hashTagColor;
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
//        linkColor = [DHGlobalObjects sharedGlobalObjects].darkLinkColor;
//        mentionColor = [DHGlobalObjects sharedGlobalObjects].darkMentionColor;
//        hashTagColor = [DHGlobalObjects sharedGlobalObjects].darkHashTagColor;
//    } else {
//        linkColor = [DHGlobalObjects sharedGlobalObjects].linkColor;
//        mentionColor = [DHGlobalObjects sharedGlobalObjects].mentionColor;
//        hashTagColor = [DHGlobalObjects sharedGlobalObjects].hashTagColor;
//    }
    
    //    NSNumber *underline = [NSNumber numberWithInt:kCTUnderlineStyleSingle | kCTUnderlinePatternDot];
    
    NSDictionary *attributesDict = [NSDictionary dictionaryWithObjectsAndKeys: (__bridge id)_ctFont, (NSString*)kCTFontAttributeName,
                                                                      (__bridge id)self.textColor.CGColor, (NSString*)kCTForegroundColorAttributeName,
                                    //(id)underline, (NSString*)kCTUnderlineStyleAttributeName,
                                    nil];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string attributes:attributesDict];


    for (NSDictionary *linkDict in self.linkRangeArray) {
        NSRange linkRange =  [[linkDict objectForKey:@"range"] rangeValue];
        
        NSRange testRange = [string rangeOfComposedCharacterSequenceAtIndex:linkRange.location];
        if (testRange.length > 1) {
            continue;
        }
        if ([attributedString length] >= linkRange.location + linkRange.length) {
            [attributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(__bridge id)self.linkColor.CGColor range: linkRange];
        }
    }

    for (NSDictionary *mentionDict in self.mentionRangeArray) {
        NSRange mentionRange = [[mentionDict objectForKey:@"range"] rangeValue];
        
        NSRange testRange = [string rangeOfComposedCharacterSequenceAtIndex:mentionRange.location];
        if (testRange.length > 1) {
            continue;
        }
        if ([attributedString length] >= mentionRange.location + mentionRange.length) {
            [attributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(__bridge id)self.mentionColor.CGColor range:mentionRange];
        }
    }

    for (NSDictionary *hashTagDict in self.hashTagRangeArray) {
        NSRange hashTagRange = [[hashTagDict objectForKey:@"range"] rangeValue];

        NSRange testRange = [string rangeOfComposedCharacterSequenceAtIndex:hashTagRange.location];
        if (testRange.length > 1) {
            continue;
        }
        if ([attributedString length] >= hashTagRange.location + hashTagRange.length) {
            [attributedString addAttribute:(NSString*)kCTForegroundColorAttributeName value:(__bridge id)self.hashTagColor.CGColor range:hashTagRange];
        }
    }

	// Create the Core Text framesetter using the attributed string
    _framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
    
	// Create the Core Text frame using our current view rect bounds
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    _frame =  CTFramesetterCreateFrame(_framesetter, CFRangeMake(0, 0), [path CGPath], NULL);

}

- (void)setText:(NSString *)text {
    [self setText:text withDefaultColors:YES];
}

- (void)setText:(NSString *)text withDefaultColors:(BOOL)useDefaultColors {
    if (useDefaultColors) {
        [self setDefaultColors];
    }
    
    _text = [text copy];
    
    [self textChanged];
}

- (void)setDefaultColors
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kDarkMode]) {
        self.textColor = [DHGlobalObjects sharedGlobalObjects].darkTextColor;
        self.linkColor = [DHGlobalObjects sharedGlobalObjects].darkLinkColor;
        self.mentionColor = [DHGlobalObjects sharedGlobalObjects].darkMentionColor;
        self.hashTagColor = [DHGlobalObjects sharedGlobalObjects].darkHashTagColor;
    } else {
        self.textColor = [DHGlobalObjects sharedGlobalObjects].textColor;
        self.linkColor = [DHGlobalObjects sharedGlobalObjects].linkColor;
        self.mentionColor = [DHGlobalObjects sharedGlobalObjects].mentionColor;
        self.hashTagColor = [DHGlobalObjects sharedGlobalObjects].hashTagColor;
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CTFrameDraw(_frame, UIGraphicsGetCurrentContext());
}

// Public method to find the text range index for a given CGPoint
- (NSInteger)closestIndexToPoint:(CGPoint)point
{
	// Use Core Text to find the text index for a given CGPoint by
	// iterating over the y-origin points for each line, finding the closest
	// line, and finding the closest index within that line.
    NSArray *lines = (__bridge NSArray *) CTFrameGetLines(_frame);
    CGPoint origins[lines.count];
    CTFrameGetLineOrigins(_frame, CFRangeMake(0, lines.count), origins);
    
    for (int i = 0; i < lines.count; i++) {
        if (point.y > origins[i].y) {
			// This line origin is closest to the y-coordinate of our point,
			// now look for the closest string index in this line.
            CTLineRef line = (__bridge CTLineRef) [lines objectAtIndex:i];
            return CTLineGetStringIndexForPosition(line, point);
            
        }
    }
    
    return  _text.length;
    
}

//- (CGFloat)heightOfText {
//    NSArray *lines = (__bridge NSArray *) CTFrameGetLines(_frame);
//    CGPoint origins[lines.count];
//    CTFrameGetLineOrigins(_frame, CFRangeMake(0, lines.count), origins);
//    
//    dhDebug(@"self.text: %@", self.text);
//    int lastLine = 0;
//    for (int i = 0; i < lines.count; i++) {
//        dhDebug(@"origin[%d].y: %f", i, origins[i].y);
//        lastLine = i;
//    }
//    dhDebug(@"numberOfLines: %d, frame.size.height: %f", lastLine, self.frame.size.height);
//    dhDebug(@"lineHeight: %f, %f, %f", self.font.lineHeight, self.font.ascender, self.font.descender);
//    return (self.font.lineHeight+self.font.descender)*(lastLine+1);
//}

- (NSString*)linkForPoint:(CGPoint)point {
    NSInteger index = [self closestIndexToPoint:point];
    for (NSDictionary *linkDict in self.linkRangeArray) {
        NSRange linkRange = [[linkDict objectForKey:@"range"] rangeValue];
        if (linkRange.location < index && index < linkRange.location + linkRange.length) {
            return [linkDict objectForKey:@"link"];
        }
    }
    return nil;
}

- (NSString*)userIdForPoint:(CGPoint)point {
    NSInteger index = [self closestIndexToPoint:point];
    for (NSDictionary *mentionDict in self.mentionRangeArray) {
        dhDebug(@"mentionDict: %@", mentionDict);
        NSRange mentionRange = [[mentionDict objectForKey:@"range"] rangeValue];
        dhDebug(@"mentionRange: %@; index: %d", [mentionDict objectForKey:@"range"], index);
        if (mentionRange.location < index && index < mentionRange.location + mentionRange.length) {
            return [mentionDict objectForKey:@"id"];
        }
    }
    return nil;
}

- (NSString*)hashTagForPoint:(CGPoint)point {
    NSInteger index = [self closestIndexToPoint:point];
    for (NSDictionary *hashTagDict in self.hashTagRangeArray) {
        dhDebug(@"hashTagDict: %@", hashTagDict);
        NSRange hashTagRange = [[hashTagDict objectForKey:@"range"] rangeValue];
        dhDebug(@"hashTagRange: %@; index: %d", [hashTagDict objectForKey:@"range"], index);
        if (hashTagRange.location < index && index < hashTagRange.location + hashTagRange.length) {
            return [hashTagDict objectForKey:@"name"];
        }
    }
    return nil;
}

//- (NSString*)description {
//    return self.text;
//}

//- (BOOL)isAccessibilityElement {
//    return YES;
//}

- (NSString*)accessibilityLabel {
    return self.text;
}

- (void)accessibilityElementDidBecomeFocused {
    self.isFocused = YES;
}

- (void)accessibilityElementDidLoseFocus {
    self.isFocused = NO;
}

@end
