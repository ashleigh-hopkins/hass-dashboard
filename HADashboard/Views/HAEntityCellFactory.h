#import <UIKit/UIKit.h>

@class HAEntity;

@interface HAEntityCellFactory : NSObject

/// Register all entity cell classes with a collection view
+ (void)registerCellClassesWithCollectionView:(UICollectionView *)collectionView;

/// Get the reuse identifier for a given entity (based on its domain)
+ (NSString *)reuseIdentifierForEntity:(HAEntity *)entity;

/// Get the reuse identifier considering card type from Lovelace config.
/// cardType overrides domain-based lookup for specific card types (entities, thermostat).
+ (NSString *)reuseIdentifierForEntity:(HAEntity *)entity cardType:(NSString *)cardType;

@end
