#import <icCanvasManagerObjC.h>
#import <icCanvasAppKit.h>

#include <cairo.h>
#include <cairo-quartz.h>

@implementation ICAKCanvasView {
    ICMCanvasView* internal;
    ICMDrawing* drawing;
}

- (id)initWithDrawing:(ICMDrawing*) theDrawing {
    self = [super init];
    
    if (self != nil) {
        self->internal = [[ICMCanvasView alloc] init];
        self->drawing = theDrawing;
        
        [self->internal attachDrawing:self->drawing];
    }
    
    return self;
};

- (id)initWithFrame:(NSRect)frameRect andDrawing:(ICMDrawing*) theDrawing {
    self = [super initWithFrame:frameRect];
    
    if (self != nil) {
        self->internal = [[ICMCanvasView alloc] init];
        self->drawing = theDrawing;
        
        [self->internal attachDrawing:self->drawing];
    }
    
    return self;
};

- (BOOL)isFlipped {
    return YES;
};

- (void)drawRect:(NSRect)dirtyRect {
    //Not-so-toll-free bridging
    NSGraphicsContext* cocoaContext = [NSGraphicsContext currentContext];
    CGContextRef cgContext = (CGContextRef)[cocoaContext graphicsPort];
    
    CGContextSaveGState(cgContext);
    
    cairo_surface_t* xrsurf = cairo_quartz_surface_create_for_cg_context(cgContext, (unsigned int)self.bounds.size.width, (unsigned int)self.bounds.size.height);
    cairo_t* ctxt = cairo_create(xrsurf);
    cairo_rectangle_t cr_dirty = {dirtyRect.origin.x, dirtyRect.origin.y, dirtyRect.size.width, dirtyRect.size.height};
    
    const NSRect* dirty_list;
    NSInteger dirty_list_count;
    [self getRectsBeingDrawn:&dirty_list count:&dirty_list_count];
    
    cairo_reset_clip(ctxt);
    for (NSInteger i = 0; i < dirty_list_count; i++) {
        cairo_move_to(ctxt, dirty_list[i].origin.x, dirty_list[i].origin.y);
        cairo_line_to(ctxt, dirty_list[i].origin.x + dirty_list[i].size.width, dirty_list[i].origin.y);
        cairo_line_to(ctxt, dirty_list[i].origin.x + dirty_list[i].size.width, dirty_list[i].origin.y + dirty_list[i].size.height);
        cairo_line_to(ctxt, dirty_list[i].origin.x, dirty_list[i].origin.y + dirty_list[i].size.height);
        cairo_line_to(ctxt, dirty_list[i].origin.x, dirty_list[i].origin.y);
        cairo_clip(ctxt);
    }
    
    NSSize testSize = {1.0, 1.0};
    NSSize scaleSize = [self convertSizeToBacking:testSize];
    
    [self->internal setSizeWidth:self.bounds.size.width andHeight:self.bounds.size.height andUiScale:scaleSize.width];
    [self->internal drawWithContext:ctxt];
    
    CGContextRestoreGState(cgContext);
    
    cairo_destroy(ctxt);
    cairo_surface_destroy(xrsurf);
};

- (void)mouseDown:(NSEvent*)theEvent {
    NSPoint event_location = [theEvent locationInWindow];
    NSPoint local_point = [self convertPoint:event_location fromView:nil];
    
    [self->internal mouseDownWithX:local_point.x andY:local_point.y andDeltaX:theEvent.deltaX andDeltaY:theEvent.deltaY];
};

- (void)mouseDragged:(NSEvent*)theEvent {
    NSPoint event_location = [theEvent locationInWindow];
    NSPoint local_point = [self convertPoint:event_location fromView:nil];
    
    [self->internal mouseDragWithX:local_point.x andY:local_point.y andDeltaX:theEvent.deltaX andDeltaY:theEvent.deltaY];
};

- (void)mouseUp:(NSEvent*)theEvent {
    NSPoint event_location = [theEvent locationInWindow];
    NSPoint local_point = [self convertPoint:event_location fromView:nil];
    
    [self->internal mouseUpWithX:local_point.x andY:local_point.y andDeltaX:theEvent.deltaX andDeltaY:theEvent.deltaY];
};

- (void)sizeToFitCanvas {
    NSSize testSize = {1.0, 1.0};
    NSSize scaleSize = [self convertSizeToBacking:testSize];
    
    double pwidth, pheight;
    [self->internal setSizeUiScale:scaleSize.width];
    [self->internal getSizeWidth:&pwidth andHeight:&pheight andUiScale:NULL];
    
    NSRect bounds = {-pwidth/2.0, -pheight/2.0, pwidth/2.0, pheight/2.0};
    
    [self setFrame: bounds];
};

- (void)setDrawing:(ICMDrawing*)drawing {
    self->drawing = drawing;
    [self->internal attachDrawing:drawing];
};

- (ICMDrawing*)drawing {
    return self->drawing;
};

@end