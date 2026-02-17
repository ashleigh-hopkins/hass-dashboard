#import <UIKit/UIKit.h>

/// Maps MDI (Material Design Icons) icon names from Home Assistant to font glyphs.
/// Uses the bundled materialdesignicons-webfont.ttf for crisp vector icons.
@interface HAIconMapper : NSObject

/// Preload MDI font and warm system font caches. Call early at app launch.
+ (void)warmFonts;

/// The MDI font name (after registration). Nil if font failed to load.
+ (NSString *)mdiFontName;

/// Returns a UIFont for MDI icons at the given size.
+ (UIFont *)mdiFontOfSize:(CGFloat)size;

/// Returns a plain NSString containing the single Unicode character for the icon.
/// Nil if the icon name is not recognized.
+ (NSString *)glyphForIconName:(NSString *)mdiName;

/// Convenience: returns a glyph string for a domain's default icon.
+ (NSString *)glyphForDomain:(NSString *)domain;

@end
