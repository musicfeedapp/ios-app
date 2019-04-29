//
//  MFRecognitionManager.m
//  botmusic
//
//  Created by Panda Systems on 7/20/15.
//
//

#import "MFRecognitionManager.h"
#define CLIENTID @"456960"
#define CLIENTIDTAG @"5E15278B6238BE89093B4EA7045FDA94"

@implementation MFRecognitionManager

+ (instancetype)sharedInstance
{
    static MFRecognitionManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void) initializeSDK{
    if (!self.initialized){
        NSString* gnsdkLicenseFilename = @"license.txt";
        NSError* error = nil;
        NSString* resourcePath = [[NSBundle mainBundle] pathForResource:gnsdkLicenseFilename ofType: nil];
        NSString* licenseString = [NSString stringWithContentsOfFile: resourcePath
                                                            encoding: NSUTF8StringEncoding
                                                               error: &error];
        self.gnManager = [[GnManager alloc] initWithLicense: licenseString licenseInputMode:
                          kLicenseInputModeString];
        
        self.gnUserStore = [[GnUserStore alloc] init];
        self.gnUser = [[GnUser alloc] initWithGnUserStoreDelegate: self.gnUserStore
                                                         clientId: CLIENTID
                                                        clientTag: CLIENTIDTAG applicationVersion: @"1.0.0.0"];
        self.initialized = YES;
        if (!self.mMic) {
            self.mMic = [[GnMic alloc] initWithSampleRate:44100 bitsPerChannel:16 numberOfChannels:1];
        }
        if (!self.mAdapter) {
            self.mAdapter = [[GnAudioVisualizeAdapter alloc] initWithAudioSource:self.mMic audioVisualizerDelegate:self];
        }
        if (!self.mMusicAudio) {
            self.mMusicAudio = [[GnMusicIdStream alloc] initWithGnUser:self.gnUser preset:kPresetMicrophone musicIdStreamEventsDelegate:self];
        }
        
        self.internalQueue = dispatch_queue_create("gnsdk.TaskQueue", NULL);
    }
    
}

- (void) identify{
    if (playerManager.playing) {
        [playerManager pauseTrack];
    }
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
                [self initializeSDK];

                dispatch_async(self.internalQueue, ^{
                    NSError *error = nil;
                    [self.mMusicAudio audioProcessStartWithAudioSource:self.mAdapter error:&error];


                    if (error) {
                        NSLog(@"[gracenote] music id stream start with audot source produced error");
                    }
                });

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSLog(@"[gracenote] started identify");

                    NSError *error = nil;
                    [self.mMusicAudio identifyAlbumAsync:&error];

                    if (error) {
                        NSLog(@"[gracenote] music audio identify produced error");
                    }
                });
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Recording not permitted" message:@"Please go to settings and allow Musicfeed to record sound" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Go to settings", nil] show];
                [self.delegate idEndedWithTrackName:nil artist:nil error:[[NSError alloc] initWithDomain:@"com.musicfeed.app.recognition" code:2 userInfo:@{NSLocalizedDescriptionKey: @"Mic access denied"}]];
            });
        }
    }];

}

-(void) musicIdStreamProcessingStatusEvent: (GnMusicIdStreamProcessingStatus)status cancellableDelegate: (id <GnCancellableDelegate>)canceller{
    NSLog(@"%lo",status);
}


-(void) musicIdStreamIdentifyingStatusEvent: (GnMusicIdStreamIdentifyingStatus)status cancellableDelegate: (id <GnCancellableDelegate>)canceller{
    NSLog(@"%lo",status);
}


-(void) musicIdStreamAlbumResult: (GnResponseAlbums*)result cancellableDelegate: (id <GnCancellableDelegate>)canceller{
    //[self stopAudioProcess];

    if (!result.albums.count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.delegate){
                [self.delegate idEndedWithTrackName:nil artist:nil error:[[NSError alloc] initWithDomain:@"com.musicfeed.app.recognition" code:1 userInfo:@{NSLocalizedDescriptionKey: @"No results found"}]];
            }
        });
    } else {
    
        GnAlbum* album = result.albums.allObjects.firstObject;
        GnTrackEnumerator *tracksMatched  = [album tracksMatched];
        NSString *albumArtist = [[[album artist] name] display];
        NSString *albumTitle = [[album title] display];
        NSString *albumGenre = [album genre:kDataLevel_1] ;
        NSString *albumID = [NSString stringWithFormat:@"%@-%@", [album tui], [album tuiTag]];
        GnExternalId *externalID  =  nil;
        if ([album externalIds] && [[album externalIds] allObjects].count)
            externalID = (GnExternalId *) [[album externalIds] nextObject];
        
        NSString *albumXID = [externalID source];
        NSString *albumYear = [album year];
        NSString *albumTrackCount = [NSString stringWithFormat:@"%lu", (unsigned long)[album trackCount]];
        NSString *albumLanguage = [album language];
        
        /* Get CoverArt */
        GnContent *coverArtContent = [album coverArt];
        GnAsset *coverArtAsset = [coverArtContent asset:kImageSizeSmall];
        NSString *URLString = [NSString stringWithFormat:@"http://%@", [coverArtAsset url]];
        
        GnContent *artistImageContent = [[[album artist] contributor] image];
        GnAsset *artistImageAsset = [artistImageContent asset:kImageSizeSmall];
        NSString *artistImageURLString = [NSString stringWithFormat:@"http://%@", [artistImageAsset url]];
        
        GnContent *artistBiographyContent = [[[album artist] contributor] biography];
        NSString *artistBiographyURLString = [NSString stringWithFormat:@"http://%@", [[[artistBiographyContent assets] nextObject] url]];
        
        GnContent *albumReviewContent = [album review];
        NSString *albumReviewURLString = [NSString stringWithFormat:@"http://%@", [[[albumReviewContent assets] nextObject] url]];
        
        [tracksMatched enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.delegate){
                    [self.delegate idEndedWithTrackName:[[((GnTrack*)obj) title] display] artist:albumArtist error:nil];
                }
            });
            *stop = YES;
        }];
    }
}


-(void) musicIdStreamIdentifyCompletedWithError: (NSError*)completeError{
    //[self stopAudioProcess];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate){
            [self.delegate idEndedWithTrackName:nil artist:nil error:completeError];
        }
    });

}

-(void) stopAudioProcess{
    [self.mMusicAudio audioProcessStop:nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    });
}

-(void) statusEvent: (GnStatus)status percentComplete: (NSUInteger)percentComplete bytesTotalSent: (NSUInteger)bytesTotalSent bytesTotalReceived: (NSUInteger)bytesTotalReceived cancellableDelegate: (id <GnCancellableDelegate>)canceller{
    
}

-(void) RMSDidUpdateByValue:(float) value{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate RMSDidUpdateByValue:value];
    });
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}
@end
