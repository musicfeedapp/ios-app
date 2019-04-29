//
//  NewSearchViewController.h
//  botmusic
//
//  Created by Panda Systems on 10/8/15.
//
//

#import "AbstractViewController.h"

@interface NewSearchViewController : AbstractViewController
- (void) reloadData;
@property (nonatomic) BOOL shouldNavigateToSuggestionsAfterViewLoaded;
@end
