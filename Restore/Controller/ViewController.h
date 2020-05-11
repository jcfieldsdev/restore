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

#import "Document.h"
#import "FileVersion.h"
#import "TableRow.h"

@interface ViewController : NSViewController <NSTableViewDelegate, QLPreviewPanelDataSource, QLPreviewPanelDelegate>

@property(strong) QLPreviewPanel *previewPanel;
@property(nonatomic) NSMutableArray *rows;
@property(nonatomic, copy) NSIndexSet *selectedIndexes;
@property(nonatomic, copy) NSArray *selectedItems;
@property(weak) IBOutlet NSArrayController *arrayController;
@property(weak) IBOutlet NSTableView *tableView;

- (void)showErrorMessage:(NSString *)message error:(NSError *)error;
- (void)validateToolbar;
- (IBAction)doOpen:(id)sender;
- (IBAction)doRestore:(id)sender;
- (IBAction)doReplace:(id)sender;
- (IBAction)doDelete:(id)sender;
- (IBAction)doDeleteAll:(id)sender;
- (IBAction)togglePreviewPanel:(id)panel;
- (IBAction)doHelp:(id)sender;

@end
