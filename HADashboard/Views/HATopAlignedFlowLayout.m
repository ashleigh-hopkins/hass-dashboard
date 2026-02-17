#import "HATopAlignedFlowLayout.h"

@implementation HATopAlignedFlowLayout

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *original = [super layoutAttributesForElementsInRect:rect];
    if (!original || original.count == 0) return original;

    // Copy attributes (required by UICollectionView)
    NSMutableArray *attrs = [NSMutableArray arrayWithCapacity:original.count];
    for (UICollectionViewLayoutAttributes *a in original) {
        [attrs addObject:[a copy]];
    }

    // Collect cell attributes only, sorted by center Y then X
    NSMutableArray<UICollectionViewLayoutAttributes *> *cells = [NSMutableArray array];
    for (UICollectionViewLayoutAttributes *a in attrs) {
        if (a.representedElementCategory == UICollectionElementCategoryCell) {
            [cells addObject:a];
        }
    }
    [cells sortUsingComparator:^NSComparisonResult(UICollectionViewLayoutAttributes *a, UICollectionViewLayoutAttributes *b) {
        CGFloat diff = CGRectGetMidY(a.frame) - CGRectGetMidY(b.frame);
        if (fabs(diff) < 1.0) {
            return CGRectGetMinX(a.frame) < CGRectGetMinX(b.frame) ? NSOrderedAscending : NSOrderedDescending;
        }
        return diff < 0 ? NSOrderedAscending : NSOrderedDescending;
    }];

    // Group into rows: items whose center-Y is within half the line spacing
    // of each other are on the same visual row.
    NSMutableArray<NSMutableArray *> *rows = [NSMutableArray array];
    NSMutableArray *currentRow = nil;
    CGFloat currentRowCenterY = 0;

    for (UICollectionViewLayoutAttributes *a in cells) {
        CGFloat centerY = CGRectGetMidY(a.frame);
        if (!currentRow || fabs(centerY - currentRowCenterY) > a.frame.size.height * 0.5) {
            // Start a new row
            currentRow = [NSMutableArray array];
            [rows addObject:currentRow];
            currentRowCenterY = centerY;
        }
        [currentRow addObject:a];
    }

    // For each row with multiple items, top-align all items
    for (NSMutableArray *row in rows) {
        if (row.count <= 1) continue;

        CGFloat minY = CGFLOAT_MAX;
        for (UICollectionViewLayoutAttributes *a in row) {
            if (a.frame.origin.y < minY) minY = a.frame.origin.y;
        }

        for (UICollectionViewLayoutAttributes *a in row) {
            CGRect frame = a.frame;
            frame.origin.y = minY;
            a.frame = frame;
        }
    }

    return attrs;
}

@end
