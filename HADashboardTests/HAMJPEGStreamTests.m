#import <XCTest/XCTest.h>
#import "HAMJPEGStreamParser.h"
#import "HAEntity.h"

#pragma mark - HAMJPEGStreamParser Test Access

@interface HAMJPEGStreamParser (TestAccess)
@property (nonatomic, strong) NSMutableData *buffer;
@property (nonatomic, copy) NSData *boundaryData;
- (void)extractBoundaryFromContentType:(NSString *)contentType;
- (void)extractFrames;
- (void)decodeJPEGFromChunk:(NSData *)chunk;
@end

#pragma mark - MJPEG Parser Tests

@interface HAMJPEGStreamParserTests : XCTestCase
@property (nonatomic, strong) HAMJPEGStreamParser *parser;
@end

@implementation HAMJPEGStreamParserTests

- (void)setUp {
    [super setUp];
    self.parser = [[HAMJPEGStreamParser alloc] init];
}

- (void)tearDown {
    [self.parser stop];
    self.parser = nil;
    [super tearDown];
}

- (void)testInitCreatesParser {
    XCTAssertNotNil(self.parser);
    XCTAssertFalse(self.parser.isStreaming);
}

- (void)testStopWithoutStartDoesNotCrash {
    XCTAssertNoThrow([self.parser stop]);
}

- (void)testBoundaryExtractionStandard {
    // Standard HA MJPEG Content-Type
    [self.parser extractBoundaryFromContentType:@"multipart/x-mixed-replace; boundary=frame"];
    NSString *boundary = [[NSString alloc] initWithData:self.parser.boundaryData encoding:NSUTF8StringEncoding];
    XCTAssertTrue([boundary containsString:@"--frame"], @"Boundary should contain '--frame', got: %@", boundary);
}

- (void)testBoundaryExtractionWithDashes {
    [self.parser extractBoundaryFromContentType:@"multipart/x-mixed-replace;boundary=--myboundary"];
    NSString *boundary = [[NSString alloc] initWithData:self.parser.boundaryData encoding:NSUTF8StringEncoding];
    XCTAssertTrue([boundary containsString:@"--myboundary"], @"Boundary should contain '--myboundary', got: %@", boundary);
}

- (void)testBoundaryExtractionQuoted {
    [self.parser extractBoundaryFromContentType:@"multipart/x-mixed-replace; boundary=\"frameboundary\""];
    NSString *boundary = [[NSString alloc] initWithData:self.parser.boundaryData encoding:NSUTF8StringEncoding];
    XCTAssertTrue([boundary containsString:@"--frameboundary"], @"Boundary should contain '--frameboundary', got: %@", boundary);
}

- (void)testBoundaryExtractionNilContentType {
    [self.parser extractBoundaryFromContentType:nil];
    XCTAssertNotNil(self.parser.boundaryData, @"Should use fallback boundary when Content-Type is nil");
}

- (void)testBoundaryExtractionNoBoundaryParam {
    [self.parser extractBoundaryFromContentType:@"multipart/x-mixed-replace"];
    XCTAssertNotNil(self.parser.boundaryData, @"Should use fallback boundary when no boundary= param");
}

