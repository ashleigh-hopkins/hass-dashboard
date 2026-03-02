#import "HATileFeatureView.h"
#import "HAEntity.h"

@implementation HATileFeatureView

+ (CGFloat)preferredHeight {
    return 44.0;
}

- (void)configureWithEntity:(HAEntity *)entity featureConfig:(NSDictionary *)config {
    self.entity = entity;
    self.featureConfig = config;
    self.featureType = config[@"type"];
}

- (void)updateWithEntity:(HAEntity *)entity {
    [self configureWithEntity:entity featureConfig:self.featureConfig];
}

@end
