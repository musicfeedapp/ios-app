  //
//  UserManager.m
//
//  Created by Илья Романеня on 01.10.13.
//  Copyright (c) 2013 Илья Романеня. All rights reserved.
//

#import "IRUserManager.h"
#import "MFConstants.h"
#import "MFNotificationManager.h"
#import "MagicalRecord/MagicalRecord.h"
#import "MenuViewController.h"

NSString* kUserInfoKey = @"UserInfo";
NSString* kAuthTokenItem = @"AuthToken";
  NSString* kSessionUserDefaultsKey = @"SpotifySession";
NSString *const kLastTimelinesCheck=@"lastTimelinesCheck";
NSString *const kLastSearchKeyword=@"lastSearchKeyword";
NSString *const kNumberOfUnfollowPromptsRejected=@"numberOfUnfollowPromptsRejected";

@implementation IRUserManager
{
    KeychainItemWrapper* fbTokenItem;
}


+ (IRUserManager *)sharedInstance
{
    static IRUserManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[IRUserManager alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    if (self = [super init])
    {
        NSLogExt();
        fbTokenItem = [[KeychainItemWrapper alloc] initWithIdentifier:kAuthTokenItem accessGroup:nil];
        //[self createSPSessionError:nil];
    }
    
    return self;
}

- (MFUserInfo *)userInfo
{
    return [MFUserInfo MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"isAnotherUser == NO"]];
}

- (void)setUserInfo:(MFUserInfo *)userInfo
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:userInfo] forKey:kUserInfoKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [MFNotificationManager postUserInfoUpdatedNotification:userInfo];
}

- (BOOL)isLoggedIn
{
    //return (([[fbTokenItem objectForKey:(id)CFBridgingRelease(kSecValueData)] length] != 0) && (self.userInfo));
    return ([[[NSUserDefaults standardUserDefaults] objectForKey:kAuthTokenItem] length] != 0 && (self.userInfo));
}

- (NSString*)fbToken
{
    //return [fbTokenItem objectForKey:(id)CFBridgingRelease(kSecValueData)];
    return [[NSUserDefaults standardUserDefaults] objectForKey:kAuthTokenItem];
}

- (void)loginBotmusicWithUser:(MFUserInfo*)user apiToken:(NSString*)apiToken
{
    NSLogExt();

    MFUserInfo* userInfoOld = [dataManager getMyUserInfoInContext];
    userInfoOld.isAnotherUser = YES;
    user.isAnotherUser = NO;
    [dataManager clearFeed];
    [dataManager clearNotifications];

    self.userInfo = user;
    
    //[fbTokenItem setObject:apiToken forKey:(id)CFBridgingRelease(kSecValueData)];
    [[NSUserDefaults standardUserDefaults] setObject:apiToken forKey:kAuthTokenItem];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"MFUserLoggedIn" object:nil];

}

- (void)createdUnsignedUserForThisPhone{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:IS_UNSIGNED_CREATED];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isUnsignedUserCreatedforThisPhone{
    return [[NSUserDefaults standardUserDefaults]objectForKey:IS_UNSIGNED_CREATED]==nil?NO:YES;
}

- (void)logout
{
    NSLogExt();
    //[fbTokenItem resetKeychainItem];

    [playerManager stopTrack];
    [playerManager removeAllTracks];
    [saver clear];
    MFUserInfo* userInfoOld = [dataManager getMyUserInfoInContext];
    userInfoOld.isAnotherUser = YES;
    //[dataManager clearFeed];
    [dataManager clearNotifications];

    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kAuthTokenItem];
    [[NSUserDefaults standardUserDefaults] synchronize];

    
    settingsManager.isConnectFacebook = NO;
    [settingsManager saveSettings];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserInfoKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"MFUserLoggedOut" object:nil];

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
}
-(BOOL)isFirstLogin
{
    return [[NSUserDefaults standardUserDefaults]objectForKey:IS_FIRST_LOGIN]==nil?YES:NO;
}
-(void)setFirstLogin:(BOOL)value
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:value] forKey:IS_FIRST_LOGIN];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isSwitchToAudioPromptShown{
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"isSwitchToAudioPromptShown"]==nil?NO:YES;

}

