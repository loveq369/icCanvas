#import <icCanvasManagerObjC.h>
#include <icCanvasManager.hpp>

@implementation ICMRenderer {
    icCanvasManager::RefPtr<icCanvasManager::Renderer> _wrapped;
}

- (id)init {
    self = [super init];
    
    if (self != nil) {
        self->_wrapped = new icCanvasManager::Renderer();
    }
    
    return self;
};

- (id)initFromWrappedObject:(void*)optr {
    self = [super init];
    
    if (self != nil) {
        self->_wrapped = (icCanvasManager::Renderer*)optr;
    }
    
    return self;
};

- (void)enterSurfaceAtX:(const int32_t)x andY:(const int32_t)y withZoom:(const int32_t)zoom andSurface:(cairo_surface_t*)xrsurf withHeight:(const int)height andWidth:(const int)width {
    self->_wrapped->enterSurface(x, y, zoom, xrsurf, height, width);
};

- (void)enterImageSurfaceAtX:(const int32_t)x andY:(const int32_t)y withZoom:(const int32_t)zoom andSurface:(cairo_surface_t*)xrsurf {
    self->_wrapped->enterImageSurface(x, y, zoom, xrsurf);
};

- (void)drawStroke:(ICMBrushStroke*)br {
    icCanvasManager::RefPtr<icCanvasManager::BrushStroke> cppbr = (icCanvasManager::BrushStroke*)[br getWrappedObject];
    self->_wrapped->drawStroke(cppbr);
};

- (void*)getWrappedObject {
    return (void*)self->_wrapped;
};

@end