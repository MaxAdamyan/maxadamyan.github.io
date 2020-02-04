import Foundation
import Files

struct Utiles {
    static func resolvePackageFolder(withSourceFilePath path: String) throws -> Folder {
        do {
            let originalFile = try File(path: path)
            
            var nextFolder: Folder? = originalFile.parent
            while let currentFolder = nextFolder {
                if currentFolder.containsFile(named: "Package.swift") {
                    return currentFolder
                }
                
                nextFolder = currentFolder.parent
            }
        } catch { }
        throw SiteGeneratorError.genericError(message: "Could not resolve Package folder")
    }
}

extension Dictionary where Key == String, Value == Any? {
    func toStringDictionary() -> [String: String] {
        var new: [String: String] = [:]
        for (key, value) in self {
            guard let value = value as? String else { continue }
            new.updateValue(value, forKey: key)
        }
        return new
    }
}

extension Collection {
    var isNotEmpty: Bool {
        return !isEmpty
    }
}
