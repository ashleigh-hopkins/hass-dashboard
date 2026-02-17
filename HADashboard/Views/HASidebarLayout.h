#import <UIKit/UIKit.h>

@protocol HASidebarLayoutDelegate <UICollectionViewDelegate>

/// Return the height for an item at the given index path
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)layout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath
                itemWidth:(CGFloat)itemWidth;

@end

/// Two-column sidebar layout matching HA's hui-sidebar-view.
/// Section 0 = main cards, section 1 = sidebar cards.
/// Above 760px: main (flex-grow 2, max 1620px) and sidebar (flex-grow 1, max 380px) side by side.
/// Below 760px: single column, sidebar cards below main cards.
/// Compatible with iOS 9+ (UICollectionViewLayout subclass).
@interface HASidebarLayout : UICollectionViewLayout

@property (nonatomic, weak) id<HASidebarLayoutDelegate> delegate;

@end
