#import <Cocoa/Cocoa.h>

#include <cairo.h>

@interface ICMBrushStroke : NSObject

- (id)init;
- (id)initFromWrappedObject:(void*)optr;

- (void)penBeginWithX:(int32_t)x andY:(int32_t)y;
- (void)penBeginWithPressure:(int32_t) pressure;
- (void)penBeginWithTilt:(int32_t)tilt andAngle:(int32_t) angle;
- (void)penBeginWithDeltaX:(int32_t)delta_x andDeltaY:(int32_t)delta_y;
- (void)penToFromControlPointX:(int32_t)fromcp_x andY:(int32_t)fromcp_y toControlPointX:(int32_t)tocp_x andY:(int32_t)tocp_y toX:(int32_t)to_x andY:(int32_t)to_y;
- (void)penToFromControlPointPressure:(int32_t)fromcp_pressure toControlPointPressure:(int32_t)tocp_pressure toPressure:(int32_t)to_pressure;
- (void)penToFromControlPointTilt:(int32_t)fromcp_tilt andAngle:(int32_t)fromcp_angle toControlPointTilt:(int32_t)tocp_tilt andAngle:(int32_t)tocp_angle toTilt:(int32_t)to_tilt andAngle:(int32_t)to_angle;
- (void)penToFromControlPointDeltaX:(int32_t)fromcp_delta_x andDeltaY:(int32_t)fromcp_delta_y toControlPointDeltaX:(int32_t)tocp_delta_x andDeltaY:(int32_t)tocp_delta_y toDeltaX:(int32_t)to_delta_x andDeltaY:(int32_t)to_delta_y;
- (void)penExtendWithContinuityLevel:(int) lvl;
- (void)penBack;

- (cairo_rectangle_t)boundingBox;

- (void*)getWrappedObject;

@end
