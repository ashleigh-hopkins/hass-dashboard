#import "HAEntity.h"

@interface HAEntity (WaterHeater)
- (NSArray<NSString *> *)waterHeaterOperationList;
- (NSString *)waterHeaterOperationMode;
- (NSNumber *)waterHeaterTemperature;
- (NSNumber *)waterHeaterMinTemp;
- (NSNumber *)waterHeaterMaxTemp;
@end
