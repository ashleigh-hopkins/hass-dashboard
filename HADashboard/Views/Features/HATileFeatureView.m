#import "HATileFeatureView.h"
#import "HAAutoLayout.h"
#import "HAEntity.h"

@implementation HATileFeatureView

+ (CGFloat)preferredHeight {
    return 44.0;
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (!HAAutoLayoutAvailable()) {
        CGFloat h = [[self class] preferredHeight];
        return CGSizeMake(size.width, h);
    }
    return [super sizeThatFits:size];
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