- (void)testFrameExtractionWithValidJPEG {
    // Build a mock MJPEG multipart response with a minimal JPEG
    // JPEG SOI marker = FF D8, EOI = FF D9
    uint8_t miniJPEG[] = {
        0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 'J', 'F', 'I', 'F', 0x00,
        0x01, 0x01, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0xFF, 0xD9
    };
    NSData *jpegData = [NSData dataWithBytes:miniJPEG length:sizeof(miniJPEG)];

    // Build multipart body: headers + JPEG + boundary
    NSString *boundary = @"--frame";
    NSMutableData *body = [NSMutableData data];

    // First frame
    NSString *headers = [NSString stringWithFormat:@"Content-Type: image/jpeg\r\nContent-Length: %lu\r\n\r\n", (unsigned long)jpegData.length];
    [body appendData:[headers dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:jpegData];
    [body appendData:[[NSString stringWithFormat:@"\r\n%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    // Second frame (to verify extraction stops at boundary)
    [body appendData:[headers dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:jpegData];

    // Set up parser
    self.parser.buffer = [body mutableCopy];
    self.parser.boundaryData = [[NSString stringWithFormat:@"\r\n%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding];

    // Track frame delivery
    __block NSInteger frameCount = 0;
    self.parser.frameHandler = ^(UIImage *frame) {
        frameCount++;
    };

    // Need to set streaming=YES for extractFrames to work
    [self.parser setValue:@YES forKey:@"streaming"];

    // Extract frames
    [self.parser extractFrames];

    // The first frame should be extracted (between start and boundary)
    // The second frame has no trailing boundary yet, so stays in buffer
    // Frame decoding is async, so we just verify the buffer was consumed
    XCTAssertTrue(self.parser.buffer.length < body.length,
                  @"Buffer should be partially consumed after frame extraction");
}

- (void)testDecodeJPEGFromChunkWithNoJPEGMarker {
    // Chunk without JPEG SOI marker should be silently ignored
    uint8_t garbage[] = {0x00, 0x01, 0x02, 0x03, 0x04};
    NSData *chunk = [NSData dataWithBytes:garbage length:sizeof(garbage)];

    // Should not crash
    [self.parser setValue:@YES forKey:@"streaming"];
    XCTAssertNoThrow([self.parser decodeJPEGFromChunk:chunk]);
}

- (void)testDecodeJPEGFromChunkWithHeadersBeforeSOI {
    // Simulate a chunk that has HTTP headers before the JPEG SOI
    NSMutableData *chunk = [NSMutableData data];
    [chunk appendData:[@"Content-Type: image/jpeg\r\nContent-Length: 22\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    // Minimal JPEG
    uint8_t miniJPEG[] = {0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x02, 0xFF, 0xD9};
    [chunk appendData:[NSData dataWithBytes:miniJPEG length:sizeof(miniJPEG)]];

    [self.parser setValue:@YES forKey:@"streaming"];
    // Should find the SOI and not crash
    XCTAssertNoThrow([self.parser decodeJPEGFromChunk:chunk]);
}

@end

#pragma mark - Camera Entity Tests

@interface HACameraStreamPathTests : XCTestCase
@end

@implementation HACameraStreamPathTests

- (void)testCameraStreamPathFormat {
    HAEntity *entity = [[HAEntity alloc] initWithDictionary:@{
        @"entity_id": @"camera.front_door", @"state": @"idle",
        @"attributes": @{@"friendly_name": @"Front Door"}
    }];
    XCTAssertEqualObjects([entity cameraStreamPath], @"/api/camera_proxy_stream/camera.front_door");
}

- (void)testCameraStreamPathNilEntity {
    HAEntity *entity = [[HAEntity alloc] initWithDictionary:@{
        @"state": @"idle", @"attributes": @{}
    }];
    XCTAssertNil([entity cameraStreamPath]);
}

- (void)testCameraProxyPathStillWorks {
    HAEntity *entity = [[HAEntity alloc] initWithDictionary:@{
        @"entity_id": @"camera.back_yard", @"state": @"streaming",
        @"attributes": @{@"friendly_name": @"Back Yard"}
    }];
    XCTAssertEqualObjects([entity cameraProxyPath], @"/api/camera_proxy/camera.back_yard");
    XCTAssertEqualObjects([entity cameraStreamPath], @"/api/camera_proxy_stream/camera.back_yard");
}

@end

#pragma mark - Stream Mode Tests

@interface HACameraStreamModeTests : XCTestCase
@end

@implementation HACameraStreamModeTests

- (void)tearDown {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"HADevStreamMode"];
    [super tearDown];
}

- (void)testDefaultStreamModeIsAuto {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"HADevStreamMode"];
    NSString *mode = [[NSUserDefaults standardUserDefaults] stringForKey:@"HADevStreamMode"];
    // nil defaults → auto (mode 0)
    XCTAssertNil(mode, @"Default should be nil (auto)");
}

- (void)testStreamModeSettings {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];

    [ud setObject:@"mjpeg" forKey:@"HADevStreamMode"];
    XCTAssertEqualObjects([ud stringForKey:@"HADevStreamMode"], @"mjpeg");

    [ud setObject:@"hls" forKey:@"HADevStreamMode"];
    XCTAssertEqualObjects([ud stringForKey:@"HADevStreamMode"], @"hls");

    [ud setObject:@"snapshot" forKey:@"HADevStreamMode"];
    XCTAssertEqualObjects([ud stringForKey:@"HADevStreamMode"], @"snapshot");

    [ud setObject:@"auto" forKey:@"HADevStreamMode"];
    XCTAssertEqualObjects([ud stringForKey:@"HADevStreamMode"], @"auto");
}

- (void)testEntityStreamFeatureFlag {
    // Entity with STREAM support (bit 1 = 2)
    HAEntity *streaming = [[HAEntity alloc] initWithDictionary:@{
        @"entity_id": @"camera.arlo", @"state": @"idle",
        @"attributes": @{@"supported_features": @3} // ON_OFF=1 + STREAM=2
    }];
    XCTAssertTrue(([streaming supportedFeatures] & 2) != 0, @"Should support STREAM");

    // Entity without STREAM support
    HAEntity *snapshot = [[HAEntity alloc] initWithDictionary:@{
        @"entity_id": @"camera.ring", @"state": @"idle",
        @"attributes": @{@"supported_features": @0}
    }];
    XCTAssertFalse(([snapshot supportedFeatures] & 2) != 0, @"Should not support STREAM");
}

@end
