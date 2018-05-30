/* *********************************************************************
 *                  _____         _               _
 *                 |_   _|____  _| |_ _   _  __ _| |
 *                   | |/ _ \ \/ / __| | | |/ _` | |
 *                   | |  __/>  <| |_| |_| | (_| | |
 *                   |_|\___/_/\_\\__|\__,_|\__,_|_|
 *
 * Copyright (c) 2017, 2018 Codeux Software, LLC & respective contributors.
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

#import "ICMImgurGifv.h"

NS_ASSUME_NONNULL_BEGIN

@interface ICMImgurGifv ()
@property (readonly, copy, class) NSArray<NSString *> *validFileExtensions;
@end

@implementation ICMImgurGifv

+ (nullable ICLInlineContentModuleActionBlock)actionBlockForURL:(NSURL *)url
{
	NSString *address = [self _finalAddressForURL:url];

	if (address == nil) {
		return nil;
	}

	return [super actionBlockForAddress:address];
}

+ (nullable NSString *)_finalAddressForURL:(NSURL *)url
{
	NSString *urlPath = url.path.percentEncodedURLPath;

	if (urlPath.length <= 1) {
		return nil;
	}

	urlPath = [urlPath substringFromIndex:1]; // "/"

	NSString *fileExtension = urlPath.pathExtension;

	if ([self.validFileExtensions containsObject:fileExtension] == NO) {
		return nil;
	}

	NSString *videoIdentifier = urlPath.stringByDeletingPathExtension;

	if (videoIdentifier.isAlphabeticNumericOnly == NO) {
		return nil;
	}

	return [NSString stringWithFormat:@"https://i.imgur.com/%@.mp4", videoIdentifier];
}

+ (nullable NSArray<NSString *> *)domains
{
	static NSArray<NSString *> *domains = nil;

	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		domains =
		@[
		  @"i.imgur.com"
		];
	});

	return domains;
}

+ (NSArray<NSString *> *)validFileExtensions
{
	static NSArray<NSString *> *cachedValue = nil;

	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		cachedValue =
		@[@"mp4",
		  @"gif",
		  @"gifv",
		  @"webp"];
	});

	return cachedValue;
}

+ (BOOL)contentIsFile
{
	return YES;
}

- (void)finalizePreflight
{
	self.payload.classAttribute = @"inlineImgurGifv";
}

@end

NS_ASSUME_NONNULL_END
