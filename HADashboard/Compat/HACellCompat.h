/// iOS 5-safe base classes for collection view cells and reusable views.
///
/// On iOS 5, UICollectionViewCell/UICollectionReusableView don't exist natively.
/// PSTCollectionView creates them dynamically at runtime, but too late for the
/// ObjC runtime to resolve classes that were compiled with these as superclasses.
///
/// PSUICollectionViewCell_ and PSUICollectionReusableView_ are compiled into the
/// binary (inheriting from PSTCollectionViewCell / PSTCollectionReusableView),
/// so they're always available at class load time.  On iOS 6+, PSTCollectionView
/// reparents them under the real UICollectionViewCell / UICollectionReusableView
/// via class_setSuperclass, so they're fully compatible with native UIKit.
///
/// Usage: inherit from HACollectionViewCellBase / HACollectionReusableViewBase
/// instead of UICollectionViewCell / UICollectionReusableView.

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"

#define HACollectionViewCellBase           PSUICollectionViewCell_
#define HACollectionReusableViewBase       PSUICollectionReusableView_
#define HACollectionViewLayoutBase             PSUICollectionViewLayout_
#define HACollectionViewFlowLayoutBase         PSUICollectionViewFlowLayout_
#define HACollectionViewLayoutAttributesBase   PSUICollectionViewLayoutAttributes_
