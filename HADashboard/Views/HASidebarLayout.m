#import "HASidebarLayout.h"

/// HA sidebar layout constants
static const CGFloat kSidebarCollapseWidth = 760.0;
static const CGFloat kMainMaxWidth = 1620.0;
static const CGFloat kSidebarMaxWidth = 380.0;
static const CGFloat kSidebarSpacing = 8.0;  // gap between main and sidebar columns
static const CGFloat kCardSpacing = 8.0;     // vertical gap between cards
static const CGFloat kContentPadding = 4.0;  // top/side padding

@interface HASidebarLayout ()
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *itemAttributes;
@property (nonatomic, assign) CGSize cachedContentSize;
@end

@implementation HASidebarLayout

- (instancetype)init {
    self = [super init];
    if (self) {
        _itemAttributes = [NSMutableArray array];
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];

    [self.itemAttributes removeAllObjects];

    UICollectionView *cv = self.collectionView;
    if (!cv) return;

    NSInteger sectionCount = [cv numberOfSections];
    if (sectionCount == 0) {
        self.cachedContentSize = CGSizeZero;
        return;
    }

    CGFloat viewportWidth = cv.bounds.size.width;
    BOOL collapsed = (viewportWidth < kSidebarCollapseWidth);

    NSInteger mainCount = [cv numberOfItemsInSection:0];
    NSInteger sidebarCount = (sectionCount > 1) ? [cv numberOfItemsInSection:1] : 0;

    if (collapsed) {
        // Single column: main cards first, then sidebar cards
        [self layoutSingleColumn:cv mainCount:mainCount sidebarCount:sidebarCount viewportWidth:viewportWidth];
    } else {
        // Two columns: main + sidebar side by side
        [self layoutTwoColumns:cv mainCount:mainCount sidebarCount:sidebarCount viewportWidth:viewportWidth];
    }
}

/// Collapsed layout: all items in one column
- (void)layoutSingleColumn:(UICollectionView *)cv
                 mainCount:(NSInteger)mainCount
              sidebarCount:(NSInteger)sidebarCount
             viewportWidth:(CGFloat)viewportWidth {
    CGFloat columnWidth = viewportWidth - 2.0 * kContentPadding;
    CGFloat y = kContentPadding;

    // Main items (section 0)
    for (NSInteger i = 0; i < mainCount; i++) {
        NSIndexPath *ip = [NSIndexPath indexPathForItem:i inSection:0];
        CGFloat h = [self heightForItem:ip width:columnWidth inCV:cv];
        UICollectionViewLayoutAttributes *attr =
            [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:ip];
        attr.frame = CGRectMake(kContentPadding, y, columnWidth, h);
        [self.itemAttributes addObject:attr];
        y += h + kCardSpacing;
    }

    // Sidebar items (section 1) below main
    for (NSInteger i = 0; i < sidebarCount; i++) {
        NSIndexPath *ip = [NSIndexPath indexPathForItem:i inSection:1];
        CGFloat h = [self heightForItem:ip width:columnWidth inCV:cv];
        UICollectionViewLayoutAttributes *attr =
            [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:ip];
        attr.frame = CGRectMake(kContentPadding, y, columnWidth, h);
        [self.itemAttributes addObject:attr];
        y += h + kCardSpacing;
    }

    self.cachedContentSize = CGSizeMake(viewportWidth, y);
}

/// Two-column layout: main (flex-grow 2) + sidebar (flex-grow 1)
- (void)layoutTwoColumns:(UICollectionView *)cv
               mainCount:(NSInteger)mainCount
            sidebarCount:(NSInteger)sidebarCount
           viewportWidth:(CGFloat)viewportWidth {
    // Calculate column widths using flex-grow 2:1 ratio
    CGFloat available = viewportWidth - 2.0 * kContentPadding - kSidebarSpacing;
    CGFloat mainWidth = floor(available * 2.0 / 3.0);
    CGFloat sidebarWidth = available - mainWidth;

    // Apply max width constraints
    if (mainWidth > kMainMaxWidth) mainWidth = kMainMaxWidth;
    if (sidebarWidth > kSidebarMaxWidth) sidebarWidth = kSidebarMaxWidth;

    // Center the columns if they don't fill the viewport
    CGFloat totalWidth = mainWidth + kSidebarSpacing + sidebarWidth;
    CGFloat leftOffset = floor((viewportWidth - totalWidth) / 2.0);
    if (leftOffset < kContentPadding) leftOffset = kContentPadding;

    CGFloat mainX = leftOffset;
    CGFloat sidebarX = leftOffset + mainWidth + kSidebarSpacing;

    // Layout main items (section 0)
    CGFloat mainY = kContentPadding;
    for (NSInteger i = 0; i < mainCount; i++) {
        NSIndexPath *ip = [NSIndexPath indexPathForItem:i inSection:0];
        CGFloat h = [self heightForItem:ip width:mainWidth inCV:cv];
        UICollectionViewLayoutAttributes *attr =
            [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:ip];
        attr.frame = CGRectMake(mainX, mainY, mainWidth, h);
        [self.itemAttributes addObject:attr];
        mainY += h + kCardSpacing;
    }

    // Layout sidebar items (section 1)
    CGFloat sidebarY = kContentPadding;
    for (NSInteger i = 0; i < sidebarCount; i++) {
        NSIndexPath *ip = [NSIndexPath indexPathForItem:i inSection:1];
        CGFloat h = [self heightForItem:ip width:sidebarWidth inCV:cv];
        UICollectionViewLayoutAttributes *attr =
            [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:ip];
        attr.frame = CGRectMake(sidebarX, sidebarY, sidebarWidth, h);
        [self.itemAttributes addObject:attr];
        sidebarY += h + kCardSpacing;
    }

    CGFloat maxY = MAX(mainY, sidebarY);
    self.cachedContentSize = CGSizeMake(viewportWidth, maxY);
}

- (CGFloat)heightForItem:(NSIndexPath *)indexPath width:(CGFloat)width inCV:(UICollectionView *)cv {
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:heightForItemAtIndexPath:itemWidth:)]) {
        return [self.delegate collectionView:cv layout:self heightForItemAtIndexPath:indexPath itemWidth:width];
    }
    return 100.0;
}

- (CGSize)collectionViewContentSize {
    return self.cachedContentSize;
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *result = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *attr in self.itemAttributes) {
        if (CGRectIntersectsRect(attr.frame, rect)) {
            [result addObject:attr];
        }
    }
    return result;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    for (UICollectionViewLayoutAttributes *attr in self.itemAttributes) {
        if ([attr.indexPath isEqual:indexPath]) {
            return attr;
        }
    }
    return nil;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
