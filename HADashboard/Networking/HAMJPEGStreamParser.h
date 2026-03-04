#import <UIKit/UIKit.h>

/// Connects to an MJPEG stream URL, parses multipart JPEG frames,
/// and delivers decoded UIImage objects to a callback.
///
/// The MJPEG format is: multipart/x-mixed-replace with each part
/// containing a JPEG image. This parser accumulates data from the
/// streaming HTTP response, detects frame boundaries, and decodes
/// each JPEG on a background thread.
@interface HAMJPEGStreamParser : NSObject

/// Called on main thread with each decoded frame image.
@property (nonatomic, copy) void (^frameHandler)(UIImage *frame);

/// Called on main thread when the stream encounters an error or ends.
@property (nonatomic, copy) void (^errorHandler)(NSError *error);

/// Start streaming from the given URL with Bearer token authorization.
- (void)startWithURL:(NSURL *)url authToken:(NSString *)token;

/// Stop the stream and cancel the connection.
- (void)stop;

/// Whether the stream is currently active.
@property (nonatomic, readonly) BOOL isStreaming;

@end
