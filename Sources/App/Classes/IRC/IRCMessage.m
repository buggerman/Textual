/* *********************************************************************
 *                  _____         _               _
 *                 |_   _|____  _| |_ _   _  __ _| |
 *                   | |/ _ \ \/ / __| | | |/ _` | |
 *                   | |  __/>  <| |_| |_| | (_| | |
 *                   |_|\___/_/\_\\__|\__,_|\__,_|_|
 *
 * Copyright (c) 2008 - 2010 Satoshi Nakagawa <psychs AT limechat DOT net>
 * Copyright (c) 2010 - 2018 Codeux Software, LLC & respective contributors.
 *       Please see Acknowledgements.pdf for additional information.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *  * Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *  * Neither the name of Textual, "Codeux Software, LLC", nor the
 *    names of its contributors may be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 *********************************************************************** */

#import "NSObjectHelperPrivate.h"
#import "NSStringHelper.h"
#import "TXGlobalModelsPrivate.h"
#import "IRCClientPrivate.h"
#import "IRCPrefix.h"
#import "IRCLineParserPrivate.h"
#import "IRCMessageInternal.h"

NS_ASSUME_NONNULL_BEGIN

@implementation IRCMessage

DESIGNATED_INITIALIZER_EXCEPTION_BODY_BEGIN
- (instancetype)init
{
	if ((self = [super init])) {
		[self populateDefaultsPostflight];

		return self;
	}

	return nil;
}
DESIGNATED_INITIALIZER_EXCEPTION_BODY_END

- (nullable instancetype)initWithLine:(NSString *)line
{
	return [self initWithLine:line onClient:nil];
}

- (nullable instancetype)initWithLine:(NSString *)line onClient:(nullable IRCClient *)client
{
	if ((self = [super init])) {
		BOOL parseResult = [self parseLine:line forClient:client];

		if (parseResult == NO) {
			return nil;
		}

		[self populateDefaultsPostflight];

		return self;
	}

	return nil;
}

- (void)populateDefaultsPostflight
{
	SetVariableIfNil(self->_command, @"")
	SetVariableIfNil(self->_messageTags, @{})
	SetVariableIfNil(self->_params, @[])
	SetVariableIfNil(self->_receivedAt, [NSDate date])
	SetVariableIfNil(self->_sender, [IRCPrefix new])
}

- (NSUInteger)paramsCount
{
	return self.params.count;
}

- (NSString *)paramAt:(NSUInteger)index
{
	if (index < self.params.count) {
		return self.params[index];
	}

	return @"";
}

- (NSString *)sequence
{
	if (self.params.count < 2) {
		return [self sequence:0];
	} else {
		return [self sequence:1];
	}
}

- (NSString *)sequence:(NSUInteger)index
{
	NSMutableString *sequence = [NSMutableString string];

	NSArray *params = self.params;

	NSUInteger paramsCount = params.count;

	for (NSUInteger i = index; i < paramsCount; i++) {
		NSString *param = params[i];

		if (i != index) {
			[sequence appendString:@" "];
		}

		[sequence appendString:param];
	}

	return [sequence copy];
}

- (void)markAsNotHistoric
{
	self->_isHistoric = NO;
}

- (nullable NSString *)senderNickname
{
	return self.sender.nickname;
}

- (nullable NSString *)senderUsername
{
	return self.sender.username;
}

- (nullable NSString *)senderAddress
{
	return self.sender.address;
}

- (nullable NSString *)senderHostmask
{
	return self.sender.hostmask;
}

- (BOOL)senderIsServer
{
	return self.sender.isServer;
}

- (void)populateDuringCopy:(__kindof XRPortablePropertyObject *)newObject mutableCopy:(BOOL)mutableCopy
{
	IRCMessage *object = (IRCMessage *)newObject;

	object->_batchToken = self->_batchToken;
	object->_command = self->_command;
	object->_commandNumeric = self->_commandNumeric;
	object->_isHistoric = self->_isHistoric;
	object->_isEventOnlyMessage = self->_isEventOnlyMessage;
	object->_isPrintOnlyMessage = self->_isPrintOnlyMessage;
	object->_messageTags = self->_messageTags;
	object->_params = self->_params;
	object->_receivedAt = self->_receivedAt;
	object->_sender = self->_sender;
}

- (__kindof XRPortablePropertyObject *)mutableClass
{
	return [IRCMessageMutable self];
}

@end

#pragma mark -

@implementation IRCMessage (IRCMessageLineParser)

