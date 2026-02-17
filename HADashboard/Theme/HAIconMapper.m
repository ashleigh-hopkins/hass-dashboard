#import "HAIconMapper.h"
#import <CoreText/CoreText.h>

static NSString *_mdiFontName = nil;
static NSDictionary<NSString *, NSNumber *> *_codepointMap = nil;
static NSDictionary<NSString *, NSString *> *_domainIconMap = nil;

@implementation HAIconMapper

+ (void)initialize {
    if (self != [HAIconMapper class]) return;
    [self loadFont];
    [self loadCodepoints];
    [self buildDomainMap];
}

+ (void)loadFont {
    NSString *fontPath = [[NSBundle mainBundle] pathForResource:@"materialdesignicons-webfont" ofType:@"ttf"];
    if (!fontPath) {
        NSLog(@"[HAIconMapper] MDI font file not found in bundle");
        return;
    }

    NSData *fontData = [NSData dataWithContentsOfFile:fontPath];
    if (!fontData) return;

    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)fontData);
    CGFontRef cgFont = CGFontCreateWithDataProvider(provider);
    CGDataProviderRelease(provider);
    if (!cgFont) return;

    CFErrorRef error = NULL;
    if (!CTFontManagerRegisterGraphicsFont(cgFont, &error)) {
        if (error) CFRelease(error);
    }

    CFStringRef psName = CGFontCopyPostScriptName(cgFont);
    if (psName) {
        _mdiFontName = (__bridge_transfer NSString *)psName;
    }
    CGFontRelease(cgFont);
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
    (void)[UIFont monospacedDigitSystemFontOfSize:57 weight:UIFontWeightRegular];
    // Warm the medium-weight system font used by labels
    (void)[UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
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
