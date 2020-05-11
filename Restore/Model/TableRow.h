/*
 * Copyright (C) 2020 J.C. Fields (jcfields@jcfields.dev).
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 */

@import Cocoa;
@import Quartz;

#import "FileVersion.h"

NS_ASSUME_NONNULL_BEGIN

@interface TableRow : NSObject <QLPreviewItem>

@property(retain) FileVersion *version;
@property(assign, readonly) BOOL current;
@property(assign, readonly) NSUInteger index;
@property(weak, readonly) NSString *name;
@property(weak, readonly) NSDate *datetime;
@property(assign, readonly) NSUInteger size;
@property(weak, readonly) NSString *formattedIndex;
@property(weak, readonly) NSString *formattedDatetime;
@property(weak, readonly) NSString *formattedSize;

- (instancetype)initWithFileVersion:(FileVersion *)version index:(NSUInteger)index current:(BOOL)current;

@end

NS_ASSUME_NONNULL_END
