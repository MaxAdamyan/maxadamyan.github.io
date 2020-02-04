import Foundation
import Files

struct SiteGenerator {
    let htmlGenerator: HTMLGenerator
    let resourcePaths: Set<String>
    
    func generate(at path: String? = nil,
                  originalFilePath: String = #file) throws {
        
        let packageFolder: Folder
        let workingFolder: Folder
        do {
            packageFolder = try Utiles.resolvePackageFolder(withSourceFilePath: originalFilePath)
            
            if let path = path {
                workingFolder = try Folder(path: path)
            } else {
                workingFolder = packageFolder
            }
        } catch { throw SiteGeneratorError.genericError(message: "Could not find output folder")}
        
        let outputFolder = try workingFolder.createSubfolderIfNeeded(at: "Output")
        try outputFolder.subfolders.forEach({ try $0.delete() })
        try outputFolder.files.forEach({ try $0.delete() })
        
        try outputFolder.createFile(at: "index.html", contents: htmlGenerator.generateHTML().data(using: .utf8))
        for resourcePath in resourcePaths {
            let resourceFolder = try packageFolder.subfolder(at: resourcePath)
            try resourceFolder.copy(to: outputFolder)
        }
    }
}
