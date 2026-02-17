#import "HAPanelLayout.h"

@interface HAPanelLayout ()
@property (nonatomic, strong) UICollectionViewLayoutAttributes *panelAttributes;
@property (nonatomic, assign) CGSize cachedContentSize;
@end

@implementation HAPanelLayout

- (void)prepareLayout {
    [super prepareLayout];

    self.panelAttributes = nil;

    UICollectionView *cv = self.collectionView;
    if (!cv) return;

    NSInteger sectionCount = [cv numberOfSections];
    if (sectionCount == 0) {
        self.cachedContentSize = CGSizeZero;
        return;
    }

    NSInteger itemCount = [cv numberOfItemsInSection:0];
    if (itemCount == 0) {
        self.cachedContentSize = CGSizeZero;
        return;
    }

    // Panel: single item fills the full available width with no margins
    CGFloat width = cv.bounds.size.width;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];

    CGFloat height = cv.bounds.size.height; // default to full height
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:heightForItemAtIndexPath:itemWidth:)]) {
        height = [self.delegate collectionView:cv layout:self heightForItemAtIndexPath:indexPath itemWidth:width];
    }
    // Ensure at least the full viewport height
    height = MAX(height, cv.bounds.size.height);

    UICollectionViewLayoutAttributes *attr =
        [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    attr.frame = CGRectMake(0, 0, width, height);
    self.panelAttributes = attr;

    self.cachedContentSize = CGSizeMake(width, height);
}

- (CGSize)collectionViewContentSize {
    return self.cachedContentSize;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    if (self.panelAttributes && CGRectIntersectsRect(self.panelAttributes.frame, rect)) {
        return @[self.panelAttributes];
    }
    return @[];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.item == 0) {
        return self.panelAttributes;
    }
    return nil;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
