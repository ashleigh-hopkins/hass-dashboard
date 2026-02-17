#import "HABaseEntityCell.h"

@interface HAAlarmEntityCell : HABaseEntityCell

/// Height when code keypad is visible (code_format is non-nil).
+ (CGFloat)preferredHeightWithKeypad;

/// Height without keypad (no code required).
+ (CGFloat)preferredHeightWithoutKeypad;

@end
