import Foundation
import Files
import Plot
import Ink
import Yams

typealias Node = Plot.Node

struct CVHTMLGenerator: HTMLGenerator {
    enum Section: String {
        case education = "Educations"
        case languages = "Languages"
        case interests = "Interests"
        case experience = "Experiences"
        case projects = "Projects"
        case skills = "Skills"
    }
    
    let contentsFolder: Folder
    
    init(contentsFolderPath: String,
         originalFilePath: String = #file) throws {
        
        let packageFolder = try Utiles.resolvePackageFolder(withSourceFilePath: originalFilePath)
        self.contentsFolder = try packageFolder.subfolder(at: contentsFolderPath)
    }
}

extension CVHTMLGenerator {
    func generateHTML() -> String {
        
        let generalData = self.generalData()
        let educationData = self.data(forSection: .education)
        let languagesData = self.data(forSection: .languages)
        let interestsData = self.data(forSection: .interests)
        let experienceData = self.data(forSection: .experience)
        let projectsData = self.data(forSection: .projects)
        let skillsData = self.data(forSection: .skills)
        
        return HTML(
            .lang(.english),
            .head(withGeneralData: generalData),
            .body(
                .div(.class("wrapper"),
                     .sideBar(withGeneralData: generalData,
                              withEducationData: educationData,
                              withLanguagesData: languagesData,
                              withInterestData: interestsData),
                     .div(
                        .class("main-wrapper"),
                        .content(withGeneralData: generalData,
                                 withExperienceData: experienceData,
                                 withProjectsData: projectsData,
                                 withSkillsData: skillsData)
                    )
                ),
                .footer()
            )
        )
        .render(indentedBy: .spaces(4))
    }
    
    func data(forSection section: Section) -> [[String: String]] {
        var data: [[String: String]] = []
        do {
            let dataYAMLString = try self.contentsFolder.file(at: "Sections/" + section.rawValue + ".yml").readAsString()
            let anyData = try Yams.load(yaml: dataYAMLString)
            if let dicData = (anyData as? [[String: Any?]]) {
                dicData.forEach({ data.append($0.toStringDictionary()) })
            }
        } catch { }
        
        return data
    }
    
    func generalData() -> [String: String] {
        var data: [String: String] = [:]
        do {
            let dataYAMLString = try self.contentsFolder.file(at: "GeneralData.yml").readAsString()
            let anyData = try Yams.load(yaml: dataYAMLString)
            if let dicData = (anyData as? [String: Any?])?.toStringDictionary() { data = dicData }
        } catch { }
        
        return data
    }
}

//MARK: - Head
extension Node where Context == HTML.DocumentContext {
    static func head(withGeneralData data: [String: String]) -> Self {
        .head(
            .unwrap(data["name"], { .title($0) }),
            .meta(.name("description"), .content("Resume")),
            .meta(.name("viewport"), .content("width=device-width initial-scale=1.0")),
            .link(.rel(.shortcutIcon), .href("Resources/favicon.ico")),
            
            //3rd Party CSS and Fonts
            .link(.rel(.stylesheet), .href("https://fonts.googleapis.com/css?family=Roboto:400,500,400italic,300italic,300,500italic,700,700italic,900,900italic")),
            .link(.rel(.stylesheet), .href("Resources/plugins/bootstrap/css/bootstrap.min.css")),
            .link(.rel(.stylesheet), .href("Resources/plugins/font-awesome/css/font-awesome.css")),
            
            //Main CSS
            .link(.rel(.stylesheet), .href("Resources/css/styles.css"))
        )
    }
}

//MARK: - SideBar
extension Node where Context == HTML.BodyContext {
    static func sideBar(withGeneralData data: [String: String],
                        withEducationData education: [[String: String]],
                        withLanguagesData languages: [[String: String]],
                        withInterestData interests: [[String: String]]) -> Self {
                
        return .div(
            .class("sidebar-wrapper"),
            .profileContainer(withGeneralData: data),
            .contactsContainer(withGeneralData: data),
            .if(education.isNotEmpty, .educationContainer(withEducationData: education)),
            .if(languages.isNotEmpty, .languagesContainer(withLanguagesData: languages)),
            .if(interests.isNotEmpty, .interestsContainer(withInterestsData: interests))
        )
    }
    
    static func profileContainer(withGeneralData data: [String: String]) -> Self {
        .div(
            .class("profile-container"),
            .img(
                .class("profile-img"),
                .src("Resources/images/profile.png"),
                .alt("profile picture")
            ),
            .unwrap(data["name"], { .h1(.class("name"), .text($0)) }),
            .unwrap(data["tagline"], { .h1(.class("tagline"), .text($0)) })
        )
    }
    
    static func contactsContainer(withGeneralData data: [String: String]) -> Self {
        .div(
            .class("contact-container container-block"),
            .ul(
                .class("list-unstyled contact-list"),
                .unwrap(data["email"], {
                    .li(.class("email"),
                        .i(.class("fa fa-envelope")),
                        .a(.href("mailto:" + $0), .text($0))
                    )
                }),
                .unwrap(data["phone"], {
                    .li(.class("phone"),
                        .i(.class("fa fa-phone")),
                        .a(.href("tel:" + $0), .text($0))
                    )
                }),
                .unwrap(data["website"], {
                    .li(.class("website"),
                        .i(.class("fa fa-globe")),
                        .a(.href("http://" + $0), .text($0))
                    )
                }),
                .unwrap(data["linkedin"], {
                    .li(.class("linkedin"),
                        .i(.class("fa fa-linkedin")),
                        .a(.href("https://linkedin.com/in/" + $0), .target(.blank), .text($0))
                    )
                }),
                .unwrap(data["github"], {
                    .li(.class("github"),
                        .i(.class("fa fa-github")),
                        .a(.href("http://github.com/" + $0), .target(.blank), .text($0))
                    )
                }),
                .unwrap(data["twitter"], {
                    .li(.class("twitter"),
                        .i(.class("fa fa-twitter")),
                        .a(.href("http://twitter.com/" + $0), .target(.blank), .text($0))
                    )
                })
            )
        )
    }
    
