#import <icCanvasAppKit.h>

static const NSInteger _MARGINS_LABEL_BOTTOM = 15;

@interface ICAKDockablePanel ()

- (void)dockablePanelSetupSubviews;

@end

@implementation ICAKDockablePanel {
    NSTextView* _label;
    NSView* _content;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
};

- (void)dockablePanelSetupSubviews {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    self->_label = [[NSTextView alloc] init];
    [self addSubview:self->_label];
    
    self->_label.editable = NO;
    self->_label.selectable = NO;
    self->_label.drawsBackground = NO;
    self->_label.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self->_label attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self->_label attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self->_label attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self->_label attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    
    self->_content = nil;
    
    self.style = ICAKDockableViewStylePanel;
};

- (id)init {
    self = [super init];
    
    if (self != nil) {
        [self dockablePanelSetupSubviews];
    }
    
    return self;
}

- (NSView*)contentView {
    return self->_content;
};

- (void)setContentView:(NSView*)view {
    if (self->_content != nil) {
        [self->_content removeFromSuperview];
    }
    
    self->_content = view;
    self->_content.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self->_content];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self->_content attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self->_content attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self->_content attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self->_label attribute:NSLayoutAttributeBottom multiplier:1.0 constant:_MARGINS_LABEL_BOTTOM]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self->_content attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
};

- (void)setLabel:(NSString*)lbl {
    self->_label.textStorage.mutableString.string = lbl;
};

@end