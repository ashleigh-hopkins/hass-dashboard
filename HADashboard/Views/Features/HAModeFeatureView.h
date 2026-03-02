#import "HATileFeatureView.h"

/// Mode selector tile feature for HVAC modes, climate preset modes, climate fan modes,
/// and alarm modes. Supports two styles:
/// - "icons" (default): horizontal row of pill-shaped buttons, active mode highlighted
/// - "dropdown": single button that shows an action sheet picker
@interface HAModeFeatureView : HATileFeatureView
@end
