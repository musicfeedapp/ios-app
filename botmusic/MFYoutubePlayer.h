//
//  MFYoutubePlayer.h
//  botmusic
//
//  Created by Panda Systems on 4/2/15.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MFYoutubePlayerState) {
    MFYoutubePlayerStatePlaying,
    MFYoutubePlayerStatePaused,
    MFYoutubePlayerStateLoading,
    MFYoutubePlayerStateEnded
};

@class MFYoutubePlayer;

@protocol MFYoutubePlayerDelegate <NSObject>

@required
- (void)youtubePlayerDidBecomeReady:(MFYoutubePlayer *)youtubePlayer;
- (void)youtubePlayer:(MFYoutubePlayer *)youtubePlayer didChangeToState:(MFYoutubePlayerState)state;
- (void)youtubePlayer:(MFYoutubePlayer *)youtubePlayer didReceiveError:(NSError *)error;

@end

@interface MFYoutubePlayer : NSObject

@property (nonatomic, weak) id<MFYoutubePlayerDelegate> delegate;

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong, readonly) NSString *videoId;

@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSTimeInterval currentTime;

- (void)loadVideoWithId:(NSString *)videoId;
- (void)play;
- (void)pause;
- (void)stop;
- (void)seekToSeconds:(float)seekOffset;

@end