- (BOOL)parseLine:(NSString *)line forClient:(nullable IRCClient *)client
{
	NSParameterAssert(line != nil);

	/* Delegate structural parsing to the Swift IRCLineParser */
	IRCLineParserResult *result = [IRCLineParser parse:line];

	if (result == nil) {
		return NO;
	}

	/* Populate command */
	self->_command = result.command;
	self->_commandNumeric = result.commandNumeric;

	/* Populate parameters */
	self->_params = result.params;

	/* Populate message tags (raw) */
	if (result.tags.count > 0) {
		self->_messageTags = result.tags;
	}

	/* Populate sender */
	if (result.senderString != nil) {
		IRCPrefixMutable *sender = [IRCPrefixMutable new];

		sender.hostmask = result.senderString;

		if (result.senderIsServer) {
			sender.nickname = result.senderNickname;
			sender.isServer = YES;
		} else {
			sender.nickname = result.senderNickname;
			sender.username = result.senderUsername;
			sender.address = result.senderAddress;
		}

		self->_sender = [sender copy];
	} else {
		/* No sender prefix — use server address from client */
		NSString * _Nonnull serverAddress = (NSString * _Nonnull)client.serverAddress;

		IRCPrefixMutable *sender = [IRCPrefixMutable new];

		sender.nickname = serverAddress;
		sender.hostmask = serverAddress;
		sender.isServer = YES;

		self->_sender = [sender copy];
	}

	/* Process IRCv3 extensions that depend on client capabilities */
	[self processExtensions:result.tags forClient:client];

	/* Return success */
	return YES;
}

- (void)processExtensions:(NSDictionary<NSString *, NSString *> *)extensions forClient:(nullable IRCClient *)client
{
	/* If there is no client, then further processing is not possible */
	if (client == nil) {
		return;
	}

	/* Check for known capacities */
	if ([client isCapabilityEnabled:ClientIRCv3SupportedCapabilityServerTime]) {
		/* We support two time extensions. The time= value is the date and
		 time in the format as defined by ISO 8601:2004(E) 4.3.2. */
		/* The t= value is a legacy value in a epoch time. We always favor
		 the new time= format over the old. */
		NSString *dateString = extensions[@"time"];

		if (dateString == nil) {
			dateString = extensions[@"t"];
		}

		if (dateString) {
			NSDate *dateObject = nil;

			if ([dateString onlyContainsCharactersFromCharacterSet:[NSCharacterSet ZeroToNineDecimalCharacterSet]]) {
				dateObject = [NSDate dateWithTimeIntervalSince1970:dateString.doubleValue];
			} else {
				dateObject = [TXSharedISOStandardDateFormatter() dateFromString:dateString];
			}

			if (dateObject) {
				self->_receivedAt = [dateObject copy];

				self->_isHistoric = YES;
			}
		}
	}

	if ([client isCapabilityEnabled:ClientIRCv3SupportedCapabilityBatch]) {
		NSString *batchToken = extensions[@"batch"];

		if ([batchToken onlyContainsCharactersFromCharacterSet:[NSCharacterSet Ato9UnderscoreDash]]) {
			self->_batchToken = [batchToken copy];

			self->_parentBatchMessage = [client queuedBatchMessageWithToken:batchToken];
		}
	}
}


@end

#pragma mark -

@implementation IRCMessageMutable

@dynamic batchToken;
@dynamic command;
@dynamic commandNumeric;
@dynamic isHistoric;
@dynamic isEventOnlyMessage;
@dynamic isPrintOnlyMessage;
@dynamic messageTags;
@dynamic params;
@dynamic receivedAt;
@dynamic sender;

+ (BOOL)isMutable
{
	return YES;
}

- (__kindof XRPortablePropertyObject *)immutableClass
{
	return [IRCMessage self];
}

- (void)setBatchToken:(nullable NSString *)batchToken
{
	if (self->_batchToken != batchToken) {
		self->_batchToken = [batchToken copy];
	}
}

- (void)setCommand:(NSString *)command
{
	NSParameterAssert(command != nil);

	if (self->_command != command) {
		self->_command = [command copy];
	}
}

- (void)setCommandNumeric:(NSUInteger)commandNumeric
{
	if (self->_commandNumeric != commandNumeric) {
		self->_commandNumeric = commandNumeric;
	}
}

- (void)setIsHistoric:(BOOL)isHistoric
{
	if (self->_isHistoric != isHistoric) {
		self->_isHistoric = isHistoric;
	}
}

- (void)setIsEventOnlyMessage:(BOOL)isEventOnlyMessage
{
	if (self->_isEventOnlyMessage != isEventOnlyMessage) {
		self->_isEventOnlyMessage = isEventOnlyMessage;
	}
}

- (void)setIsPrintOnlyMessage:(BOOL)isPrintOnlyMessage
{
	if (self->_isPrintOnlyMessage != isPrintOnlyMessage) {
		self->_isPrintOnlyMessage = isPrintOnlyMessage;
	}
}

- (void)setMessageTags:(nullable NSDictionary<NSString *, NSString *> *)messageTags
{
	if (self->_messageTags != messageTags) {
		self->_messageTags = [messageTags copy];
	}
}

- (void)setParams:(NSArray<NSString *> *)params
{
	NSParameterAssert(params != nil);

	if (self->_params != params) {
		self->_params = [params copy];
	}
}

- (void)setReceivedAt:(NSDate *)receivedAt
{
	NSParameterAssert(receivedAt != nil);

	if (self->_receivedAt != receivedAt) {
		self->_receivedAt = [receivedAt copy];
	}
}

- (void)setSender:(IRCPrefix *)sender
{
	NSParameterAssert(sender != nil);

	if (self->_sender != sender) {
		self->_sender = [sender copy];
	}
}

@end

NS_ASSUME_NONNULL_END
