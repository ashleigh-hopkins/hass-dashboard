#import "HABaseSnapshotTestCase.h"
#import "HASnapshotTestHelpers.h"
#import "HALightEntityCell.h"
#import "HASensorEntityCell.h"
#import "HASwitchEntityCell.h"
#import "HAClimateEntityCell.h"
#import "HADashboardConfig.h"

@interface HAEdgeCaseSnapshotTests : HABaseSnapshotTestCase
@end

@implementation HAEdgeCaseSnapshotTests

#pragma mark - Unavailable Entities

- (void)testUnavailableLight {
    HAEntity *entity = [HASnapshotTestHelpers unavailableEntity:@"light.test"];
    HADashboardConfigItem *item = [HASnapshotTestHelpers itemWithEntityId:@"light.test"
        cardType:@"light" columnSpan:6 headingIcon:nil displayName:nil];
    CGFloat width = floor(kSubGridUnit * 6);
    UIView *cell = [self cellForEntity:entity cellClass:[HALightEntityCell class]
        size:CGSizeMake(width, kStandardCellHeight) configItem:item];
    [self verifyView:cell identifier:nil];
}

- (void)testUnavailableSensor {
    HAEntity *entity = [HASnapshotTestHelpers unavailableEntity:@"sensor.test"];
    HADashboardConfigItem *item = [HASnapshotTestHelpers itemWithEntityId:@"sensor.test"
        cardType:@"sensor" columnSpan:6 headingIcon:nil displayName:nil];
    CGFloat width = floor(kSubGridUnit * 6);
    UIView *cell = [self cellForEntity:entity cellClass:[HASensorEntityCell class]
        size:CGSizeMake(width, kStandardCellHeight) configItem:item];
    [self verifyView:cell identifier:nil];
}

- (void)testUnavailableClimate {
    HAEntity *entity = [HASnapshotTestHelpers unavailableEntity:@"climate.test"];
    HADashboardConfigItem *item = [HASnapshotTestHelpers itemWithEntityId:@"climate.test"
        cardType:@"climate" columnSpan:6 headingIcon:nil displayName:nil];
    CGFloat width = floor(kSubGridUnit * 6);
    UIView *cell = [self cellForEntity:entity cellClass:[HAClimateEntityCell class]
        size:CGSizeMake(width, kStandardCellHeight) configItem:item];
    [self verifyView:cell identifier:nil];
}

- (void)testUnavailableSwitch {
    HAEntity *entity = [HASnapshotTestHelpers unavailableEntity:@"switch.test"];
    HADashboardConfigItem *item = [HASnapshotTestHelpers itemWithEntityId:@"switch.test"
        cardType:@"switch" columnSpan:6 headingIcon:nil displayName:nil];
    CGFloat width = floor(kSubGridUnit * 6);
    UIView *cell = [self cellForEntity:entity cellClass:[HASwitchEntityCell class]
        size:CGSizeMake(width, kStandardCellHeight) configItem:item];
    [self verifyView:cell identifier:nil];
}

#pragma mark - Long Name Entities

- (void)testLongNameLight {
    HAEntity *entity = [HASnapshotTestHelpers longNameEntity:@"light.test"];
    HADashboardConfigItem *item = [HASnapshotTestHelpers itemWithEntityId:@"light.test"
        cardType:@"light" columnSpan:6 headingIcon:nil displayName:nil];
    CGFloat width = floor(kSubGridUnit * 6);
    UIView *cell = [self cellForEntity:entity cellClass:[HALightEntityCell class]
        size:CGSizeMake(width, kStandardCellHeight) configItem:item];
    [self verifyView:cell identifier:nil];
}

- (void)testLongNameSensor {
    HAEntity *entity = [HASnapshotTestHelpers longNameEntity:@"sensor.test"];
    HADashboardConfigItem *item = [HASnapshotTestHelpers itemWithEntityId:@"sensor.test"
        cardType:@"sensor" columnSpan:6 headingIcon:nil displayName:nil];
    CGFloat width = floor(kSubGridUnit * 6);
    UIView *cell = [self cellForEntity:entity cellClass:[HASensorEntityCell class]
        size:CGSizeMake(width, kStandardCellHeight) configItem:item];
    [self verifyView:cell identifier:nil];
}

- (void)testLongNameSwitch {
    HAEntity *entity = [HASnapshotTestHelpers longNameEntity:@"switch.test"];
    HADashboardConfigItem *item = [HASnapshotTestHelpers itemWithEntityId:@"switch.test"
        cardType:@"switch" columnSpan:6 headingIcon:nil displayName:nil];
    CGFloat width = floor(kSubGridUnit * 6);
    UIView *cell = [self cellForEntity:entity cellClass:[HASwitchEntityCell class]
        size:CGSizeMake(width, kStandardCellHeight) configItem:item];
    [self verifyView:cell identifier:nil];
}

#pragma mark - Minimal Entities

- (void)testMinimalLight {
    HAEntity *entity = [HASnapshotTestHelpers minimalEntity:@"light.test"];
    HADashboardConfigItem *item = [HASnapshotTestHelpers itemWithEntityId:@"light.test"
        cardType:@"light" columnSpan:6 headingIcon:nil displayName:nil];
    CGFloat width = floor(kSubGridUnit * 6);
    UIView *cell = [self cellForEntity:entity cellClass:[HALightEntityCell class]
        size:CGSizeMake(width, kStandardCellHeight) configItem:item];
    [self verifyView:cell identifier:nil];
}

- (void)testMinimalSensor {
    HAEntity *entity = [HASnapshotTestHelpers minimalEntity:@"sensor.test"];
    HADashboardConfigItem *item = [HASnapshotTestHelpers itemWithEntityId:@"sensor.test"
        cardType:@"sensor" columnSpan:6 headingIcon:nil displayName:nil];
    CGFloat width = floor(kSubGridUnit * 6);
    UIView *cell = [self cellForEntity:entity cellClass:[HASensorEntityCell class]
        size:CGSizeMake(width, kStandardCellHeight) configItem:item];
    [self verifyView:cell identifier:nil];
}

- (void)testMinimalSwitch {
    HAEntity *entity = [HASnapshotTestHelpers minimalEntity:@"switch.test"];
    HADashboardConfigItem *item = [HASnapshotTestHelpers itemWithEntityId:@"switch.test"
        cardType:@"switch" columnSpan:6 headingIcon:nil displayName:nil];
    CGFloat width = floor(kSubGridUnit * 6);
    UIView *cell = [self cellForEntity:entity cellClass:[HASwitchEntityCell class]
        size:CGSizeMake(width, kStandardCellHeight) configItem:item];
    [self verifyView:cell identifier:nil];
}

@end
