//
//  MFPrivacyViewController.h
//  botmusic
//
//  Created by Panda Systems on 9/9/15.
//
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    MFPlaylistsPrivacySettingsEveryone,
    MFPlaylistsPrivacySettingsUsers,
    MFPlaylistsPrivacySettingsMeOnly,
} MFPlaylistsPrivacySettings;

@interface MFPrivacyViewController : UIViewController

@end
