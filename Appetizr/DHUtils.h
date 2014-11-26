//
//  DHUtils.h
//  Appetizr
//
//  Created by dasdom on 13.08.12.
//  Copyright (c) 2012 dasdom. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kBaseURL @"https://alpha-api.app.net/stream/0/"
#define kUsersSubURL @"users/"
#define kMeSubURL @"me"
#define kPostsSubURL @"posts/"

#define kInstapaperAuthURL @"https://www.instapaper.com/api/authenticate"
#define kInstapaperAddURL @"https://www.instapaper.com/api/add"
#define kInstapaperUserNameKey @"kInstapagerUserNameKey"
#define kInstapaperServiceName @"de.dasdom.happy.instapaper"

#define kPocketUserNameKey @"kPocketUserNameKey"

#define kUserArrayKey @"kUserArrayKey"
//#define kUserDictionaryKey @"kUserDictionaryKey"

#define kAccessTokenDefaultsKey @"accessToken"
//#define kImglyDelegateToken @"ImglyDelegateToken"
#define kUserIdDefaultKey @"userId"
#define kUserNameDefaultKey @"UserNameDefaultKey"

#define kFontName @"FontName"
#define kFontSize @"FontSize"
#define kIncludeDirecedPosts @"IncludeDirecedPosts"
#define kDontLoadImages @"DontLoadImages"
#define kOnlyLoadImagesInWifi @"kOnlyLoadImagesInWifi"
#define kShowRealNames @"ShowRealNames"
#define kDarkMode @"kDarkMode"
#define kAutomaticSwitchTheme @"kAutomaticSwitchTheme"
#define kBrightnessThemeSwitchValue @"kBrightnessThemeSwitchValue"
#define kStreamMarker @"kStreamMarker"
#define kNormalKeyboard @"kNormalKeyboard"
#define kAboluteTimeStamp @"kAboluteTimeStamp"
#define kIgnoreUnreadPatter @"kIgnoreUnreadPatter"
#define kHideSeenThreads @"HideSeenThreads"
#define kDontShowPhotosHint @"kDontShowPhotosHint"
#define kHideClient @"kHideClient"
#define kInlineImages @"kInlineImages"

#define kSettingsChangedNotification @"SettingsChangedNotification"
#define kUpdateChannelsArray @"UpdateChannelsArray"
#define kUserChangedNotification @"kUserChangedNotification"
//#define kCreatePostNotification @"kCreatePostNotification"
#define kSendToInstapaperNotification @"kSendToInstapaperNotification"
#define kSendToPocketNotification @"kSendToPocketNotification"

#define kNumberOfUnreadMessagesNotification @"kNumberOfUnreadMessagesNotification"
#define kChangeColorsNotification @"kChangeColorsNotification"
#define kMenuTouchedNotification @"kMenuTouchedNotification"
#define kHideMenuNotification @"kHideMenuNotification"

#define kColorChangedNotification @"kColorChangedNotification"

#define kPurchasedProductNotification @"kPurchasedProductNotification"
#define kPurchasFailedNotification @"kPurchasFailedNotification"

#define kLoginHappendNotification @"kLoginHappendNotification"

//#define kMainColor [UIColor colorWithRed:121.0f/255.0f green:170.0f/255.0f blue:190.0f/255.0f alpha:1.0f]
#define kMainColor [UIColor colorWithRed:0.78f green:0.78f blue:0.72f alpha:1.0f]
#define kLightCellBackgroundColorDefault [UIColor colorWithRed:0.97f green:0.97f blue:0.93f alpha:1.0f]
#define kLightCellBackgroundColorMarked [UIColor colorWithRed:0.89f green:0.89f blue:0.85f alpha:1.0f]
#define kLightCellBackgroundColorLepliedTo [UIColor colorWithRed:0.89f green:0.89f blue:0.85f alpha:1.0f]
#define kLightTextColor [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f]
#define kLightTintColor [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f]
#define kLightMarkerColor [UIColor colorWithRed:0.26f green:0.46f blue:0.62f alpha:1.0f]
#define kLightSeparatorColor [UIColor colorWithRed:0.85f green:0.87f blue:0.9f alpha:1.0f]

