//
//  CALayer+NDAnimationPersistence.h
//
//  Created by Dzmitry Navak on 07/12/14.
//  Copyright (c) 2014 navakdzmitry. All rights reserved.
//
//  Based on Matej Bukovinski CALayer+MBAnimationPersistence

#import <QuartzCore/QuartzCore.h>


@interface CALayer (NDAnimationPersistence)

/**
 Animation keys for animations that should be persisted.
 Inspect the `animationKeys` array to find valid keys for your layer.
 
 `CAAnimation` instances associated with the provided keys will be copied and held onto,
 when the applications enters background mode and restored when exiting background mode.
 
 Set to `nil`to disable persistance.
 */
@property (nonatomic, strong) NSArray *ND_persistentAnimationKeys;

/** Set all current `animationKeys` as persistent. */
- (void)ND_setCurrentAnimationsPersistent;
- (void)ND_removeCurrentAnimationsPersistent;
/** Pause layer and prevert resuming */
- (void)ND_pauseLayer;
- (void)ND_resumeLayer;

@end
