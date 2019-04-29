//
//  IRSettingsManager.h
//  botmusic
//
//  Created by Supervisor on 19.07.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IRSettingsManager : NSObject

+(IRSettingsManager*)sharedInstance;

@property(nonatomic,assign)BOOL isConnectFacebook;
@property(nonatomic,assign)BOOL isConnectYoutube;
@property(nonatomic,assign)BOOL isConnectSoundCloud;
@property(nonatomic,assign)BOOL isConnectSpotify;
@property(nonatomic,assign)BOOL isConnectGrooveshark;
@property(nonatomic,assign)BOOL isConnectShazam;
@property(nonatomic,assign)BOOL isSharingFacebook;
@property(nonatomic,assign)BOOL isSharingTwitter;
@property(nonatomic,assign)BOOL isPromptRemove;

-(void)saveSettings;

-(NSArray*)connectionValues;
-(NSArray*)sharingValues;

@end
