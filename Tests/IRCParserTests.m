/* *********************************************************************
 *
 * Unit tests for the IRC message parser (IRCMessage).
 *
 * These tests exercise initWithLine:onClient: with a nil client,
 * which skips IRCv3 capability-dependent processing but still
 * performs full structural parsing of IRC protocol lines.
 *
 *********************************************************************** */

@import XCTest;

#import "IRCMessage.h"
#import "IRCPrefix.h"
#import "IRCNumerics.h"

@interface IRCParserTests : XCTestCase
@end

@implementation IRCParserTests

#pragma mark - Basic Message Parsing

- (void)testSimplePRIVMSG
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":nick!user@host PRIVMSG #channel :Hello world" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqualObjects(msg.command, @"PRIVMSG");
	XCTAssertEqual(msg.commandNumeric, (NSUInteger)0);
	XCTAssertEqual(msg.paramsCount, (NSUInteger)2);
	XCTAssertEqualObjects([msg paramAt:0], @"#channel");
	XCTAssertEqualObjects([msg paramAt:1], @"Hello world");

	XCTAssertEqualObjects(msg.sender.nickname, @"nick");
	XCTAssertEqualObjects(msg.sender.username, @"user");
	XCTAssertEqualObjects(msg.sender.address, @"host");
	XCTAssertFalse(msg.sender.isServer);
	XCTAssertEqualObjects(msg.sender.hostmask, @"nick!user@host");
}

- (void)testSimpleJOIN
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":nick!user@host JOIN #channel" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqualObjects(msg.command, @"JOIN");
	XCTAssertEqual(msg.commandNumeric, (NSUInteger)0);
	XCTAssertEqual(msg.paramsCount, (NSUInteger)1);
	XCTAssertEqualObjects([msg paramAt:0], @"#channel");

	XCTAssertEqualObjects(msg.sender.nickname, @"nick");
	XCTAssertEqualObjects(msg.sender.username, @"user");
	XCTAssertEqualObjects(msg.sender.address, @"host");
	XCTAssertFalse(msg.sender.isServer);
}

- (void)testSimplePART
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":nick!user@host PART #channel :Leaving" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqualObjects(msg.command, @"PART");
	XCTAssertEqual(msg.paramsCount, (NSUInteger)2);
	XCTAssertEqualObjects([msg paramAt:0], @"#channel");
	XCTAssertEqualObjects([msg paramAt:1], @"Leaving");

	XCTAssertEqualObjects(msg.sender.nickname, @"nick");
}

- (void)testSimpleNICK
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":oldnick!user@host NICK newnick" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqualObjects(msg.command, @"NICK");
	XCTAssertEqual(msg.paramsCount, (NSUInteger)1);
	XCTAssertEqualObjects([msg paramAt:0], @"newnick");

	XCTAssertEqualObjects(msg.sender.nickname, @"oldnick");
	XCTAssertEqualObjects(msg.sender.username, @"user");
	XCTAssertEqualObjects(msg.sender.address, @"host");
}

- (void)testSimpleQUIT
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":nick!user@host QUIT :Quit message here" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqualObjects(msg.command, @"QUIT");
	XCTAssertEqual(msg.paramsCount, (NSUInteger)1);
	XCTAssertEqualObjects([msg paramAt:0], @"Quit message here");

	XCTAssertEqualObjects(msg.sender.nickname, @"nick");
}

- (void)testNOTICE
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":server.name NOTICE * :*** Looking up your hostname" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqualObjects(msg.command, @"NOTICE");
	XCTAssertEqual(msg.paramsCount, (NSUInteger)2);
	XCTAssertEqualObjects([msg paramAt:0], @"*");
	XCTAssertEqualObjects([msg paramAt:1], @"*** Looking up your hostname");

	/* "server.name" has no ! or @ so it is treated as a server sender */
	XCTAssertEqualObjects(msg.sender.nickname, @"server.name");
	XCTAssertTrue(msg.sender.isServer);
}

- (void)testMODE
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":nick!user@host MODE #channel +o othernick" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqualObjects(msg.command, @"MODE");
	XCTAssertEqual(msg.paramsCount, (NSUInteger)3);
	XCTAssertEqualObjects([msg paramAt:0], @"#channel");
	XCTAssertEqualObjects([msg paramAt:1], @"+o");
	XCTAssertEqualObjects([msg paramAt:2], @"othernick");

	XCTAssertEqualObjects(msg.sender.nickname, @"nick");
	XCTAssertFalse(msg.sender.isServer);
}

