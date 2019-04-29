//
//  Common.h
//  botmusic
//
//  Created by Илья Романеня on 10.12.13.
//  Copyright (c) 2013 wellnuts. All rights reserved.
//

#ifndef botmusic_Common_h
#define botmusic_Common_h

//Utils
#import "NSObject+Utilities.h"
#import "UIViewController+Presents.h"
#import "UIColor+ExtendedColors.h"
#import "NSObject+JSON.h"
#import "UIColor+Expanded.h"

//Networking
#define ShowNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HideNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = NO

#ifdef PRODUCTION
#define BASE_URL_STRING @"http://musicfeed.rubyforce.co/api/client/"
#define BASE_URL [NSURL URLWithString:BASE_URL_STRING]

#define V2_BASE_URL_STRING @"http://musicfeed.rubyforce.co/api/client/v2/"
#define V2_BASE_URL [NSURL URLWithString:V2_BASE_URL_STRING]

#endif

#ifdef STAGING
#define BASE_URL_STRING @"http://musicfeed-staging.rubyforce.co/api/client/"
#define BASE_URL [NSURL URLWithString:BASE_URL_STRING]

#define V2_BASE_URL_STRING @"http://musicfeed-staging.rubyforce.co/api/client/v2/"
#define V2_BASE_URL [NSURL URLWithString:V2_BASE_URL_STRING]
#endif

//Managers
#import "IRNetworkClient.h"

#import "IRSettingsManager.h"
#define settingsManager [IRSettingsManager sharedInstance]

#import "MFDataManager.h"
#define dataManager [MFDataManager sharedInstance]

#import "IRUserManager.h"
#define userManager [IRUserManager sharedInstance]

#import "IRPlayerManager.h"
#define playerManager [IRPlayerManager sharedInstance]

#import "MFMessageManager.h"

#import "MFSaver.h"
#define saver [MFSaver sharedInstance]

#define DEFAULT_IMAGE [UIImage imageNamed:@"NoImage.png"]

#define NSLogExt(x,...) NSLog((@"%s [Line %d] " x), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

//Colors
#define kActiveColor 0xc6c6c6
#define kInactiveColor 0xffffff
#define kSeparatorColor 0xe5e5e5
#define kBackgroundColor 0x131313
#define kAppMainColor 0xFF1957
#define kAppMainInverseColor 0x00e6a8
#define kAppPlayerColor 0x343434

//New Design Colors
#define kBrandPinkColor 0xF30049
#define kBrandBlueColor 0x007AFF
#define kDarkColor 0x222222
#define kJetColor 0x444444
#define kMediumColor 0x777777
#define kLightColor 0xAAAAAA
#define kFaintColor 0xDDDDDD
#define kOffWhiteColor 0xF7F7F7
#define kLovedColor 0xF23F51
#define kSuccessColor 0x00D763
#define kNewBlueColor 0x1870FF
//Fonts
#define kMainFontFamilyName @"HelveticaNeue-CondensedBold"

//Global const
#define kPlayerHideDelay 10.0

//Device settings
#define IS_IPHONE_5 [UIScreen mainScreen].bounds.size.height>480

#endif
