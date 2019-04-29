//
//  NDMusicControl.h
//  PlayButtonExample
//
//  Created by Dzmitry Navak on 07/12/14.
//  Copyright (c) 2014 navakdzmitry. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, NDMusicConrolStateType) {
    NDMusicConrolStateTypeNotStarted,
    NDMusicConrolStateTypePaused,
    NDMusicConrolStateTypeLoading,
    NDMusicConrolStateTypePlaying,
    NDMusicConrolStateTypePlayed,
    NDMusicConrolStateTypeFailed
};

@interface NDMusicControl : UIControl

@property (nonatomic, strong) UIColor* mainColor;

- (void)changePlayState:(NDMusicConrolStateType)stateType;

@end