- (void)testKICK
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":nick!user@host KICK #channel target :reason" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqualObjects(msg.command, @"KICK");
	XCTAssertEqual(msg.paramsCount, (NSUInteger)3);
	XCTAssertEqualObjects([msg paramAt:0], @"#channel");
	XCTAssertEqualObjects([msg paramAt:1], @"target");
	XCTAssertEqualObjects([msg paramAt:2], @"reason");

	XCTAssertEqualObjects(msg.sender.nickname, @"nick");
}

#pragma mark - Numeric Replies

- (void)testNumericWelcome
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":server.name 001 mynick :Welcome to the IRC Network" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqualObjects(msg.command, @"001");
	XCTAssertEqual(msg.commandNumeric, (NSUInteger)RPL_WELCOME);
	XCTAssertEqual(msg.commandNumeric, (NSUInteger)1);
	XCTAssertEqual(msg.paramsCount, (NSUInteger)2);
	XCTAssertEqualObjects([msg paramAt:0], @"mynick");
	XCTAssertEqualObjects([msg paramAt:1], @"Welcome to the IRC Network");

	XCTAssertTrue(msg.sender.isServer);
	XCTAssertEqualObjects(msg.sender.nickname, @"server.name");
}

- (void)testNumericISUPPORT
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":server.name 005 mynick NETWORK=TestNet :are supported" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqualObjects(msg.command, @"005");
	XCTAssertEqual(msg.commandNumeric, (NSUInteger)RPL_ISUPPORT);
	XCTAssertEqual(msg.paramsCount, (NSUInteger)3);
	XCTAssertEqualObjects([msg paramAt:0], @"mynick");
	XCTAssertEqualObjects([msg paramAt:1], @"NETWORK=TestNet");
	XCTAssertEqualObjects([msg paramAt:2], @"are supported");
}

- (void)testNumericNickInUse
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":server.name 433 * newnick :Nickname is already in use" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqualObjects(msg.command, @"433");
	XCTAssertEqual(msg.commandNumeric, (NSUInteger)ERR_NICKNAMEINUSE);
	XCTAssertEqual(msg.paramsCount, (NSUInteger)3);
	XCTAssertEqualObjects([msg paramAt:0], @"*");
	XCTAssertEqualObjects([msg paramAt:1], @"newnick");
	XCTAssertEqualObjects([msg paramAt:2], @"Nickname is already in use");
}

- (void)testNumericNAMREPLY
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":server.name 353 mynick = #channel :user1 user2 user3" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqualObjects(msg.command, @"353");
	XCTAssertEqual(msg.commandNumeric, (NSUInteger)RPL_NAMEREPLY);
}

#pragma mark - Sender / Prefix Parsing

- (void)testServerSender
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":irc.server.com NOTICE * :message" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertTrue(msg.sender.isServer);
	XCTAssertEqualObjects(msg.sender.nickname, @"irc.server.com");
	XCTAssertEqualObjects(msg.sender.hostmask, @"irc.server.com");

	/* Server senders have no username or address parsed from hostmask */
	XCTAssertNil(msg.sender.username);
	XCTAssertNil(msg.sender.address);

	/* Convenience accessors on IRCMessage should mirror the sender */
	XCTAssertTrue(msg.senderIsServer);
	XCTAssertEqualObjects(msg.senderNickname, @"irc.server.com");
}

- (void)testFullHostmask
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":nick!~user@192.168.1.1 PRIVMSG #chan :test" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqualObjects(msg.sender.nickname, @"nick");
	XCTAssertEqualObjects(msg.sender.username, @"~user");
	XCTAssertEqualObjects(msg.sender.address, @"192.168.1.1");
	XCTAssertEqualObjects(msg.sender.hostmask, @"nick!~user@192.168.1.1");
	XCTAssertFalse(msg.sender.isServer);
}

- (void)testHostmaskWithCloakedHost
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":nick!user@user/cloak PRIVMSG #chan :test" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqualObjects(msg.sender.nickname, @"nick");
	XCTAssertEqualObjects(msg.sender.username, @"user");
	XCTAssertEqualObjects(msg.sender.address, @"user/cloak");
	XCTAssertFalse(msg.sender.isServer);
}

- (void)testHostmaskWithIPv6Address
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":nick!user@2001:db8::1 PRIVMSG #chan :test" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqualObjects(msg.sender.nickname, @"nick");
	XCTAssertEqualObjects(msg.sender.username, @"user");
	/* The address parser uses lastIndexOf('@') so IPv6 colons do not confuse it */
	XCTAssertEqualObjects(msg.sender.address, @"2001:db8::1");
	XCTAssertFalse(msg.sender.isServer);
}

- (void)testSenderConvenienceAccessors
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":alice!ident@some.host PRIVMSG #test :hi" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqualObjects(msg.senderNickname, @"alice");
	XCTAssertEqualObjects(msg.senderUsername, @"ident");
	XCTAssertEqualObjects(msg.senderAddress, @"some.host");
	XCTAssertEqualObjects(msg.senderHostmask, @"alice!ident@some.host");
	XCTAssertFalse(msg.senderIsServer);
}

