#import "HATileFeatureFactory.h"
#import "HATileFeatureView.h"
#import "HASliderFeatureView.h"
#import "HAButtonRowFeatureView.h"
#import "HAModeFeatureView.h"
#import "HAEntity.h"

/// Feature types handled by HASliderFeatureView
static NSSet *_sliderTypes;
/// Feature types handled by HAButtonRowFeatureView
static NSSet *_buttonRowTypes;
/// Feature types handled by HAModeFeatureView
static NSSet *_modeTypes;

@implementation HATileFeatureFactory

+ (void)initialize {
    if (self == [HATileFeatureFactory class]) {
        _sliderTypes = [NSSet setWithObjects:
            @"light-brightness",
            @"cover-position",
            @"cover-tilt-position",
            @"fan-speed",
            @"light-color-temp",
            @"media-player-volume-slider",
            @"numeric-input",
            @"target-humidity",
            nil];
        _buttonRowTypes = [NSSet setWithObjects:
            @"cover-open-close",
            @"lock-commands",
            @"toggle",
            @"vacuum-commands",
            @"counter-actions",
            @"target-temperature",
            nil];
        _modeTypes = [NSSet setWithObjects:
            @"climate-hvac-modes",
            @"climate-preset-modes",
            @"climate-fan-modes",
            @"alarm-modes",
            nil];
    }
}

+ (HATileFeatureView *)featureViewForConfig:(NSDictionary *)config entity:(HAEntity *)entity {
    NSString *type = config[@"type"];
    if (![type isKindOfClass:[NSString class]] || type.length == 0) return nil;

    HATileFeatureView *view = nil;

    if ([_sliderTypes containsObject:type]) {
        view = [[HASliderFeatureView alloc] init];
    } else if ([_buttonRowTypes containsObject:type]) {
        view = [[HAButtonRowFeatureView alloc] init];
    } else if ([_modeTypes containsObject:type]) {
        view = [[HAModeFeatureView alloc] init];
    } else {
        // Unsupported feature type — skip silently
        NSLog(@"[TileFeature] Unsupported feature type: %@", type);
        return nil;
    }

    view.translatesAutoresizingMaskIntoConstraints = NO;
    [view configureWithEntity:entity featureConfig:config];
    return view;
}

+ (CGFloat)heightForFeatureType:(NSString *)featureType {
    if ([_sliderTypes containsObject:featureType]) {
        return [HASliderFeatureView preferredHeight];
    } else if ([_buttonRowTypes containsObject:featureType]) {
        return [HAButtonRowFeatureView preferredHeight];
    } else if ([_modeTypes containsObject:featureType]) {
        return [HAModeFeatureView preferredHeight];
    }
    return 0;
}

@end
