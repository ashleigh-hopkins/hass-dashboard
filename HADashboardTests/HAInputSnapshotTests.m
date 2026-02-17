#import "HABaseSnapshotTestCase.h"
#import "HASnapshotTestHelpers.h"
#import "HAInputSelectEntityCell.h"
#import "HAInputNumberEntityCell.h"
#import "HAInputTextEntityCell.h"
#import "HAInputDateTimeEntityCell.h"
#import "HADashboardConfig.h"

@interface HAInputSnapshotTests : HABaseSnapshotTestCase
@end

@implementation HAInputSnapshotTests

#pragma mark - Input Select (2 tests)

- (void)testInputSelectThreeOptions {
    HAEntity *entity = [HASnapshotTestHelpers inputSelectThreeOptions];
    HADashboardConfigItem *item = [HASnapshotTestHelpers itemWithEntityId:@"input_select.media_source"
                                                                cardType:@"input_select"
                                                              columnSpan:6
                                                             headingIcon:nil
                                                             displayName:nil];
    CGSize size = CGSizeMake(floor(kSubGridUnit * 6), kStandardCellHeight);
    UIView *cell = [self cellForEntity:entity cellClass:[HAInputSelectEntityCell class] size:size configItem:item];
    [self verifyView:cell identifier:@""];
}

- (void)testInputSelectFiveOptions {
    HAEntity *entity = [HASnapshotTestHelpers inputSelectFiveOptions];
    HADashboardConfigItem *item = [HASnapshotTestHelpers itemWithEntityId:@"input_select.living_room_app"
                                                                cardType:@"input_select"
                                                              columnSpan:6
                                                             headingIcon:nil
                                                             displayName:nil];
    CGSize size = CGSizeMake(floor(kSubGridUnit * 6), kStandardCellHeight);
    UIView *cell = [self cellForEntity:entity cellClass:[HAInputSelectEntityCell class] size:size configItem:item];
    [self verifyView:cell identifier:@""];
}

#pragma mark - Input Number (2 tests)

- (void)testInputNumberSlider {
    HAEntity *entity = [HASnapshotTestHelpers inputNumberSlider];
    HADashboardConfigItem *item = [HASnapshotTestHelpers itemWithEntityId:@"input_number.target_temperature"
                                                                cardType:@"input_number"
                                                              columnSpan:6
                                                             headingIcon:nil
                                                             displayName:nil];
    CGSize size = CGSizeMake(floor(kSubGridUnit * 6), kStandardCellHeight);
    UIView *cell = [self cellForEntity:entity cellClass:[HAInputNumberEntityCell class] size:size configItem:item];
    [self verifyView:cell identifier:@""];
}

- (void)testInputNumberBox {
    HAEntity *entity = [HASnapshotTestHelpers inputNumberBox];
    HADashboardConfigItem *item = [HASnapshotTestHelpers itemWithEntityId:@"input_number.standing_desk_height"
                                                                cardType:@"input_number"
                                                              columnSpan:6
                                                             headingIcon:nil
                                                             displayName:nil];
    CGSize size = CGSizeMake(floor(kSubGridUnit * 6), kStandardCellHeight);
    UIView *cell = [self cellForEntity:entity cellClass:[HAInputNumberEntityCell class] size:size configItem:item];
    [self verifyView:cell identifier:@""];
}

#pragma mark - Input Text (2 tests)

- (void)testInputTextWithValue {
    HAEntity *entity = [HASnapshotTestHelpers inputTextWithValue];
    HADashboardConfigItem *item = [HASnapshotTestHelpers itemWithEntityId:@"input_text.greeting"
                                                                cardType:@"input_text"
                                                              columnSpan:6
                                                             headingIcon:nil
                                                             displayName:nil];
    CGSize size = CGSizeMake(floor(kSubGridUnit * 6), kStandardCellHeight);
    UIView *cell = [self cellForEntity:entity cellClass:[HAInputTextEntityCell class] size:size configItem:item];
    [self verifyView:cell identifier:@""];
}

- (void)testInputTextEmpty {
    HAEntity *entity = [HASnapshotTestHelpers inputTextEmpty];
    HADashboardConfigItem *item = [HASnapshotTestHelpers itemWithEntityId:@"input_text.notes"
                                                                cardType:@"input_text"
                                                              columnSpan:6
                                                             headingIcon:nil
                                                             displayName:nil];
    CGSize size = CGSizeMake(floor(kSubGridUnit * 6), kStandardCellHeight);
    UIView *cell = [self cellForEntity:entity cellClass:[HAInputTextEntityCell class] size:size configItem:item];
    [self verifyView:cell identifier:@""];
}

#pragma mark - Input DateTime (3 tests)

- (void)testInputDateTimeDate {
    HAEntity *entity = [HASnapshotTestHelpers inputDateTimeDate];
    HADashboardConfigItem *item = [HASnapshotTestHelpers itemWithEntityId:@"input_datetime.vacation_start"
                                                                cardType:@"input_datetime"
                                                              columnSpan:6
                                                             headingIcon:nil
                                                             displayName:nil];
    CGSize size = CGSizeMake(floor(kSubGridUnit * 6), kStandardCellHeight);
    UIView *cell = [self cellForEntity:entity cellClass:[HAInputDateTimeEntityCell class] size:size configItem:item];
    [self verifyView:cell identifier:@""];
}

- (void)testInputDateTimeTime {
    HAEntity *entity = [HASnapshotTestHelpers inputDateTimeTime];
    HADashboardConfigItem *item = [HASnapshotTestHelpers itemWithEntityId:@"input_datetime.morning_alarm"
                                                                cardType:@"input_datetime"
                                                              columnSpan:6
                                                             headingIcon:nil
                                                             displayName:nil];
    CGSize size = CGSizeMake(floor(kSubGridUnit * 6), kStandardCellHeight);
    UIView *cell = [self cellForEntity:entity cellClass:[HAInputDateTimeEntityCell class] size:size configItem:item];
    [self verifyView:cell identifier:@""];
}

- (void)testInputDateTimeBoth {
    HAEntity *entity = [HASnapshotTestHelpers inputDateTimeBoth];
    HADashboardConfigItem *item = [HASnapshotTestHelpers itemWithEntityId:@"input_datetime.appointment"
                                                                cardType:@"input_datetime"
                                                              columnSpan:6
                                                             headingIcon:nil
                                                             displayName:nil];
    CGSize size = CGSizeMake(floor(kSubGridUnit * 6), kStandardCellHeight);
    UIView *cell = [self cellForEntity:entity cellClass:[HAInputDateTimeEntityCell class] size:size configItem:item];
    [self verifyView:cell identifier:@""];
}

@end
