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

#import "ViewController.h"

NSString *const kWebSiteURL = @"https://github.com/jcfieldsdev/restore";

@implementation ViewController

- (void)viewWillAppear {
    [super viewWillAppear];
    
    _rows = [NSMutableArray array];
    _selectedIndexes = [NSIndexSet indexSet];
    _selectedItems = [NSArray array];
    
    NSWindowController *windowController = [[self.view window] windowController];
    Document *document = [windowController document];
    self.representedObject = document;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    for (NSTableColumn *tableColumn in [self.tableView tableColumns]) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor
            sortDescriptorWithKey:[tableColumn identifier]
            ascending:YES
            selector:@selector(compare:)];
        tableColumn.sortDescriptorPrototype = sortDescriptor;
    }
    
    [self reloadData];
    [self.tableView reloadData];
    [self validateToolbar];
}

- (void)reloadData {
    NSMutableArray *rows  = [NSMutableArray array];
    NSUInteger index = 0;
    
    for (FileVersion *version in [self.representedObject previousVersions]) {
        TableRow *tableRow = [[TableRow alloc] initWithFileVersion:version index:index current:NO];
        [rows addObject:tableRow];
        
        index++;
    }
    
    FileVersion *version = [self.representedObject currentVersion];
    TableRow *tableRow = [[TableRow alloc] initWithFileVersion:version index:index current:YES];
    [rows addObject:tableRow];
    
    self.rows = rows;
    self.arrayController.content = [NSArray arrayWithArray:rows];
}

- (void)setSelectedIndexes:(NSIndexSet *)indexSet {
    if (indexSet != _selectedIndexes) {
        indexSet = [indexSet copy];
        _selectedIndexes = indexSet;
        self.selectedItems = [self.arrayController.content objectsAtIndexes:indexSet];
    }
}

- (void)setSelectedItems:(NSArray *)items {
    if (items != _selectedItems) {
        items = [items copy];
        _selectedItems = items;
        [self.previewPanel reloadData];
    }
}

- (void)showErrorMessage:(NSString *)message error:(NSError *)error {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = NSAlertStyleCritical;
    alert.messageText = message;
    
    if (error != nil) {
        alert.informativeText = [error localizedDescription];
    }
    
    [alert addButtonWithTitle:@"OK"];
    [alert runModal];
}

- (void)validateToolbar {
    NSToolbar *toolbar = [[self.view window] toolbar];
    BOOL selected = [self.tableView selectedRow] >= 0;
    
    for (NSToolbarItem *toolbarItem in [toolbar visibleItems]) {
        BOOL state = selected;
        NSString *label = [toolbarItem label];

        if (selected && [label isEqual:@"Replace"]) {
            state = [self.tableView selectedRow] != [self.tableView numberOfRows] - 1;
        } else if ((selected && [label isEqual:@"Delete"]) || [label isEqual:@"Delete All"]) {
            state = [self.tableView numberOfRows] > 1;
        }
        
        toolbarItem.enabled = state;
    }
}

#pragma mark - NSMenuItemValidation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    SEL action = [menuItem action];
    BOOL selected = [self.tableView selectedRow] >= 0;
    
    if (action == @selector(doHelp:)) {
        return YES;
    }
    
    if (action == @selector(doOpen:) || action == @selector(doRestore:)) {
        return selected;
    }
    
    if (action == @selector(doReplace:)) {
        // disables Replace for current version
        return selected && [self.tableView selectedRow] != [self.tableView numberOfRows] - 1;
    }
    
    if (action == @selector(doDelete:)) {
        // disables Delete if no version selected or no previous versions
        return selected && [self.tableView numberOfRows] > 1;
    }
    
    if (action == @selector(doDeleteAll:)) {
        // disables Delete All if no previous versions
        return [self.tableView numberOfRows] > 1;
    }
    
    if (action == @selector(togglePreviewPanel:)) {
        if ([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel] isVisible]) {
            menuItem.title = NSLocalizedString(@"Close Quick Look", "");
        } else {
            menuItem.title = NSLocalizedString(@"Open Quick Look", "");
        }
        
        return YES;
    }
    
    return NO;
}

#pragma mark - NSResponder

- (void)keyDown:(NSEvent *)event {
    NSUInteger keyCode = [event keyCode];
    
    if (keyCode == 49) { // space bar opens quick look
        [self togglePreviewPanel:self];
    } else {
        [super keyDown:event];
    }
}

#pragma mark - IBAction

- (IBAction)doOpen:(id)sender {
    NSUInteger selected = [self.selectedIndexes firstIndex];
    
    if (self.representedObject != nil && selected != NSNotFound) {
        TableRow *tableRow = [self.selectedItems firstObject];
        FileVersion *version = [tableRow version];
        
        NSError *error = nil;
        NSURL *URL = nil;
        
        if ([tableRow current]) {
            URL = [version URL];
        } else {
            URL = [version createTemporaryFile:&error];
        }

        if (error != nil) {
            [self showErrorMessage:@"Could not open version." error:error];
        } else {
            NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
            [workspace openURL:URL];
        }
    }
}

- (IBAction)doRestore:(id)sender {
    NSUInteger selected = [self.selectedIndexes firstIndex];
    
    if (self.representedObject != nil && selected != NSNotFound) {
        TableRow *tableRow = [self.selectedItems firstObject];
        FileVersion *version = [tableRow version];
        
        NSSavePanel *panel = [NSSavePanel savePanel];
        panel.nameFieldStringValue = [version localizedName];
        
        [panel beginSheetModalForWindow:[self.view window] completionHandler:^(NSInteger result) {
            if (result == NSModalResponseOK) {
                NSError *error = nil;
                [self.representedObject restoreVersion:[tableRow index] destination:[panel URL] error:&error];
                
                if (error != nil) {
                    [self showErrorMessage:@"Could not restore version." error:error];
                }
            }
        }];
    }
}

