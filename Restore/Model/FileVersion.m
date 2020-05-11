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

#import "FileVersion.h"

@implementation FileVersion

- (instancetype)init {
    self = [super init];
    
    if (self != nil) {
        _temporaryFileURL = nil;
    }
    
    return self;
}

- (NSURL *)createTemporaryFile:(NSError **)errorPtr {
    // does not rewrite temporary file if it already exists
    if (self.temporaryFileURL != nil) {
        return self.temporaryFileURL;
    }
    
    NSString *tempDirName = NSTemporaryDirectory();
    NSString *tempFileName = [[NSUUID UUID] UUIDString];
    NSString *extension = [[self URL] pathExtension];
    
    if ([extension length] > 0) {
        tempFileName = [tempFileName stringByAppendingFormat:@".%@", extension];
    }
    
    NSURL *tempFileURL = [NSURL fileURLWithPath:[tempDirName stringByAppendingPathComponent:tempFileName]];
    
    NSData *contents = [[NSData alloc] initWithContentsOfURL:self.URL options:0 error:errorPtr];
    [contents writeToURL:tempFileURL options:0 error:errorPtr];
    
    _temporaryFileURL = tempFileURL;
    
    return tempFileURL;
}

@end
