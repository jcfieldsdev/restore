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

#import "FileVersion.h"

@interface Document : NSDocument

@property(copy) NSURL *URL;
@property(retain) FileVersion *currentVersion;
@property(retain) NSArray *previousVersions;

- (instancetype)init;
- (FileVersion *)getVersion:(NSInteger)index;
- (BOOL)reloadVersions;
- (BOOL)restoreVersion:(NSUInteger)index destination:(NSURL *)destination error:(NSError **)errorPtr;
- (BOOL)deleteVersion:(NSUInteger)index error:(NSError **)errorPtr;
- (BOOL)deleteAllVersions:(NSError **)errorPtr;

@end
