//
//  CALayer+NDAnimationPersistence.m
//
//  Created by Dzmitry Navak on 07/12/14.
//  Copyright (c) 2014 navakdzmitry. All rights reserved.
//
//  Based on Matej Bukovinski CALayer+MBAnimationPersistence

#import <objc/runtime.h>
#import "CALayer+NDAnimationPersistence.h"
#import "UIKit/UIKit.h"


@interface NDPersistentAnimationContainer : NSObject
@property (nonatomic)       BOOL    isPaused;
@property (nonatomic, weak) CALayer *layer;
@property (nonatomic, copy) NSArray *persistentAnimationKeys;
@property (nonatomic, copy) NSDictionary *persistedAnimations;
- (id)initWithLayer:(CALayer *)layer;
@end


@interface CALayer (NDAnimationPersistencePrivate)
@property (nonatomic, strong) NDPersistentAnimationContainer *ND_animationContainer;
@end


@implementation CALayer (NDAnimationPersistence)

#pragma mark - Public

- (NSArray *)ND_persistentAnimationKeys {
    return self.ND_animationContainer.persistentAnimationKeys;
}

- (void)setND_persistentAnimationKeys:(NSArray *)persistentAnimationKeys {
    NDPersistentAnimationContainer *container = [self ND_animationContainer];
    if (!container) {
        container = [[NDPersistentAnimationContainer alloc] initWithLayer:self];
        [self ND_setAnimationContainer:container];
    }
    container.persistentAnimationKeys = persistentAnimationKeys;
}

- (void)ND_setCurrentAnimationsPersistent {
    self.ND_persistentAnimationKeys = [self animationKeys];
}

- (void)ND_removeCurrentAnimationsPersistent
{
    self.ND_persistentAnimationKeys = @[];
}

#pragma mark - Associated objects

- (void)ND_setAnimationContainer:(NDPersistentAnimationContainer *)animationContainer {
    objc_setAssociatedObject(self, @selector(ND_animationContainer), animationContainer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NDPersistentAnimationContainer *)ND_animationContainer {
    return objc_getAssociatedObject(self, @selector(ND_animationContainer));
}

#pragma mark - Pause and resume

// TechNote QA1673 - How to pause the animation of a layer tree
// @see https://developer.apple.com/library/ios/qa/qa1673/_index.html

- (void)ND_pauseLayer {
    [self ND_animationContainer].isPaused = YES;
    [self ND_pauseLayerTemporarily];
}

- (void)ND_pauseLayerTemporarily {
    CFTimeInterval pausedTime = [self convertTime:CACurrentMediaTime() fromLayer:nil];
    self.speed = 0.0;
    self.timeOffset = pausedTime;
}

- (void)ND_resumeLayer {
    if ([self ND_animationContainer].isPaused) {
        [self ND_animationContainer].isPaused = NO;
        CFTimeInterval pausedTime = [self timeOffset];
        self.speed = 1.0;
        self.timeOffset = 0.0;
        self.beginTime = 0.0;
        CFTimeInterval timeSincePause = [self convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
        self.beginTime = timeSincePause;
    }
}

@end

@implementation NDPersistentAnimationContainer

#pragma mark - Lifecycle

- (id)initWithLayer:(CALayer *)layer {
    self = [super init];
    if (self) {
        _layer = layer;
    }
    return self;
}

- (void)dealloc {
    [self unregisterFromAppStateNotifications];
}

#pragma mark - Keys

- (void)setPersistentAnimationKeys:(NSArray *)persistentAnimationKeys {
    if (persistentAnimationKeys != _persistentAnimationKeys) {
        if (!_persistentAnimationKeys) {
            [self registerForAppStateNotifications];
        } else if (!persistentAnimationKeys) {
            [self unregisterFromAppStateNotifications];
        }
        _persistentAnimationKeys = persistentAnimationKeys;
    }
}

#pragma mark - Persistence

- (void)persistLayerAnimationsAndPause {
    CALayer *layer = self.layer;
    if (!layer) {
        return;
    }
    NSMutableDictionary *animations = [NSMutableDictionary new];
    for (NSString *key in self.persistentAnimationKeys) {
        CAAnimation *animation = [layer animationForKey:key];
        if (animation) {
            animations[key] = animation;
        }
    }
    if (animations.count > 0) {
        self.persistedAnimations = animations;
        if (!_isPaused) {
            [layer ND_pauseLayerTemporarily];
        }
    }
}

- (void)restoreLayerAnimationsAndResume {
    CALayer *layer = self.layer;
    if (!layer) {
        return;
    }
    [self.persistedAnimations enumerateKeysAndObjectsUsingBlock:^(NSString *key, CAAnimation *animation, BOOL *stop) {
        [layer addAnimation:animation forKey:key];
    }];
    if (self.persistedAnimations.count > 0) {
        if (!_isPaused) {
            [layer ND_resumeLayer];
        }
    }
    self.persistedAnimations = nil;
}

#pragma mark - Notifications

- (void)registerForAppStateNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)unregisterFromAppStateNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidEnterBackground {
    [self persistLayerAnimationsAndPause];
}

- (void)applicationWillEnterForeground {
    [self restoreLayerAnimationsAndResume];
}

@end
