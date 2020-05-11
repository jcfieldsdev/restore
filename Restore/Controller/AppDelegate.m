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

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    NSString *tempDir = NSTemporaryDirectory();
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // clears temporary directory on exit
    for (NSString *file in [fileManager contentsOfDirectoryAtPath:tempDir error:nil]) {
        NSString *path = [tempDir stringByAppendingPathComponent:file];
        [fileManager removeItemAtPath:path error:nil];
    }
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender {
    return NO;
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
    return NO;
}

@end