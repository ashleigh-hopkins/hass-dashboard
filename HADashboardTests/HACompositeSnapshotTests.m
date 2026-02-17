#import "HABaseSnapshotTestCase.h"
#import "HASnapshotTestHelpers.h"
#import "HAEntitiesCardCell.h"
#import "HABadgeRowCell.h"
#import "HAGaugeCardCell.h"
#import "HAGraphCardCell.h"
#import "HATileEntityCell.h"
#import "HAHeadingCell.h"
#import "HADashboardConfig.h"
#import "HAEntity.h"

@interface HACompositeSnapshotTests : HABaseSnapshotTestCase
@end

@implementation HACompositeSnapshotTests

#pragma mark - HAEntitiesCardCell (2 tests)

- (void)testEntitiesCard3Rows {
    HADashboardConfigSection *section = [HASnapshotTestHelpers entitiesSectionWithLights];
    NSDictionary *entities = [HASnapshotTestHelpers livingRoomEntities];
    HADashboardConfigItem *item = [HASnapshotTestHelpers itemWithEntityId:@"light.office_3"
        cardType:@"entities" columnSpan:12 headingIcon:nil displayName:nil];
    item.entitiesSection = section;
    CGFloat height = [HAEntitiesCardCell preferredHeightForEntityCount:3 hasTitle:NO hasHeaderToggle:NO];
    UIView *cell = [self compositeCell:[HAEntitiesCardCell class]
        size:CGSizeMake(kColumnWidth, height) section:section entities:entities configItem:item];
    [self verifyView:cell identifier:nil];
}

- (void)testEntitiesCard5Rows {
    HADashboardConfigSection *section = [HASnapshotTestHelpers entitiesSectionFiveRows];
    NSDictionary *entities = @{
        @"light.kitchen": [HASnapshotTestHelpers lightEntityOnBrightness],
        @"switch.in_meeting": [HASnapshotTestHelpers switchEntityOn],
        @"sensor.living_room_temperature": [HASnapshotTestHelpers sensorTemperature],
        @"cover.living_room_shutter": [HASnapshotTestHelpers coverEntityOpenShutter],
        @"lock.frontdoor": [HASnapshotTestHelpers lockLocked]
    };
    HADashboardConfigItem *item = [HASnapshotTestHelpers itemWithEntityId:@"light.kitchen"
        cardType:@"entities" columnSpan:12 headingIcon:nil displayName:nil];
    item.entitiesSection = section;
    CGFloat height = [HAEntitiesCardCell preferredHeightForEntityCount:5 hasTitle:YES hasHeaderToggle:NO];
    UIView *cell = [self compositeCell:[HAEntitiesCardCell class]
        size:CGSizeMake(kColumnWidth, height) section:section entities:entities configItem:item];
    [self verifyView:cell identifier:nil];
}

#pragma mark - HABadgeRowCell (2 tests)

- (void)testBadgeRow2Items {
    HADashboardConfigSection *section = [HASnapshotTestHelpers badgeSection2Items];
    NSDictionary *entities = @{
        @"sensor.living_room_temperature": [HASnapshotTestHelpers sensorTemperature],
        @"sensor.living_room_humidity": [HASnapshotTestHelpers sensorHumidity]
    };
    UIView *cell = [self compositeCell:[HABadgeRowCell class]
        size:CGSizeMake(kColumnWidth, kBadgeRowHeight) section:section entities:entities configItem:nil];
    [self verifyView:cell identifier:nil];
}

- (void)testBadgeRow4Items {
    HADashboardConfigSection *section = [HASnapshotTestHelpers badgeSection4Items];
    NSDictionary *entities = @{
        @"sensor.living_room_temperature": [HASnapshotTestHelpers sensorTemperature],
        @"sensor.living_room_humidity": [HASnapshotTestHelpers sensorHumidity],
        @"binary_sensor.hallway_motion": [HASnapshotTestHelpers binarySensorMotionOn],
        @"binary_sensor.front_door": [HASnapshotTestHelpers binarySensorDoorOff]
    };
    UIView *cell = [self compositeCell:[HABadgeRowCell class]
        size:CGSizeMake(kColumnWidth, kBadgeRowHeight) section:section entities:entities configItem:nil];
    [self verifyView:cell identifier:nil];
}

