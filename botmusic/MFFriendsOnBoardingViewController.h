//
//  MFFriendsOnBoardingViewController.h
//  botmusic
//
//  Created by Panda Systems on 8/27/15.
//
//

#import <UIKit/UIKit.h>
#import "MFOnBoardingViewController.h"

typedef enum : NSUInteger {
    MFFriendsTypeFacebook,
    MFFriendsTypeContacts,
    MFFriendsTypeImportedArtists,
} MFFriendsType;

@interface MFFriendsOnBoardingViewController : AbstractViewController

@property(nonatomic) MFFriendsType friendsType;
@property (nonatomic, weak) MFOnBoardingViewController* onBoardingViewController;
@property (nonatomic, strong) NSArray<MFUserInfo*>* friends;
@property (nonatomic) BOOL showListOfGivenArtistsMode;
@end
