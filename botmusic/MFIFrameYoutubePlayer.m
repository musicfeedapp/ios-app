//
//  MFIFrameYoutubePlayer.m
//  botmusic
//
//  Created by Panda Systems on 4/2/15.
//
//

#import "MFIFrameYoutubePlayer.h"
#import "YTPlayerView.h"

@interface MFIFrameYoutubePlayer () <YTPlayerViewDelegate>
@property (nonatomic, strong, readonly) YTPlayerView *videoPlayerView;
@end

@implementation MFIFrameYoutubePlayer

#pragma mark - Properties

- (NSTimeInterval)duration {
    return self.videoPlayerView.duration;
}

- (NSTimeInterval)currentTime {
    return self.videoPlayerView.currentTime;
}

#pragma mark - Player Actions

- (void)loadVideoWithId:(NSString *)videoId {
    [super loadVideoWithId:videoId];
    
    if (!self.videoPlayerView.delegate) {
        self.videoPlayerView.delegate = self;
    }
    if([UIApplication sharedApplication].applicationState == UIApplicationStateActive){
        [self.videoPlayerView loadWithVideoId:videoId];
    } else {
        [playerManager playbackNotStarted:nil delay:NO];
    }
    
}

- (void)play {
    [self.videoPlayerView playVideo];
}

- (void)pause {
    [self.videoPlayerView pauseVideo];
}

- (void)stop {
    [self.videoPlayerView stopVideo];
}

- (void)seekToSeconds:(float)seekOffset {
    [self.videoPlayerView seekToSeconds:seekOffset allowSeekAhead:YES];
}

#pragma mark - Internal properties

- (YTPlayerView *)videoPlayerView {
    if ([self.containerView isKindOfClass:[YTPlayerView class]]) {
        return (YTPlayerView *)self.containerView;
    }
    return nil;
}

#pragma mark - YTPlayerViewDelegate methods

- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView {
    if (self.delegate) {
        [self.delegate youtubePlayerDidBecomeReady:self];
    }
}

- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state {
    switch (state) {
        case kYTPlayerStateUnstarted:
            if (self.delegate) {
                [self.delegate youtubePlayer:self didReceiveError:nil];
            }
        case kYTPlayerStateEnded:
            if (self.delegate) {
                [self.delegate youtubePlayer:self didChangeToState:MFYoutubePlayerStateEnded];
            }
            break;
        case kYTPlayerStatePlaying:
            if (self.delegate) {
                [self.delegate youtubePlayer:self didChangeToState:MFYoutubePlayerStatePlaying];
            }
            break;
        case kYTPlayerStatePaused:
            if (self.delegate) {
                [self.delegate youtubePlayer:self didChangeToState:MFYoutubePlayerStatePaused];
            }
            break;
        case kYTPlayerStateBuffering:
            if (self.delegate) {
                [self.delegate youtubePlayer:self didChangeToState:MFYoutubePlayerStateLoading];
            }
            break;
        default:
            break;
    }
}

- (void)playerView:(YTPlayerView *)playerView receivedError:(YTPlayerError)error {
    if (self.delegate) {
        [self.delegate youtubePlayer:self didReceiveError:nil];
    }
}

- (void)playerView:(YTPlayerView *)playerView didChangeToQuality:(YTPlaybackQuality)quality {
    // TODO: implement
}

@end
