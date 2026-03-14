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

/// Render an MDI icon name to a UIImage using CoreText. Works on iOS 5+
/// where UILabel can't render Supplementary Private Use Area codepoints.
/// Returns nil if the icon name is not recognized or the font isn't loaded.
+ (UIImage *)imageForIconName:(NSString *)mdiName size:(CGFloat)size color:(UIColor *)color;

/// Set an MDI glyph on a UILabel. On iOS 6+, sets text directly. On iOS 5,
/// renders via CoreText into a UIImageView overlay.
+ (void)setGlyph:(NSString *)glyphString onLabel:(UILabel *)label;

/// Set an MDI glyph on a UIButton. On iOS 6+, uses setTitle: with MDI font.
/// On iOS 5, uses setImage: with CoreText-rendered image.
+ (void)setIconName:(NSString *)iconName onButton:(UIButton *)button size:(CGFloat)size color:(UIColor *)color;

/// Build an NSAttributedString containing an MDI glyph inline. On iOS 6+,
/// uses the glyph character with MDI font. On iOS 5, inserts an
/// NSTextAttachment image (iOS 7+) or returns the plain glyph string (best effort).
+ (NSAttributedString *)attributedGlyph:(NSString *)glyphString fontSize:(CGFloat)fontSize color:(UIColor *)color;

/// Set icon + text on a label pair. On iOS 6+, uses a single attributed string
/// on textLabel. On iOS 5, renders the icon in iconLabel (MDI font) and plain
/// text in textLabel (system font) — two separate labels to avoid font mixing.
/// Pass nil for glyphString to hide the icon label and show text only.
+ (void)setIconGlyph:(NSString *)glyphString
            iconSize:(CGFloat)iconSize
           iconColor:(UIColor *)iconColor
         onIconLabel:(UILabel *)iconLabel
                text:(NSString *)text
            textFont:(UIFont *)textFont
           textColor:(UIColor *)textColor
         onTextLabel:(UILabel *)textLabel;

@end