#pragma mark - Parameter Edge Cases

- (void)testTrailingParamWithColons
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":nick!user@host PRIVMSG #chan :Hello: world: test" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqual(msg.paramsCount, (NSUInteger)2);
	XCTAssertEqualObjects([msg paramAt:0], @"#chan");
	XCTAssertEqualObjects([msg paramAt:1], @"Hello: world: test");
}

- (void)testEmptyTrailingParam
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":nick!user@host PRIVMSG #chan :" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqual(msg.paramsCount, (NSUInteger)2);
	XCTAssertEqualObjects([msg paramAt:0], @"#chan");
	XCTAssertEqualObjects([msg paramAt:1], @"");
}

- (void)testNoTrailingParam
{
	/* PING with no sender prefix and no trailing colon parameter */
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@"PING server.name" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqualObjects(msg.command, @"PING");
	XCTAssertEqual(msg.paramsCount, (NSUInteger)1);
	XCTAssertEqualObjects([msg paramAt:0], @"server.name");
}

- (void)testMultipleMiddleParams
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":server 353 nick = #channel :user1 user2 user3" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqual(msg.paramsCount, (NSUInteger)4);
	XCTAssertEqualObjects([msg paramAt:0], @"nick");
	XCTAssertEqualObjects([msg paramAt:1], @"=");
	XCTAssertEqualObjects([msg paramAt:2], @"#channel");
	XCTAssertEqualObjects([msg paramAt:3], @"user1 user2 user3");
}

- (void)testParamAtBeyondBounds
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":nick!user@host PRIVMSG #chan :hello" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqual(msg.paramsCount, (NSUInteger)2);

	/* paramAt: returns empty string for out-of-bounds indices */
	XCTAssertEqualObjects([msg paramAt:5], @"");
	XCTAssertEqualObjects([msg paramAt:99], @"");
}

- (void)testTrailingParamWithLeadingSpaces
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":nick!user@host PRIVMSG #chan :  spaced  message  " onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqual(msg.paramsCount, (NSUInteger)2);
	/* Everything after the leading ':' in the trailing param is preserved as-is */
	XCTAssertEqualObjects([msg paramAt:1], @"  spaced  message  ");
}

- (void)testOnlyTrailingParam
{
	/* A message where the only parameter is a trailing one */
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":nick!user@host QUIT :Gone fishing" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqualObjects(msg.command, @"QUIT");
	XCTAssertEqual(msg.paramsCount, (NSUInteger)1);
	XCTAssertEqualObjects([msg paramAt:0], @"Gone fishing");
}

#pragma mark - Command Case Handling

- (void)testCommandUppercased
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":nick!user@host privmsg #chan :test" onClient:nil];

	XCTAssertNotNil(msg);
	/* Non-numeric commands are always uppercased by the parser */
	XCTAssertEqualObjects(msg.command, @"PRIVMSG");
	XCTAssertEqual(msg.commandNumeric, (NSUInteger)0);
}

- (void)testCommandMixedCaseUppercased
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":nick!user@host NoTiCe #chan :test" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqualObjects(msg.command, @"NOTICE");
}

- (void)testNumericCommandNotUppercased
{
	/* Numeric commands should be stored as-is (they are digits) */
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":server 001 nick :Welcome" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqualObjects(msg.command, @"001");
	XCTAssertEqual(msg.commandNumeric, (NSUInteger)1);
}

#pragma mark - Edge Cases

- (void)testEmptyLine
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@"" onClient:nil];

	/* An empty line produces no command, so parseLine: returns NO and init returns nil */
	XCTAssertNil(msg);
}

- (void)testReceivedAtIsPopulated
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":nick!user@host PRIVMSG #chan :test" onClient:nil];

	XCTAssertNotNil(msg);
	/* receivedAt should be a recent date (within the last few seconds) */
	XCTAssertNotNil(msg.receivedAt);
	NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:msg.receivedAt];
	XCTAssertLessThan(elapsed, 5.0);
}

- (void)testIsHistoricDefaultsToNO
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":nick!user@host PRIVMSG #chan :test" onClient:nil];

	XCTAssertNotNil(msg);
	/* Without a client that supports server-time, isHistoric is NO */
	XCTAssertFalse(msg.isHistoric);
}

