//
//  MFScrollingChildDelegate.h
//  botmusic
//
//  Created by Dzmitry Navak on 20/02/15.
//
//

#ifndef botmusic_MFScrollingChildDelegate_h
#define botmusic_MFScrollingChildDelegate_h

@protocol MFScrollingChildDelegate <NSObject>

@required
-(void) scrollViewDidScroll:(UIScrollView *)scrollView;
@end

#endif