    static func educationContainer(withEducationData educations: [[String: String]]) -> Self {
        .div(
            .class("education-container container-block"),
            .h2(.class("container-block-title"), .text("Education")),
            .forEach(educations, { (education) -> Node<HTML.BodyContext> in
                .div(.class("item"),
                     .unwrap(education["degree"], { .h4(.class("degree"), .text($0)) }),
                     .unwrap(education["university"], { .h5(.class("meta"), .text($0)) }),
                     .unwrap(education["time"], { .div(.class("time"), .text($0)) })
                )
            })
        )
    }
    
    static func languagesContainer(withLanguagesData languages: [[String: String]]) -> Self {
        .div(
            .class("languages-container container-block"),
            .h2(.class("container-block-title"), .text("Languages")),
            .ul(
                .class("list-unstyled languages-list"),
                .forEach(languages, { (language) -> Node<HTML.ListContext> in
                    .li(.unwrap(language["idiom"], { .text($0) }),
                        .unwrap(language["level"], { .span(.class("lang-desc"), .text("(" + $0 + ")")) })
                    )
                })
            )
        )
    }
    
    static func interestsContainer(withInterestsData interests: [[String: String]]) -> Self {
        .div(
            .class("languages-container container-block"),
            .h2(.class("container-block-title"), .text("Interests")),
            .ul(
                .class("list-unstyled interests-list"),
                .forEach(interests, { (interest) -> Node<HTML.ListContext> in
                    .li(
                        .unwrap(interest["item"], { .text($0) })
                    )
                })
            )
        )
    }
}

//MARK: - Main Sections
extension Node where Context == HTML.BodyContext {
    static func content(withGeneralData generalData: [String: String],
                        withExperienceData experience: [[String: String]],
                        withProjectsData projects: [[String: String]],
                        withSkillsData skills: [[String: String]]) -> Self {
        
        .group(
            .if(generalData["summary"] != nil, .careerProfileSection(withGeneralData: generalData)),
            .if(experience.isNotEmpty, .experienceSection(withExperienceData: experience)),
            .if(projects.isNotEmpty, .projectsSection(withProjectsData: projects)),
            .if(skills.isNotEmpty, .skillsSection(withSkillsData: skills))
        )
    }
    
    static func careerProfileSection(withGeneralData generalData: [String: String]) -> Self {
        .section(
            .class("section summary-section"),
            .h2(
                .class("section-title"),
                .i(.class("fa fa-user")),
                .text("Career Profile")
            ),
            .div(
                .class("summary"),
                .p(.unwrap(generalData["summary"], { .markdown($0) }))
            )
        )
    }
    
    static func experienceSection(withExperienceData experience: [[String: String]]) -> Self {
        .section(
            .class("section experiences-section"),
            .h2(
                .class("section-title"),
                .i(.class("fa fa-briefcase")),
                .text("Experiences")
            ),
            .forEach(experience, { exp -> Node<HTML.BodyContext> in
                .div(
                    .class("item"),
                    .div(
                        .class("meta"),
                        .div(
                            .class("upper-row"),
                            .unwrap(exp["role"], { .h3(.class("job-title"), .text($0)) }),
                            .unwrap(exp["time"], { .div(.class("time"), .text($0)) })
                        ),
                        .div(.class("company"), .unwrap(exp["company"], { .text($0) }))
                    ),
                    .unwrap(exp["details"], { .div(.class("details"), .p(.markdown($0))) })
                )
            })
        )
    }
    
    static func projectsSection(withProjectsData projects: [[String: String]]) -> Self {
        .section(
            .class("section projects-section"),
            .h2(
                .class("section-title"),
                .i(.class("fa fa-archive")),
                .text("Projects")
            ),
            .forEach(projects, { project -> Node<HTML.BodyContext> in
                .div(
                    .class("item"),
                    .unwrap(project["title"], {
                        .span(
                            .class("project-title"),
                            .if(project["link"] != nil,
                                .unwrap(project["link"], { .a(.href(project["link"]!), .text($0)) }),
                            else: .text($0))
                        )
                    }),
                    .unwrap(project["tagline"], { .span(.class("project-tagline"), .markdown($0)) })
                )
            })
        )
    }
    
    static func skillsSection(withSkillsData skills: [[String: String]]) -> Self {
        section(
            .class("section skills-section"),
            .h2(
                .class("section-title"),
                .i(.class("fa fa-rocket")),
                .text("Skills &amp; Proficiency")
            ),
            .div(
                .class("skillset"),
                .forEach(skills, { skill -> Node<HTML.BodyContext> in
                    .div(
                        .class("item"),
                        .unwrap(skill["name"], { .h3(.class("skill-title"), .text($0)) }),
                        .unwrap(skill["time"], { .div(.class("skill-time"), .text($0)) })
                    )
                })
            )
        )
    }
}

//MARK: - Footer
extension Node where Context == HTML.BodyContext {
    static func footer() -> Self {
        .footer(
            .class("footer"),
            .div(
                .class("text-center"),
                .span(
                    .class("copyright"),
                    .raw("Copyright &copy; Adamyan, 2020"),
                    .raw("</br>"),
                    .text("Built with "),
                    .a(.text("Swift"), .href("https://github.com/MaxAdamyan/maxadamyan.github.io"), .target(.blank))
                )
            )
        )
    }
}
