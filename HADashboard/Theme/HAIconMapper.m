#import "HAIconMapper.h"
#import "HALog.h"
#import "UIFont+HACompat.h"
#import <CoreText/CoreText.h>

static NSString *_mdiFontName = nil;
static NSDictionary<NSString *, NSNumber *> *_codepointMap = nil;
static NSDictionary<NSString *, NSString *> *_domainIconMap = nil;

@implementation HAIconMapper

+ (void)initialize {
    if (self != [HAIconMapper class]) return;
    HALogD(@"icon", @"HAIconMapper +initialize BEGIN");
    HALogD(@"icon", @"  loadFont BEGIN");
    [self loadFont];
    HALogD(@"icon", @"  loadFont END");
    HALogD(@"icon", @"  loadCodepoints BEGIN");
    [self loadCodepoints];
    HALogD(@"icon", @"  loadCodepoints END");
    HALogD(@"icon", @"  buildDomainMap BEGIN");
    [self buildDomainMap];
    HALogD(@"icon", @"  buildDomainMap END");
    HALogD(@"icon", @"HAIconMapper +initialize END");
}

+ (void)loadFont {
    // The font file is declared in Info.plist UIAppFonts, so iOS registers it
    // automatically at launch. We must NOT use CGFontCreateWithDataProvider or
    // CTFontManagerRegisterGraphicsFont here — both make IPC calls to the font
    // daemon that block the main thread indefinitely on jailbroken iOS 9,
    // causing a watchdog kill (0x8badf00d).
    //
    // Instead, look up the PostScript name from the already-registered font
    // by scanning the font family list. This is pure in-process work.
    HALogD(@"icon", @"    loadFont: scanning registered font families");
    for (NSString *family in [UIFont familyNames]) {
        for (NSString *name in [UIFont fontNamesForFamilyName:family]) {
            // MDI font PostScript name contains "materialdesignicons"
            if ([name.lowercaseString rangeOfString:@"materialdesignicons"].location != NSNotFound) {
                _mdiFontName = name;
                HALogD(@"icon", @"    loadFont: found name=%@", _mdiFontName);
                return;
            }
        }
    }

    // Fallback: if UIAppFonts didn't register the font (shouldn't happen),
    // try the known PostScript name directly
    if ([UIFont fontWithName:@"materialdesignicons-webfont" size:12]) {
        _mdiFontName = @"materialdesignicons-webfont";
        HALogD(@"icon", @"    loadFont: using fallback name");
        return;
    }

    HALogD(@"icon", @"    loadFont: MDI font NOT FOUND in registered fonts");
    HALogE(@"icon", @"MDI font not found — is it listed in UIAppFonts?");
}

+ (void)loadCodepoints {
    NSString *tsvPath = [[NSBundle mainBundle] pathForResource:@"mdi-codepoints" ofType:@"tsv"];
    if (!tsvPath) {
        _codepointMap = @{};
        return;
    }

    NSString *content = [NSString stringWithContentsOfFile:tsvPath encoding:NSUTF8StringEncoding error:nil];
    if (!content) { _codepointMap = @{}; return; }

    NSMutableDictionary *map = [NSMutableDictionary dictionaryWithCapacity:7500];
    for (NSString *line in [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]) {
        NSArray *parts = [line componentsSeparatedByString:@"\t"];
        if (parts.count < 2) continue;
        unsigned int codepoint = 0;
        [[NSScanner scannerWithString:parts[1]] scanHexInt:&codepoint];
        if (codepoint > 0) {
            map[parts[0]] = @(codepoint);
        }
    }
    _codepointMap = [map copy];
}

+ (void)buildDomainMap {
    _domainIconMap = @{
        @"light":               @"lightbulb",
        @"switch":              @"toggle-switch",
        @"sensor":              @"eye",
        @"binary_sensor":       @"checkbox-blank-circle-outline",
        @"climate":             @"thermometer",
        @"cover":               @"window-shutter",
        @"fan":                 @"fan",
        @"lock":                @"lock",
        @"camera":              @"video",
        @"media_player":        @"cast",
        @"weather":             @"weather-partly-cloudy",
        @"person":              @"account",
        @"scene":               @"palette",
        @"script":              @"script-text",
        @"automation":          @"robot",
        @"input_boolean":       @"toggle-switch-outline",
        @"input_number":        @"ray-vertex",
        @"input_select":        @"format-list-bulleted",
        @"input_text":          @"form-textbox",
        @"input_datetime":      @"calendar-clock",
        @"input_button":        @"gesture-tap-button",
        @"button":              @"gesture-tap-button",
        @"number":              @"ray-vertex",
        @"select":              @"format-list-bulleted",
        @"humidifier":          @"air-humidifier",
        @"vacuum":              @"robot-vacuum",
        @"alarm_control_panel": @"shield-home",
        @"timer":               @"timer-outline",
        @"counter":             @"counter",
        @"update":              @"package-up",
        @"siren":               @"bullhorn",
        @"water_heater":        @"thermometer",
    };
}

#pragma mark - Public API

+ (void)warmFonts {
    // Triggers +initialize (loadFont + loadCodepoints + buildDomainMap) and warms
    // font descriptor caches so the first cell render doesn't pay the full cost.
    (void)[self mdiFontOfSize:16];
    // Warm the monospaced digit system font used by thermostat gauge (57pt primary)
    if ([UIFont respondsToSelector:@selector(monospacedDigitSystemFontOfSize:weight:)]) {
        (void)[UIFont monospacedDigitSystemFontOfSize:57 weight:HAFontWeightRegular];
    }
    // Warm the medium-weight system font used by labels
    if ([UIFont respondsToSelector:@selector(systemFontOfSize:weight:)]) {
        (void)[UIFont systemFontOfSize:16 weight:HAFontWeightMedium];
    } else {
        (void)[UIFont boldSystemFontOfSize:16]; // iOS 5 fallback
    }
}

+ (NSString *)mdiFontName { return _mdiFontName; }

+ (UIFont *)mdiFontOfSize:(CGFloat)size {
    if (!_mdiFontName) return [UIFont systemFontOfSize:size];
    return [UIFont fontWithName:_mdiFontName size:size] ?: [UIFont systemFontOfSize:size];
}

+ (NSString *)glyphForIconName:(NSString *)mdiName {
    if (!mdiName || mdiName.length == 0) return nil;
    NSString *name = [mdiName lowercaseString];
    if ([name hasPrefix:@"mdi:"]) name = [name substringFromIndex:4];

    NSNumber *codepoint = _codepointMap[name];
    if (!codepoint) return nil;

    uint32_t cp = [codepoint unsignedIntValue];
    if (cp <= 0xFFFF) {
        unichar ch = (unichar)cp;
        return [NSString stringWithCharacters:&ch length:1];
    }
    uint32_t offset = cp - 0x10000;
    unichar pair[2] = { (unichar)(0xD800 + (offset >> 10)), (unichar)(0xDC00 + (offset & 0x3FF)) };
    return [NSString stringWithCharacters:pair length:2];
}

+ (NSString *)glyphForDomain:(NSString *)domain {
    NSString *name = _domainIconMap[domain];
    return name ? [self glyphForIconName:name] : nil;
}

@end
