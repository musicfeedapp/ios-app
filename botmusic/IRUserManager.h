#import <Foundation/Foundation.h>
#import <KeychainItemWrapper.h>
#import "MFUserInfo+Behavior.h"
#import <Spotify/Spotify.h>
#import "AdditionalLoginViewController.h"

extern NSString* kUserInfoKey;
extern NSString* kAuthTokenItem;
extern NSString* kSpotifyDefaultsKey;

#define IS_FIRST_LOGIN @"ISFirstLogin"
#define IS_UNSIGNED_CREATED @"IS_UNSIGNED_CREATED"

@interface IRUserManager : NSObject<SPTAuthViewDelegate>

+ (IRUserManager*)sharedInstance;

@property (nonatomic, readonly, strong) SPTSession* spSession;
@property (nonatomic, strong) MFUserInfo* userInfo;
@property (nonatomic) NSInteger numberOfUnreadNotifications;
@property (nonatomic, weak) id<AdditionalLoginViewControllerDelegate> addLoginDelegate;
@property (nonatomic) BOOL isLoggingOut;

- (NSString*)fbToken;
- (BOOL)isLoggedIn;

- (void)loginBotmusicWithUser:(MFUserInfo*)user apiToken:(NSString*)apiToken;
- (void)loginSpotifyWithUserName:(NSString*)login password:(NSString*)password;
- (void)logout;

- (BOOL)isLoggedInSpotify;
- (void)loginInSpotify;
- (void)refreshSpotifySessionWithCallback:(void (^)(NSError*))callback;
- (NSURL*)spotifyCallbackURL;
- (void)saveSpotifySession:(SPTSession*)sesion;
- (SPTSession*)spotifySession;

- (BOOL)isFirstLogin;
- (void)setFirstLogin:(BOOL)value;

- (BOOL)isSwitchToAudioPromptShown;
- (void)setSwitchToAudioPromptShown:(BOOL)value;

-(NSDate *)lastTimelinesCheck;
-(void)setLastTimelinesCheck:(NSDate *)lastTimelinesCheck;

-(NSString *)lastSearchKeyword;
-(void)setLastSearchKeyword:(NSString *)keyword;

-(void)rejectedUnfollowPrompt;
-(void)acceptedUnfollowPrompt;
-(BOOL)showingUnfollowPromptsStopped;

- (void)createdUnsignedUserForThisPhone;
- (BOOL)isUnsignedUserCreatedforThisPhone;
- (void)downloadSuggestionsIfNeeded;
@end
