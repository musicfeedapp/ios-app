//
//  CustomAKSegmentControl.h
//  botmusic
//
//  Created by Dzionis Brek on 08.04.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import "AKSegmentedControl.h"

@protocol CustomAKSCDelegate <NSObject>
- (void)segmentControlTaped;
@end

@interface CustomAKSegmentControl : AKSegmentedControl

@property (nonatomic, assign) id <CustomAKSCDelegate> customAKSCDelegate;

@end
