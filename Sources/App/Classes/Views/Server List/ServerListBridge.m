#import "IRCWorld.h"
#import "IRCClient.h"
#import "IRCClientPrivate.h"
#import "IRCChannel.h"
#import "IRCTreeItemPrivate.h"
#import "TVCMainWindowPrivate.h"
#import "TVCServerList.h"
#import "TXMasterController.h"
#import "TPCPreferencesLocal.h"
#import "TXMenuController.h"
#import "ServerListBridge.h"

@implementation ServerListChannelSnapshot
@end

@implementation ServerListServerSnapshot
@end

@implementation ServerListBridge

+ (NSArray<ServerListServerSnapshot *> *)currentServers
{
	IRCWorld *world = masterController().world;

	if (world == nil) {
		return @[];
	}

	NSMutableArray *result = [NSMutableArray array];

	for (IRCClient *client in world.clientList) {
		ServerListServerSnapshot *server = [ServerListServerSnapshot new];

		server.uniqueId = client.uniqueIdentifier;
		server.name = client.label;
		server.isActive = client.isActive;
		server.isConnecting = client.isConnecting;
		server.isLoggedIn = client.isLoggedIn;
		server.isExpanded = client.sidebarItemIsExpanded;

		NSMutableArray *channels = [NSMutableArray array];

		for (IRCChannel *channel in client.channelList) {
			ServerListChannelSnapshot *snap = [ServerListChannelSnapshot new];

			snap.uniqueId = channel.uniqueIdentifier;
			snap.name = channel.label;
			snap.isActive = channel.isActive;
			snap.isChannel = channel.isChannel;
			snap.isPrivateMessage = channel.isPrivateMessage;
			snap.unreadCount = channel.treeUnreadCount;
			snap.highlightCount = channel.nicknameHighlightCount;

			[channels addObject:snap];
		}

		server.channels = channels;

		[result addObject:server];
	}

	return result;
}

+ (nullable NSString *)selectedItemId
{
	IRCTreeItem *selected = mainWindow().selectedItem;

	return selected.uniqueIdentifier;
}

+ (void)selectItemWithId:(NSString *)uniqueId
{
	IRCWorld *world = masterController().world;

	IRCTreeItem *item = [world findItemWithId:uniqueId];

	if (item == nil) {
		return;
	}

	NSOutlineView *serverList = mainWindow().serverList;

	/* Ensure the parent is expanded so the item is visible */
	if (item.isClient == NO) {
		IRCClient *parent = item.associatedClient;

		if (parent != nil && ![serverList isItemExpanded:parent]) {
			[serverList expandItem:parent];
		}
	}

	NSInteger row = [serverList rowForItem:item];

	if (row >= 0) {
		[serverList selectRowIndexes:[NSIndexSet indexSetWithIndex:row]
				byExtendingSelection:NO];
	}
}

+ (void)doubleClickItemWithId:(NSString *)uniqueId
{
	IRCWorld *world = masterController().world;

	IRCTreeItem *item = [world findItemWithId:uniqueId];

	if (item == nil) {
		return;
	}

	if (item.isClient) {
		IRCClient *client = (IRCClient *)item;

		if (client.isConnecting || client.isConnected) {
			if ([TPCPreferences disconnectOnDoubleclick]) {
				[client quit];
			}
		} else if (client.isQuitting == NO) {
			if ([TPCPreferences connectOnDoubleclick]) {
				[client connect];
			}
		}
	} else if (item.isChannel) {
		IRCClient *client = item.associatedClient;

		if (client.isLoggedIn == NO) {
			return;
		}

		IRCChannel *channel = (IRCChannel *)item;

		if (channel.isActive) {
			if ([TPCPreferences leaveOnDoubleclick]) {
				[client partChannel:channel];
			}
		} else {
			if ([TPCPreferences joinOnDoubleclick]) {
				[client joinChannel:channel];
			}
		}
	}
}

+ (nullable NSMenu *)serverContextMenu
{
	return menuController().mainMenuServerMenuItem.submenu;
}

+ (nullable NSMenu *)channelContextMenuForItem:(NSString *)uniqueId
{
	IRCWorld *world = masterController().world;

	IRCTreeItem *item = [world findItemWithId:uniqueId];

	if (item == nil) {
		return nil;
	}

	if (item.isPrivateMessage) {
		return menuController().mainMenuQueryMenu;
	}

	return menuController().mainMenuChannelMenu;
}

+ (void)performMenuAction:(NSString *)selectorName
{
	SEL selector = NSSelectorFromString(selectorName);

	id target = menuController();

	if ([target respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		[target performSelector:selector withObject:nil];
#pragma clang diagnostic pop
	}
}

+ (BOOL)isLoggingEnabled
{
	return [TPCPreferences logToDiskIsEnabled];
}

+ (void)toggleExpandedForServer:(NSString *)uniqueId
{
	IRCWorld *world = masterController().world;

	IRCTreeItem *item = [world findItemWithId:uniqueId];

	if (item == nil || item.isClient == NO) {
		return;
	}

	IRCClient *client = (IRCClient *)item;

	NSOutlineView *serverList = mainWindow().serverList;

	if ([serverList isItemExpanded:client]) {
		[serverList collapseItem:client];
	} else {
		[serverList expandItem:client];
	}
}

@end
