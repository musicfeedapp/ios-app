//
//  SuggestionsViewController.h
//  botmusic
//
//  Created by Supervisor on 12.05.14.
//  Copyright (c) 2014 wellnuts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFQuiltLayout.h"
#import "ArtistCell.h"
#import "IRSuggestion.h"
#import "MFSideMenu.h"
#import "AbstractViewController.h"

@interface SuggestionsViewController : AbstractViewController<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,RFQuiltLayoutDelegate,ArtistCellDelegate>

@property(nonatomic,assign)BOOL isRedirectTo;

@end