#define kDarkMainColor [UIColor colorWithRed:0.18f green:0.3f blue:0.33f alpha:1.0f]
#define kDarkCellBackgroundColorDefault [UIColor colorWithRed:0.0f green:0.16f blue:0.15f alpha:1.0f]
#define kDarkCellBackgroundColorMarked [UIColor colorWithRed:0.1f green:0.20f blue:0.25f alpha:1.0f]
#define kDarkCellBackgroundColorLepliedTo [UIColor colorWithRed:0.1f green:0.20f blue:0.25f alpha:1.0f]
#define kDarkTextColor [UIColor colorWithRed:0.9f green:0.88f blue:0.85f alpha:1.0f]
#define kDarkTintColor [UIColor colorWithRed:0.85f green:0.86f blue:0.85f alpha:1.0f]
#define kDarkMarkerColor [UIColor colorWithRed:1.0f green:0.61f blue:0.0f alpha:1.0f]
#define kDarkSeparatorColor [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0f]

//#define kDarkMainColor [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f]
//#define kDarkCellBackgroundColorDefault [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:1.0f]
//#define kDarkCellBackgroundColorMarked [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f]
//#define kDarkCellBackgroundColorLepliedTo [UIColor colorWithRed:0.22f green:0.22f blue:0.24f alpha:1.0f]
//#define kDarkTextColor [UIColor whiteColor]


//#define kMainFont [UIFont systemFontOfSize:15.0f]
#define kProfileDescriptionFont [UIFont systemFontOfSize:13.0f]
#define kLightLinkColor [UIColor colorWithRed:0.96f green:0.46f blue:0.45f alpha:1.0f];
#define kLightMentionColor [UIColor colorWithRed:0.20f green:0.51f blue:0.77f alpha:1.0f];
#define kLightHashTagColor [UIColor colorWithRed:0.33f green:0.76f blue:0.55f alpha:1.0f];

#define kDarkLinkColor [UIColor colorWithRed:0.14f green:0.55f blue:0.66f alpha:1.0f];
#define kDarkMentionColor [UIColor colorWithRed:0.88f green:0.58f blue:0.0f alpha:1.0f];
#define kDarkHashTagColor [UIColor colorWithRed:0.88f green:0.58f blue:0.0f alpha:1.0f];

#define kCustomMainColor @"kCustomMainColor"
#define kCustomCellBackgroundColor @"kCustomCellBackgroundColor"
#define kCustomMarkedCellBackgroundColor @"kCustomMarkedCellBackgroundColor"
#define kCustomTextColor @"kCustomTextColor"
#define kCustomMentionColor @"kCustomMentionColor"
#define kCustomLinkColor @"kCustomLinkColor"
#define kCustomHashtagColor @"kCustomHashtagColor"
#define kCustomTintColor @"kCustomTintColor"
#define kCustomMarkerColor @"kCustomMarkerColor"
#define kCustomSeparatorColor @"kCustomSeparatorColor"

#define kCustomDarkMainColor @"kCustomDarkMainColor"
#define kCustomDarkCellBackgroundColor @"kCustomDarkCellBackgroundColor"
#define kCustomDarkMarkedCellBackgroundColor @"kCustomDarkMarkedCellBackgroundColor"
#define kCustomDarkTextColor @"kCustomDarkTextColor"
#define kCustomDarkMentionColor @"kCustomDarkMentionColor"
#define kCustomDarkLinkColor @"kCustomDarkLinkColor"
#define kCustomDarkHashtagColor @"kCustomDarkHashtagColor"
#define kCustomDarkTintColor @"kCustomDarkTintColor"
#define kCustomDarkMarkerColor @"kCustomDarkMarkerColor"
#define kCustomDarkSeparatorColor @"kCustomDarkSeparatorColor"

@interface DHUtils : NSObject

+ (NSString*)stringOrEmpty:(id)value;

@end
