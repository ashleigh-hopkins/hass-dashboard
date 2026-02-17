#import "HAEntity.h"

@interface HAEntity (Update)
// Existing in HAEntity.h: updateInstalledVersion, updateLatestVersion, updateAvailable, updateReleaseURL
- (NSString *)updateReleaseSummary;
@end