- (void)setSwitchToAudioPromptShown:(BOOL)value{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:value] forKey:@"isSwitchToAudioPromptShown"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

#pragma mark - Spotify
- (BOOL)isLoggedInSpotify
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    id storedCredentials = [defaults valueForKey:kSessionUserDefaultsKey];
    
    return (storedCredentials!= nil);
}
- (void)loginInSpotify
{
    NSURL *loginURL = [SPTAuth loginURLForClientId:kMFSpotifyClientID
                                withRedirectURL:[NSURL URLWithString:kMFSpotifyRedirectURL]
                                         scopes:@[SPTAuthStreamingScope]
                                   responseType:@"token"];
    
//    NSURL *loginURL = [auth loginURLForClientId:kMFSpotifyClientID
//                            declaredRedirectURL:[NSURL URLWithString:kMFSpotifyRedirectURL]
//                                         scopes:@[SPTAuthStreamingScope]];
    
    //[[UIApplication sharedApplication] openURL:loginURL];
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
        [SPTAuth defaultInstance].redirectURL = [NSURL URLWithString:kMFSpotifyRedirectURL];
        [SPTAuth defaultInstance].requestedScopes = @[SPTAuthStreamingScope];
        [SPTAuth defaultInstance].clientID = kMFSpotifyClientID;
        SPTAuthViewController *authvc = [SPTAuthViewController authenticationViewController];
        authvc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        authvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        authvc.delegate = self;
        UIViewController* topVC = [((AppDelegate*)[[UIApplication sharedApplication] delegate]) topViewController];
//        if ([topVC isKindOfClass:[AbstractViewController class]]) {
//            topVC = [(AbstractViewController*)topVC container];
//        }
        topVC.modalPresentationStyle = UIModalPresentationCurrentContext;
        topVC.definesPresentationContext = YES;
        [topVC presentViewController:authvc animated:NO completion:nil];
    } else {
        [playerManager playbackNotStarted:nil delay:NO];
    }
    
}

#pragma mark - SPTAuthViewControllerDelegate methods


- (void) authenticationViewController:(SPTAuthViewController *)authenticationViewController didLoginWithSession:(SPTSession *)session{
    settingsManager.isConnectSpotify = YES;
    [settingsManager saveSettings];
    [userManager saveSpotifySession:session];
    [playerManager playTrack];

}

- (void) authenticationViewController:(SPTAuthViewController *)authenticationViewController didFailToLogin:(NSError *)error{
    [playerManager playbackNotStarted:nil];
}

- (void) authenticationViewControllerDidCancelLogin:(SPTAuthViewController *)authenticationViewController{
    [playerManager playbackNotStarted:nil];

}

- (void)refreshSpotifySessionWithCallback:(void (^)(NSError* error))callback
{
    SPTSession *session=[userManager spotifySession];
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    [auth renewSession:session
              callback:^(NSError *error, SPTSession *session) {
                  if (error == nil) {
                      [userManager saveSpotifySession:session];
                  }
                  callback(error);
                  
                  //[self enableAudioPlaybackWithSession:session];
              }];
}

- (void)saveSpotifySession:(SPTSession *)session
{
    NSData *sessionData = [NSKeyedArchiver archivedDataWithRootObject:session];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:sessionData forKey:kSessionUserDefaultsKey];
    [userDefaults synchronize];
}

- (SPTSession*)spotifySession
{
    id sessionData = [[NSUserDefaults standardUserDefaults] objectForKey:kSessionUserDefaultsKey];
    SPTSession *session = sessionData ? [NSKeyedUnarchiver unarchiveObjectWithData:sessionData] : nil;
    
    return session;
}

-(NSDate *)lastTimelinesCheck
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSData *data=[userDefaults objectForKey:kLastTimelinesCheck];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
}
-(void)setLastTimelinesCheck:(NSDate *)lastTimelinesCheck
{
    NSUserDefaults *userDefauls=[NSUserDefaults standardUserDefaults];
    NSData *data=[NSKeyedArchiver archivedDataWithRootObject:lastTimelinesCheck];
    [userDefauls setObject:data forKey:kLastTimelinesCheck];
    [userDefauls synchronize];
}

