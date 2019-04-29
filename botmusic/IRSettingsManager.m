//
//  IRSettingsManager.m
//  botmusic
//
//  Created by Supervisor on 19.07.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "IRSettingsManager.h"

NSString *const kFacebookConnected=@"facebook_connected";
NSString *const kYoutubeConnected=@"youtube_connected";
NSString *const kSoundCloudConnected=@"soundcloud_connected";
NSString *const kSpotifyConnected=@"spotify_connected";
NSString *const kGroovesharkConnected=@"grooveshark_connected";
NSString *const kShazamConnected=@"shazam_connected";
NSString *const kTwitterSharing=@"twitter_sharing";
NSString *const kFacebookSharing=@"facebook_sharing";
NSString *const kPromptRemove=@"prompt_remove";

@implementation IRSettingsManager

+ (IRSettingsManager*)sharedInstance
{
    static IRSettingsManager *sharedInstance=nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedInstance=[IRSettingsManager new];
        [sharedInstance openSettings];
    });
    
    return sharedInstance;
}

#pragma mark - Open/Save methods

- (void)openSettings
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    
    if(![userDefaults objectForKey:kFacebookConnected])
    {
        [self setDefaultSettings];
    }
    else
    {
        self.isConnectFacebook=[[userDefaults objectForKey:kFacebookConnected]boolValue];
        self.isConnectSpotify=[[userDefaults objectForKey:kSpotifyConnected]boolValue];
        self.isConnectSoundCloud=[[userDefaults objectForKey:kSoundCloudConnected]boolValue];
        self.isSharingFacebook=[[userDefaults objectForKey:kFacebookSharing]boolValue];
        self.isSharingTwitter=[[userDefaults objectForKey:kTwitterSharing]boolValue];
        self.isPromptRemove=[[userDefaults objectForKey:kPromptRemove]boolValue];
    }
}

- (void)saveSettings
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    if (!_isConnectFacebook) {
        [self setDefaultSettings];
    }
    [userDefaults setObject:@(_isConnectFacebook) forKey:kFacebookConnected];
    [userDefaults setObject:@(_isConnectSpotify) forKey:kSpotifyConnected];
    [userDefaults setObject:@(_isConnectSoundCloud) forKey:kSoundCloudConnected];
    [userDefaults setObject:@(_isConnectShazam) forKey:kShazamConnected];
    [userDefaults setObject:@(_isSharingFacebook) forKey:kFacebookSharing];
    [userDefaults setObject:@(_isSharingTwitter) forKey:kTwitterSharing];
    [userDefaults setObject:@(_isPromptRemove) forKey:kPromptRemove];
    
    [userDefaults synchronize];
}

- (void)setDefaultSettings
{
    _isConnectSpotify=NO;
    _isConnectSoundCloud=NO;
    
    _isSharingFacebook=NO;
    _isSharingTwitter=NO;
}

#pragma mark - Compact properties

- (NSArray*)connectionValues
{
    return @[@(_isConnectSpotify),@(_isConnectSoundCloud)];
}

- (NSArray*)sharingValues
{
    return @[@(_isSharingFacebook),@(_isSharingTwitter)];
}

#pragma mark - Open/Save methods

- (BOOL)objectForKey:(NSString*)key
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    return [[userDefaults objectForKey:key]boolValue];
}

- (void)setObject:(BOOL)obj forKey:(NSString*)key
{
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@(obj) forKey:key];
    [userDefaults synchronize];
}

@end
