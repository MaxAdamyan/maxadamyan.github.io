import Foundation

do {
    let cvHTMLGenerator = try CVHTMLGenerator(contentsFolderPath: "Contents")
    let site = SiteGenerator(htmlGenerator: cvHTMLGenerator,
                             resourcePaths: ["Resources"])

    try site.generate()
}
catch { print(error) }