-(NSString *)lastSearchKeyword
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:kLastSearchKeyword];
    
}
-(void)setLastSearchKeyword:(NSString *)keyword
{
    NSUserDefaults *userDefauls=[NSUserDefaults standardUserDefaults];
    [userDefauls setObject:keyword forKey:kLastSearchKeyword];
    [userDefauls synchronize];
}

-(void)rejectedUnfollowPrompt{
    NSUserDefaults *userDefauls=[NSUserDefaults standardUserDefaults];
    NSNumber* number = [userDefauls objectForKey:kNumberOfUnfollowPromptsRejected];
    if(!number){
        number = @0;
    }
    
    [userDefauls setObject:@([number intValue]+1) forKey:kNumberOfUnfollowPromptsRejected];
    [userDefauls synchronize];
}

-(void)acceptedUnfollowPrompt{
    NSUserDefaults *userDefauls=[NSUserDefaults standardUserDefaults];
    
    [userDefauls setObject:@0 forKey:kNumberOfUnfollowPromptsRejected];
    [userDefauls synchronize];
}

-(BOOL)showingUnfollowPromptsStopped{
    NSUserDefaults *userDefauls=[NSUserDefaults standardUserDefaults];
    NSNumber* number = [userDefauls objectForKey:kNumberOfUnfollowPromptsRejected];
    if(!number){
        number = @0;
    }
    return [number intValue]>9;
}
#pragma mark - Soundcloud

#pragma mark - Facebook
- (void)fbDidLogout
{
    NSLogExt(@"Logged out of facebook");
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        NSString* domainName = [cookie domain];
        NSRange domainRange = [domainName rangeOfString:@"facebook"];
        if(domainRange.length > 0)
        {
            [storage deleteCookie:cookie];
        }
    }
}

- (void)downloadSuggestionsIfNeeded{

    MFUserInfo* userInfo;
    if (userManager.isLoggedIn) {
        userInfo = userManager.userInfo;
    } else {
        userInfo = dataManager.getAnonUserInfo;
    }

    if (userInfo.suggestions.count) {
        return;
    }

    BOOL anonymousRequest = !userManager.isLoggedIn;
    [[IRNetworkClient sharedInstance]
     getSuggestionsFilteredWithEmail:userManager.userInfo.email
     token:[userManager fbToken]
     filterType:nil
     successBlock:^(NSDictionary *suggestionArray) {
         NSArray* rawSuggestions = suggestionArray[@"artists"];

         NSArray* suggestions = [dataManager processSuggestions:rawSuggestions];

         NSArray* trendingArtists = [dataManager convertAndAddSuggestionItemsToDatabase: suggestionArray[@"trending_artists"]];

         NSArray* suggestionTracks = [dataManager convertAndAddTracksToDatabase:suggestionArray[@"trending_tracks"]];

         if (userManager.isLoggedIn && !anonymousRequest) {
             userManager.userInfo.suggestions = [NSOrderedSet orderedSetWithArray:suggestions];
             userManager.userInfo.trendingArtists = [NSOrderedSet orderedSetWithArray:trendingArtists];
             userManager.userInfo.trendingTracks = [NSOrderedSet orderedSetWithArray:suggestionTracks];
         } else if (!userManager.isLoggedIn && anonymousRequest){
             [dataManager getAnonUserInfo].suggestions = [NSOrderedSet orderedSetWithArray:suggestions];
             [dataManager getAnonUserInfo].trendingArtists = [NSOrderedSet orderedSetWithArray:trendingArtists];
             [dataManager getAnonUserInfo].trendingTracks = [NSOrderedSet orderedSetWithArray:suggestionTracks];
         }

         [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:nil];

         [[NSNotificationCenter defaultCenter] postNotificationName:@"MFSuggestionsLoadedAfterLogin" object:nil];


     } failureBlock:^(NSString *errorMessage) {
         
     }];
}
@end