#pragma mark - HAGaugeCardCell (4 tests)

- (void)testGauge50Percent {
    HAEntity *entity = [HASnapshotTestHelpers sensorTemperature];
    HADashboardConfigItem *item = [HASnapshotTestHelpers gaugeCardItem50Percent];
    UIView *cell = [self cellForEntity:entity cellClass:[HAGaugeCardCell class]
        size:CGSizeMake(kColumnWidth, kGaugeCardHeight) configItem:item];
    [self verifyView:cell identifier:nil];
}

- (void)testGauge0Percent {
    HAEntity *entity = [HASnapshotTestHelpers sensorTemperature];
    HADashboardConfigItem *item = [HASnapshotTestHelpers gaugeCardItem0Percent];
    UIView *cell = [self cellForEntity:entity cellClass:[HAGaugeCardCell class]
        size:CGSizeMake(kColumnWidth, kGaugeCardHeight) configItem:item];
    [self verifyView:cell identifier:nil];
}

- (void)testGauge100Percent {
    HAEntity *entity = [HASnapshotTestHelpers sensorTemperature];
    HADashboardConfigItem *item = [HASnapshotTestHelpers gaugeCardItem100Percent];
    UIView *cell = [self cellForEntity:entity cellClass:[HAGaugeCardCell class]
        size:CGSizeMake(kColumnWidth, kGaugeCardHeight) configItem:item];
    [self verifyView:cell identifier:nil];
}

- (void)testGaugeSeverity {
    HAEntity *entity = [HASnapshotTestHelpers sensorTemperature];
    HADashboardConfigItem *item = [HASnapshotTestHelpers gaugeCardItemSeverity];
    UIView *cell = [self cellForEntity:entity cellClass:[HAGaugeCardCell class]
        size:CGSizeMake(kColumnWidth, kGaugeCardHeight) configItem:item];
    [self verifyView:cell identifier:nil];
}

#pragma mark - HAGraphCardCell (2 tests)

- (void)testGraphSingle {
    HAEntity *entity = [HASnapshotTestHelpers sensorTemperature];
    HADashboardConfigItem *item = [HASnapshotTestHelpers graphCardSingleEntity];
    HAGraphCardCell *graphCell = [[HAGraphCardCell alloc] initWithFrame:CGRectMake(0, 0, kColumnWidth, kGraphCardHeight)];
    [graphCell configureWithEntity:entity item:item];
    [graphCell layoutIfNeeded];
    [self verifyView:graphCell identifier:nil];
}

- (void)testGraphMulti {
    HADashboardConfigSection *section = [HASnapshotTestHelpers sectionWithTitle:@"Environment"
        icon:@"mdi:thermometer"
        entityIds:@[
            @"sensor.living_room_temperature",
            @"sensor.living_room_humidity",
            @"sensor.office_illuminance"
        ]];
    NSDictionary *entities = @{
        @"sensor.living_room_temperature": [HASnapshotTestHelpers sensorTemperature],
        @"sensor.living_room_humidity": [HASnapshotTestHelpers sensorHumidity],
        @"sensor.office_illuminance": [HASnapshotTestHelpers sensorIlluminance]
    };
    HAGraphCardCell *graphCell = [[HAGraphCardCell alloc] initWithFrame:CGRectMake(0, 0, kColumnWidth, kGraphCardHeight)];
    [graphCell configureWithSection:section entities:entities];
    [graphCell layoutIfNeeded];
    [self verifyView:graphCell identifier:nil];
}

#pragma mark - HAGaugeCardCell — Narrow (1 test)

- (void)testGaugeNarrowTextScaling {
    // Small gauge card (like vplants dashboard): text must scale to fit inside arc
    HAEntity *entity = [HASnapshotTestHelpers sensorHumidity]; // 57%
    HADashboardConfigItem *item = [HASnapshotTestHelpers gaugeCardItem50Percent];
    CGFloat narrowWidth = floor(kSubGridUnit * 4); // ~107pt — narrow column
    UIView *cell = [self cellForEntity:entity cellClass:[HAGaugeCardCell class]
        size:CGSizeMake(narrowWidth, kGaugeCardHeight) configItem:item];
    [self verifyView:cell identifier:nil];
}

#pragma mark - HAGraphCardCell — Multi-Axis (1 test)

