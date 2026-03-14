/// iOS 5-safe base classes for collection view cells and reusable views.
///
/// On iOS 5 (armv7), UICollectionViewCell etc don't exist natively.
/// PSTCollectionView creates them dynamically at runtime, but too late for the
/// ObjC runtime to resolve classes compiled with these as superclasses.
///
/// On armv7 we use PSUICollectionViewCell_ (compiled into the binary, always
/// available at class load time). On arm64 (iOS 8+) we use the real UIKit
/// classes directly — class_setSuperclass is unreliable on modern runtimes.

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"

#if defined(__arm__) && !defined(__aarch64__)
  // armv7 (iOS 5 target): use PSTCollectionView's intermediary classes
  #define HACollectionViewCellBase           PSUICollectionViewCell_
  #define HACollectionReusableViewBase       PSUICollectionReusableView_
  #define HACollectionViewLayoutBase         PSUICollectionViewLayout_
  #define HACollectionViewFlowLayoutBase     PSUICollectionViewFlowLayout_
  #define HACollectionViewLayoutAttributesBase PSUICollectionViewLayoutAttributes_
#else
  // arm64 (iOS 8+): UICollectionView exists natively, use real UIKit classes
  #define HACollectionViewCellBase           UICollectionViewCell
  #define HACollectionReusableViewBase       UICollectionReusableView
  #define HACollectionViewLayoutBase         UICollectionViewLayout
  #define HACollectionViewFlowLayoutBase     UICollectionViewFlowLayout
  #define HACollectionViewLayoutAttributesBase UICollectionViewLayoutAttributes
#endif
