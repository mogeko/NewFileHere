//
//  FinderSync.swift
//  NewFileHereFinderExtension
//
//  Created by 郑钧益 on 2022. 04. 01..
//

import Cocoa
import FinderSync

class FinderSync: FIFinderSync {
    
    let fileTypes = [
        FileType("Markdown", "md"),
        FileType("Microsoft Word", "docx"),
        FileType("Microsoft Excel", "xlsx"),
        FileType("Microsoft PowerPoint", "pptx"),
        FileType("Text file", "txt")
    ]
    
    override init() {
        super.init()
        
        NSLog("FinderSync() launched from %@", Bundle.main.bundlePath as NSString)
        
        // Set up the directory we are syncing.
        let finderSync = FIFinderSyncController.default()
        if let mountedVolumes = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: nil,
                                                                      options: [.skipHiddenVolumes]) {
                finderSync.directoryURLs = Set<URL>(mountedVolumes)
        }
    }
    
    // MARK: - Menu and toolbar item support
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu {
        // Produce a menu for the extension.
        var menu = NSMenu(title: "")
        switch menuKind {
        case .contextualMenuForContainer:
            menu = addNewFileSubMenu(menu)
        default:
            break
        }
        return menu
    }
    
    func addNewFileSubMenu(_ mainMenu: NSMenu) -> NSMenu {
        // Submenu
        let newFileSubMenu = NSMenu(title: "")
        let availableFileTypes = fileTypes
        availableFileTypes.forEach({ fileType in
            newFileSubMenu.addItem(withTitle: fileType.name, action: #selector(createNewFile(_:)), keyEquivalent: "")
        })
        // Main Menu
        let mainDropDownNewFileSubMenu = NSMenuItem(title: "Create a new...", action: nil, keyEquivalent: "")
        mainMenu.addItem(mainDropDownNewFileSubMenu)
        mainMenu.setSubmenu(newFileSubMenu, for: mainDropDownNewFileSubMenu)
        return mainMenu
    }
    
    // MARK: - Actions
    
    func getSelectedPathsFromFinder() -> [URL] {
        var urls = [URL]()
        if let items = FIFinderSyncController.default().selectedItemURLs(), items.count > 0 {
            urls = items
        } else if let url = FIFinderSyncController.default().targetedURL() {
            urls.append(url)
        }
        return urls
    }
    
    // MARK: - Menu Actions

    @IBAction func createNewFile(_ sender: AnyObject?) {
        guard let url = FIFinderSyncController.default().targetedURL() else { return }
        
        let item = sender as! NSMenuItem
        for fileType in fileTypes {
            if fileType.name == item.title {
                NSLog("Create \"New File.%s\" in \"%s\".", fileType.fienameExtension, url.path)
//                FileManager.default.createFile(atPath: "\(url.path)/New File.\(fileType.fienameExtension)",
//                                               contents: nil,
//                                               attributes: nil)
            }
        }
    }
}

struct FileType {
    let name: String
    let fienameExtension: String
    
    init(_ name: String, _ fienameExtension: String) {
        self.name = name
        self.fienameExtension = fienameExtension
    }
}
