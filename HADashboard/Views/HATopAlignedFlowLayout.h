#import <UIKit/UIKit.h>

/// A flow layout that top-aligns items within each row instead of centering them.
/// This ensures items with different heights (e.g. thermostat 9-col + vacuum 3-col)
/// align to the top of the row rather than being vertically centered.
@interface HATopAlignedFlowLayout : UICollectionViewFlowLayout
@end
