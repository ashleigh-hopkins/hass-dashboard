#import <Foundation/Foundation.h>

/// Represents a floor in the Home Assistant floor registry.
/// Used by the home strategy to group areas by floor level.
@interface HAFloor : NSObject

@property (nonatomic, copy) NSString *floorId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger level;  // lower = ground floor, negative = basement
@property (nonatomic, copy) NSArray<NSString *> *areaIds;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