- (void)testGraphMultiAxis {
    // 3 entities with different units: °C, %, lx — should produce 3 Y-axis groups
    HADashboardConfigSection *section = [HASnapshotTestHelpers sectionWithTitle:@"Environment"
        icon:@"mdi:thermometer"
        entityIds:@[
            @"sensor.living_room_temperature",
            @"sensor.living_room_humidity",
            @"sensor.office_illuminance"
        ]];
    section.customProperties = @{@"hours_to_show": @24};
    NSDictionary *entities = @{
        @"sensor.living_room_temperature": [HASnapshotTestHelpers sensorTemperature],
        @"sensor.living_room_humidity": [HASnapshotTestHelpers sensorHumidity],
        @"sensor.office_illuminance": [HASnapshotTestHelpers sensorIlluminance]
    };
    HAGraphCardCell *graphCell = [[HAGraphCardCell alloc] initWithFrame:CGRectMake(0, 0, kColumnWidth, kGraphCardHeight)];
    [graphCell configureWithSection:section entities:entities];
    [graphCell layoutIfNeeded];
    [self verifyView:graphCell identifier:nil];
}

#pragma mark - HAGraphCardCell — With Axis Labels (1 test)

- (void)testGraphSingleWithAxisLabels {
    // Single entity graph: verify Y-axis and X-axis labels render
    HAEntity *entity = [HASnapshotTestHelpers sensorTemperature];
    HADashboardConfigItem *item = [HASnapshotTestHelpers graphCardSingleEntity];
    HAGraphCardCell *graphCell = [[HAGraphCardCell alloc] initWithFrame:CGRectMake(0, 0, kColumnWidth, kGraphCardHeight)];
    [graphCell configureWithEntity:entity item:item];
    [graphCell layoutIfNeeded];
    [self verifyView:graphCell identifier:nil];
}

#pragma mark - HATileEntityCell (2 tests)

- (void)testTileLight {
    HAEntity *entity = [HASnapshotTestHelpers lightEntityOnBrightness];
    CGFloat width = floor(kSubGridUnit * 6);
    HADashboardConfigItem *item = [HASnapshotTestHelpers itemWithEntityId:entity.entityId
        cardType:@"tile" columnSpan:6 headingIcon:nil displayName:nil];
    UIView *cell = [self cellForEntity:entity cellClass:[HATileEntityCell class]
        size:CGSizeMake(width, kTileHeight) configItem:item];
    [self verifyView:cell identifier:nil];
}

- (void)testTileSwitch {
    HAEntity *entity = [HASnapshotTestHelpers switchEntityOn];
    CGFloat width = floor(kSubGridUnit * 6);
    HADashboardConfigItem *item = [HASnapshotTestHelpers itemWithEntityId:entity.entityId
        cardType:@"tile" columnSpan:6 headingIcon:nil displayName:nil];
    UIView *cell = [self cellForEntity:entity cellClass:[HATileEntityCell class]
        size:CGSizeMake(width, kTileHeight) configItem:item];
    [self verifyView:cell identifier:nil];
}

#pragma mark - HAHeadingCell (2 tests)

- (void)testHeadingWithIcon {
    HAHeadingCell *cell = [[HAHeadingCell alloc] initWithFrame:CGRectMake(0, 0, kColumnWidth, kHeadingCellHeight)];
    HADashboardConfigItem *item = [[HADashboardConfigItem alloc] init];
    item.cardType = @"heading";
    item.displayName = @"Living Room";
    item.columnSpan = 12;
    item.customProperties = @{@"icon": @"mdi:sofa"};
    [cell configureWithItem:item];
    [cell layoutIfNeeded];
    [self verifyView:cell identifier:nil];
}

- (void)testHeadingNoIcon {
    HAHeadingCell *cell = [[HAHeadingCell alloc] initWithFrame:CGRectMake(0, 0, kColumnWidth, kHeadingCellHeight)];
    HADashboardConfigItem *item = [[HADashboardConfigItem alloc] init];
    item.cardType = @"heading";
    item.displayName = @"Living Room";
    item.columnSpan = 12;
    item.customProperties = @{};
    [cell configureWithItem:item];
    [cell layoutIfNeeded];
    [self verifyView:cell identifier:nil];
}

@end
