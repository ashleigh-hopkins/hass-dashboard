#import "HABaseSnapshotTestCase.h"
#import "HAEntity.h"
#import "HADashboardConfig.h"
#import "HABaseEntityCell.h"
#import "HAEntitiesCardCell.h"
#import "HABadgeRowCell.h"
#import "HATheme.h"

@implementation HABaseSnapshotTestCase

- (void)setUp {
    [super setUp];
    // Record mode controlled by GCC_PREPROCESSOR_DEFINITIONS:
    // xcodebuild test ... GCC_PREPROCESSOR_DEFINITIONS='RECORD_SNAPSHOTS=1'
#ifdef RECORD_SNAPSHOTS
    self.recordMode = YES;
#else
    self.recordMode = NO;
#endif
    self.usesDrawViewHierarchyInRect = YES;
}

#pragma mark - Reference / Failure Image Directories

/// Override to point at our source tree ReferenceImages directory.
- (NSString *)getReferenceImageDirectoryWithDefault:(NSString *)dir {
    NSString *thisFile = @__FILE__;
    NSString *testDir = [thisFile stringByDeletingLastPathComponent];
    return [testDir stringByAppendingPathComponent:@"ReferenceImages"];
}

/// Override to point at our source tree FailureDiffs directory.
- (NSString *)getImageDiffDirectoryWithDefault:(NSString *)dir {
    NSString *thisFile = @__FILE__;
    NSString *testDir = [thisFile stringByDeletingLastPathComponent];
    return [testDir stringByAppendingPathComponent:@"FailureDiffs"];
}

#pragma mark - Cell Creation Helpers

- (UIView *)cellForEntity:(HAEntity *)entity
                 cellClass:(Class)cellClass
                      size:(CGSize)size
                configItem:(HADashboardConfigItem *)configItem {
    HABaseEntityCell *cell = [[cellClass alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    [cell configureWithEntity:entity configItem:configItem];
    [cell layoutIfNeeded];
    return cell;
}

- (UIView *)compositeCell:(Class)cellClass
                     size:(CGSize)size
                  section:(HADashboardConfigSection *)section
                 entities:(NSDictionary<NSString *, HAEntity *> *)entities
               configItem:(HADashboardConfigItem *)configItem {
    UICollectionViewCell *cell = [[cellClass alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];

    if ([cell isKindOfClass:[HAEntitiesCardCell class]]) {
        [(HAEntitiesCardCell *)cell configureWithSection:section entities:entities configItem:configItem];
    } else if ([cell isKindOfClass:[HABadgeRowCell class]]) {
        [(HABadgeRowCell *)cell configureWithSection:section entities:entities];
    }

    [cell layoutIfNeeded];
    return cell;
}

#pragma mark - Theme Verification

- (void)verifyView:(UIView *)view identifier:(NSString *)identifier inTheme:(NSInteger)mode {
    HAThemeMode originalMode = [HATheme currentMode];

    [HATheme setCurrentMode:(HAThemeMode)mode];
    [view setNeedsLayout];
    [view layoutIfNeeded];

    NSString *themeSuffix;
    switch ((HAThemeMode)mode) {
        case HAThemeModeLight:
            themeSuffix = @"_light";
            break;
        case HAThemeModeDark:
            themeSuffix = @"_dark";
            break;
        case HAThemeModeGradient:
            themeSuffix = @"_gradient";
            break;
        default:
            themeSuffix = @"_auto";
            break;
    }

    NSString *suffixedIdentifier;
    if (identifier.length > 0) {
        suffixedIdentifier = [identifier stringByAppendingString:themeSuffix];
    } else {
        suffixedIdentifier = themeSuffix;
    }

    FBSnapshotVerifyView(view, suffixedIdentifier);

    [HATheme setCurrentMode:originalMode];
}

- (void)verifyView:(UIView *)view identifier:(NSString *)identifier {
    [self verifyView:view identifier:identifier inTheme:HAThemeModeGradient];
    [self verifyView:view identifier:identifier inTheme:HAThemeModeLight];
}

@end
