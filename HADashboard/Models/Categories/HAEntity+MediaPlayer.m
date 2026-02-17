#import "HAEntity+MediaPlayer.h"

@implementation HAEntity (MediaPlayer)

- (NSNumber *)mediaDuration {
    return HAAttrNumber(self.attributes, HAAttrMediaDuration);
}

- (NSNumber *)mediaPosition {
    return HAAttrNumber(self.attributes, HAAttrMediaPosition);
}

- (NSString *)mediaAppName {
    return HAAttrString(self.attributes, HAAttrAppName);
}

- (NSString *)mediaSoundMode {
    return HAAttrString(self.attributes, HAAttrSoundMode);
}

- (NSArray<NSString *> *)mediaSoundModes {
    return HAAttrArray(self.attributes, HAAttrSoundModeList) ?: @[];
}

@end
