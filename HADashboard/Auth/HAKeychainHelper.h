#import <Foundation/Foundation.h>

@interface HAKeychainHelper : NSObject

+ (BOOL)setString:(NSString *)value forKey:(NSString *)key;
+ (NSString *)stringForKey:(NSString *)key;
+ (BOOL)removeItemForKey:(NSString *)key;

@end
