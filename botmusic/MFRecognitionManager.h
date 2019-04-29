//
//  MFRecognitionManager.h
//  botmusic
//
//  Created by Panda Systems on 7/20/15.
//
//

#import <Foundation/Foundation.h>
#import <GnSDKObjC/Gn.h>
#import "GnAudioVisualizeAdapter.h"

@protocol MFRecognitionManagerDelegate <NSObject>

@required

- (void)idEndedWithTrackName:(NSString*)name artist:(NSString*)artist error:(NSError*)error;
- (void)RMSDidUpdateByValue:(float) value;
@end


@interface MFRecognitionManager : NSObject <GnMusicIdStreamEventsDelegate, GnAudioVisualizerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) GnManager *gnManager;
@property (nonatomic, strong) GnUser *gnUser;
@property (nonatomic, strong) GnUserStore *gnUserStore;
@property (nonatomic, strong) GnMic *mMic;
@property (nonatomic, strong) GnAudioVisualizeAdapter* mAdapter;
@property (nonatomic, strong) GnMusicIdStream *mMusicAudio;
@property (nonatomic) BOOL initialized;
@property dispatch_queue_t internalQueue;
@property (nonatomic, weak) id<MFRecognitionManagerDelegate> delegate;

+ (instancetype)sharedInstance;
- (void) initializeSDK;
- (void) identify;
- (void) stopAudioProcess;

@end
