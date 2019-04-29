//
//  MFYoutubePlayer.m
//  botmusic
//
//  Created by Panda Systems on 4/2/15.
//
//

#import "MFYoutubePlayer.h"

@interface MFYoutubePlayer ()
@property (nonatomic, strong, readwrite) NSString *videoId;
@end

@implementation MFYoutubePlayer

- (void)loadVideoWithId:(NSString *)videoId {
    self.videoId = videoId;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stop];
}

@end
