//
//  MFTrackItem+Behavior.h
//  botmusic
//
//  Created by Panda Systems on 4/25/15.
//
//

#import "MFTrackItem.h"

typedef NS_ENUM(NSUInteger, IRTrackItemState) {
    IRTrackItemStateNotStarted,
    IRTrackItemStatePaused,
    IRTrackItemStateLoading,
    IRTrackItemStatePlaying,
    IRTrackItemStatePlayed,
    IRTrackItemStateFailed
};

@interface MFTrackItem (Behavior) <NSCoding>

extern NSString* feedTypeYoutube;
extern NSString* feedTypeSpotify;
extern NSString* feedTypeSoundcloud;
extern NSString* feedTypeGrooveshark;
extern NSString* feedTypeShazam;
extern NSString* feedTypeMixcloud;
extern NSString* feedTypeAll;

-(IRTrackItemState)trackState;
-(void) setTrackState:(IRTrackItemState) state;

+ (NSDateFormatter*)dateFormatter;

- (void)configureWithDictionary: (NSDictionary*)dictionaryData;

- (NSString*)shareText;
- (NSString*)shareLink;
- (BOOL)isHaveVideo;

-(void)likeTrackItem;
-(void)dislikeTrackItem;

-(void)addComment;
-(void)removeComment;

-(BOOL)isLightColor;

-(NSString*)videoID;

-(BOOL)isSpotifyTrack;
-(BOOL)isSoundcloudTrack;
- (BOOL)isMixcloudTrack;
-(BOOL)isYoutubeTrack;

@end