- (void)testMessageTagsParsedWithNilClient
{
	/* Even with a nil client, the extension info (@tags) is parsed into messageTags.
	   Only capability-dependent processing (time, batch) is skipped. */
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@"@aaa=bbb;ccc :nick!user@host PRIVMSG #chan :tagged" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqualObjects(msg.command, @"PRIVMSG");
	XCTAssertEqualObjects([msg paramAt:1], @"tagged");

	/* The tags dictionary should contain the parsed key-value pairs */
	XCTAssertNotNil(msg.messageTags);
	XCTAssertEqualObjects(msg.messageTags[@"aaa"], @"bbb");
	/* A tag with no value ("ccc") should have an empty string value */
	XCTAssertNotNil(msg.messageTags[@"ccc"]);
}

- (void)testSenderOnlyColonReturnsNil
{
	/* A line with just ":" as sender and nothing else should fail parsing */
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":" onClient:nil];

	XCTAssertNil(msg);
}

- (void)testCommandOnlyNoParams
{
	/* A bare command with no sender and no parameters */
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@"QUIT" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqualObjects(msg.command, @"QUIT");
	XCTAssertEqual(msg.paramsCount, (NSUInteger)0);
	XCTAssertEqualObjects([msg paramAt:0], @"");
}

- (void)testDefaultSenderWhenNoPrefixAndNilClient
{
	/* When there's no ":" prefix and client is nil, the sender is constructed
	   from client.serverAddress which is nil. The sender should still be
	   initialized (via populateDefaultsPostflight) as a non-nil object. */
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@"PING :timestamp" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertNotNil(msg.sender);
	XCTAssertEqualObjects(msg.command, @"PING");
	XCTAssertEqual(msg.paramsCount, (NSUInteger)1);
	XCTAssertEqualObjects([msg paramAt:0], @"timestamp");
}

#pragma mark - Sequence Method

- (void)testSequenceReturnsJoinedParams
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":server 005 nick NETWORK=Test MODES=4 :are supported" onClient:nil];

	XCTAssertNotNil(msg);

	/* sequence with index 0 joins all params from index 0 onward */
	NSString *seqFrom0 = [msg sequence:0];
	XCTAssertTrue([seqFrom0 containsString:@"nick"]);
	XCTAssertTrue([seqFrom0 containsString:@"NETWORK=Test"]);

	/* sequence with index 1 joins from index 1 onward */
	NSString *seqFrom1 = [msg sequence:1];
	XCTAssertTrue([seqFrom1 containsString:@"NETWORK=Test"]);

	/* The default sequence property starts from index 1 when there are >= 2 params */
	NSString *defaultSeq = msg.sequence;
	XCTAssertEqualObjects(defaultSeq, seqFrom1);
}

#pragma mark - Various IRC Commands

- (void)testTOPICCommand
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":nick!user@host TOPIC #channel :New topic for the channel" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqualObjects(msg.command, @"TOPIC");
	XCTAssertEqual(msg.paramsCount, (NSUInteger)2);
	XCTAssertEqualObjects([msg paramAt:0], @"#channel");
	XCTAssertEqualObjects([msg paramAt:1], @"New topic for the channel");
}

- (void)testINVITECommand
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":nick!user@host INVITE target #channel" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqualObjects(msg.command, @"INVITE");
	XCTAssertEqual(msg.paramsCount, (NSUInteger)2);
	XCTAssertEqualObjects([msg paramAt:0], @"target");
	XCTAssertEqualObjects([msg paramAt:1], @"#channel");
}

- (void)testNumericMOTD
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":server.name 372 mynick :- Welcome to the server MOTD" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqualObjects(msg.command, @"372");
	XCTAssertEqual(msg.commandNumeric, (NSUInteger)RPL_MOTD);
	XCTAssertEqualObjects([msg paramAt:0], @"mynick");
	XCTAssertEqualObjects([msg paramAt:1], @"- Welcome to the server MOTD");
}

- (void)testNumericEndOfMOTD
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":server.name 376 mynick :End of /MOTD command." onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqual(msg.commandNumeric, (NSUInteger)RPL_ENDOFMOTD);
}

- (void)testNumericChannelModeIs
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@":server 324 nick #channel +nt" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqual(msg.commandNumeric, (NSUInteger)RPL_CHANNELMODEIS);
	XCTAssertEqual(msg.paramsCount, (NSUInteger)3);
	XCTAssertEqualObjects([msg paramAt:0], @"nick");
	XCTAssertEqualObjects([msg paramAt:1], @"#channel");
	XCTAssertEqualObjects([msg paramAt:2], @"+nt");
}

- (void)testERROR
{
	IRCMessage *msg = [[IRCMessage alloc] initWithLine:@"ERROR :Closing Link: nick[host] (Quit: leaving)" onClient:nil];

	XCTAssertNotNil(msg);
	XCTAssertEqualObjects(msg.command, @"ERROR");
	XCTAssertEqual(msg.paramsCount, (NSUInteger)1);
	XCTAssertEqualObjects([msg paramAt:0], @"Closing Link: nick[host] (Quit: leaving)");
}

@end
