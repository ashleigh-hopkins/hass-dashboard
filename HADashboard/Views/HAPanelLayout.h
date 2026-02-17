#import <UIKit/UIKit.h>

@protocol HAPanelLayoutDelegate <UICollectionViewDelegate>

/// Return the height for the single panel item
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)layout
 heightForItemAtIndexPath:(NSIndexPath *)indexPath
                itemWidth:(CGFloat)itemWidth;

@end

/// Single-card full-bleed layout for HA panel view type.
/// Renders only the first card with no margins, no border-radius, no shadow.
/// Compatible with iOS 9+ (UICollectionViewLayout subclass).
@interface HAPanelLayout : UICollectionViewLayout

@property (nonatomic, weak) id<HAPanelLayoutDelegate> delegate;

@end
