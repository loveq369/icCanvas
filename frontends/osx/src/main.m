#import <Cocoa/Cocoa.h>
#import <icCanvasAppKit.h>

int main (int argc, char* argv[]) {
    [NSApplication sharedApplication];
    
    NSApplicationDelegate* theDelegate = [[ICAKAppDelegate alloc] init];
    [NSApp setDelegate:theDelegate]:
    [NSApp run];
}