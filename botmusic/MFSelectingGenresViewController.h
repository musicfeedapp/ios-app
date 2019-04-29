//
//  MFSelectingGenresViewController.h
//  botmusic
//
//  Created by Panda Systems on 8/24/15.
//
//

#import <UIKit/UIKit.h>

@protocol MFSelectingGenresSearchDelegate <NSObject>

-(void) startSearch;
-(void) finishSearch;

@end

@interface MFSelectingGenresViewController : UIViewController
@property(nonatomic, weak) id<MFSelectingGenresSearchDelegate> genresSearchDelegate;
- (void) placeGenresFilteredByString:(NSString*)string onView:(UIView*)view;
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;
@property (nonatomic) BOOL isSettingsMode;
@end
