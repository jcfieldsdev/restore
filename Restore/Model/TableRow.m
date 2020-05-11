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

#import "TableRow.h"

@implementation TableRow

- (instancetype)initWithFileVersion:(FileVersion *)version index:(NSUInteger)index current:(BOOL)current {
    self = [super init];
    
    if (self != nil) {
        _version = version;
        _index = index;
        _current = current;
    }
    
    return self;
}

- (NSString *)name {
    return [self.version localizedName];
}

- (NSDate *)datetime {
    return [self.version modificationDate];
}

- (NSUInteger)size {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [[self.version URL] path];
    NSError *error = nil;
    NSDictionary *attr = [fileManager attributesOfItemAtPath:path error:&error];
    
    NSUInteger fileSize = 0;
    
    if (error == nil && attr != nil) {
       fileSize = [attr fileSize];
    }
    
    return fileSize;
}

- (NSString *)formattedIndex {
    return [NSString stringWithFormat:@"%lu", self.index + 1];
}

- (NSString *)formattedDatetime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterMediumStyle;
    dateFormatter.doesRelativeDateFormatting = YES;
    
    return [dateFormatter stringFromDate:self.datetime];
}

- (NSString *)formattedSize {
    NSByteCountFormatter *sizeFormatter = [[NSByteCountFormatter alloc] init];
    sizeFormatter.countStyle = NSByteCountFormatterCountStyleFile;
    
    return [sizeFormatter stringFromByteCount:self.size];
}

#pragma mark - QLPreviewItem

- (NSURL *)previewItemURL {
    return [self.version URL];
}

- (NSString *)previewItemTitle {
    return [self.version localizedName];
}

@end
