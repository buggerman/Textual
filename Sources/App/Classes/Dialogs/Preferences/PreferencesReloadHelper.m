#import "PreferencesReloadHelper.h"
#import "TPCPreferencesReload.h"

@implementation PreferencesReloadHelper

+ (void)performReload:(NSUInteger)action
{
	[TPCPreferences performReloadAction:(TPCPreferencesReloadAction)action];
}

@end
