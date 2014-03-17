#import <Cocoa/Cocoa.h>

@interface ICMRenderer : NSObject

- (id)init;
- (void)dealloc;

- (void)enterImageSurfaceAtX:(const int32_t)x andY:(const int32_t)y withZoom:(const int32_t)zoom andSurface:(cairo_surface_t*)xrsurf;
- (void)drawStroke:(ICMBrushStroke*)br;

- (void*)getWrappedObject;

@end
