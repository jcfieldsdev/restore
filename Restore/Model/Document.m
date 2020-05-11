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

#import "Document.h"

@implementation Document

- (instancetype)init {
    self = [super init];
    
    if (self != nil) {
        _URL = nil;
        _currentVersion = nil;
        _previousVersions = nil;
    }
    
    return self;
}

+ (BOOL)autosavesInPlace {
    return NO;
}

- (void)makeWindowControllers {
    NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    [self addWindowController:[storyboard instantiateControllerWithIdentifier:@"Document Window Controller"]];
}

- (BOOL)readFromURL:(NSURL *)URL ofType:(NSString *)typeName error:(NSError **)errorPtr {
    _URL = URL;
    
    return [self reloadVersions];
}

- (FileVersion *)getVersion:(NSInteger)index {
    if (index < 0) {
        return nil;
    }
    
    FileVersion *version = nil;
    
    if (index < [self.previousVersions count]) {
        version = [self.previousVersions objectAtIndex:index];
    } else {
        version = self.currentVersion;
    }
    
    return version;
}

- (BOOL)reloadVersions {
    _currentVersion = (FileVersion *)[FileVersion currentVersionOfItemAtURL:self.URL];
    _previousVersions = [FileVersion otherVersionsOfItemAtURL:self.URL];
    
    return YES;
}

- (BOOL)restoreVersion:(NSUInteger)index destination:(NSURL *)destination error:(NSError **)errorPtr {
    NSInteger count = [self.previousVersions count];
    
    if (count == 0 || index > count) {
        return NO;
    }
    
    if (index < count) { // previous version
        FileVersion *version = [self.previousVersions objectAtIndex:index];
        [version replaceItemAtURL:destination options:0 error:errorPtr];
    } else { // current version
        // writes current version to new file and matches modification time
        NSData *contents = [[NSData alloc] initWithContentsOfURL:self.URL options:0 error:errorPtr];
        NSDate *mtime = [self.currentVersion modificationDate];
        NSDictionary* attr = [NSDictionary dictionaryWithObjectsAndKeys:mtime, NSFileModificationDate, nil];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createFileAtPath:[destination path] contents:contents attributes:attr];
    }
    
    return *errorPtr == nil;
}

- (BOOL)deleteVersion:(NSUInteger)index error:(NSError **)errorPtr {
    NSInteger count = [self.previousVersions count];
    
    if (count == 0 || index > count) {
        return NO;
    }
    
    if (index < count) { // previous version
        FileVersion *version = [self.previousVersions objectAtIndex:index];
        return [version removeAndReturnError:errorPtr];
    } else { // current version
        // replaces current version with previous version, then deletes previous version
        [self restoreVersion:count - 1 destination:[self.currentVersion URL] error:errorPtr];
        [self deleteVersion:count - 1 error:errorPtr];
        
        return *errorPtr == nil;
    }
}

- (BOOL)deleteAllVersions:(NSError **)errorPtr {
    NSInteger count = [self.previousVersions count];
    
    if (count == 0) {
        return NO;
    }
    
    return [FileVersion removeOtherVersionsOfItemAtURL:self.URL error:errorPtr];
}

@end