- (IBAction)doReplace:(id)sender {
    NSUInteger selected = [self.selectedIndexes firstIndex];
    
    if (self.representedObject != nil && selected != NSNotFound) {
        TableRow *tableRow = [self.selectedItems firstObject];
        FileVersion *version = [self.representedObject currentVersion];
        
        NSAlert *alert = [[NSAlert alloc] init];
        alert.alertStyle = NSAlertStyleWarning;
        alert.messageText = @"This will replace the current version of the file with the selected revision.";
        alert.informativeText = @"You will lose the current version of the file if you do not have a copy of it somewhere else.";
        [alert addButtonWithTitle:@"Replace"];
        [alert addButtonWithTitle:@"Cancel"];
        
        if ([alert runModal] == NSAlertFirstButtonReturn) {
            NSError *error = nil;
            [self.representedObject restoreVersion:[tableRow index] destination:[version URL] error:&error];
            
            if (error != nil) {
                [self showErrorMessage:@"Could not replace version." error:error];
            } else {
                [self.representedObject reloadVersions];
                [self reloadData];
                [self.tableView reloadData];
                [self.previewPanel reloadData];
            }
        }
    }
}

- (IBAction)doDelete:(id)sender {
    NSUInteger selected = [self.selectedIndexes firstIndex];
    
    if (self.representedObject != nil && selected != NSNotFound) {
        TableRow *tableRow = [self.selectedItems firstObject];
        
        NSAlert *alert = [[NSAlert alloc] init];
        alert.alertStyle = NSAlertStyleWarning;
        alert.messageText = @"This will delete the selected revision of the file.";
        alert.informativeText = @"This action is irreversible.";
        [alert addButtonWithTitle:@"Delete"];
        [alert addButtonWithTitle:@"Cancel"];
        
        if ([alert runModal] == NSAlertFirstButtonReturn) {
            NSError *error = nil;
            [self.representedObject deleteVersion:[tableRow index] error:&error];
            
            if (error != nil) {
                [self showErrorMessage:@"Could not delete version." error:error];
            } else {
                NSIndexSet *selected = [self.tableView selectedRowIndexes];
                
                [self.representedObject reloadVersions];
                [self reloadData];
                [self.tableView reloadData];
                
                // re-selects row after deleted version
                [self.tableView selectRowIndexes:selected byExtendingSelection:NO];
                [self.previewPanel reloadData];
            }
        }
    }
}

- (IBAction)doDeleteAll:(id)sender {
    if (self.representedObject != nil) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.alertStyle = NSAlertStyleWarning;
        alert.messageText = @"This will delete all previous versions of the file.";
        alert.informativeText = @"The current version will not be deleted. This action is irreversible.";
        [alert addButtonWithTitle:@"Delete All"];
        [alert addButtonWithTitle:@"Cancel"];
        
        if ([alert runModal] == NSAlertFirstButtonReturn) {
            NSError *error = nil;
            [self.representedObject deleteAllVersions:&error];
            
            if (error != nil) {
                [self showErrorMessage:@"Could not delete versions." error:error];
            } else {
                [self.representedObject reloadVersions];
                [self reloadData];
                [self.tableView reloadData];
                [self.previewPanel reloadData];
            }
        }
    }
}

- (IBAction)togglePreviewPanel:(id)panel {
    QLPreviewPanel *previewPanel = [QLPreviewPanel sharedPreviewPanel];
    
    if ([QLPreviewPanel sharedPreviewPanelExists] && [previewPanel isVisible]) {
        [previewPanel orderOut:nil];
    } else {
        [previewPanel makeKeyAndOrderFront:nil];
        [previewPanel reloadData];
    }
}

- (IBAction)doHelp:(id)sender {
    NSURL *URL = [[NSURL alloc] initWithString:kWebSiteURL];
    [[NSWorkspace sharedWorkspace] openURL:URL];
}

#pragma mark - NSTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    if ([self.tableView isEqual:[notification object]]) {
        if (self.previewPanel != nil && [self.previewPanel isVisible]) {
            [self.previewPanel reloadData];
        }
    }
    
    [self validateToolbar];
}

- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)sortDescriptors {
    self.arrayController.content = [self.rows sortedArrayUsingDescriptors:sortDescriptors];
    [tableView reloadData];
}

#pragma mark - QLPreviewPanelDelegate

- (BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel {
    return YES;
}

- (BOOL)previewPanel:(QLPreviewPanel *)panel handleEvent:(NSEvent *)event {
    if ([event type] == NSEventTypeKeyDown) {
        [self.tableView keyDown:event];
        return YES;
    }
    
    return NO;
}

- (void)beginPreviewPanelControl:(QLPreviewPanel *)panel {
    _previewPanel = panel;
    
    panel.dataSource = self;
    panel.delegate = self;
}

- (void)endPreviewPanelControl:(QLPreviewPanel *)panel {
    _previewPanel = nil;
}

#pragma mark - QLPreviewPanelDataSource

- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel {
    if (self.representedObject != nil) {
        return [self.selectedItems count];
    }
    
    return 0;
}

- (id<QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index {
    if (self.representedObject != nil && [self.selectedItems count] > 0) {
        return [self.selectedItems objectAtIndex:index];
    }
    
    return nil;
}

@end
