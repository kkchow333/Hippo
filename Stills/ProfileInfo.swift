import Foundation

struct ProfileInfo: Identifiable {
    let id: Int
    let name: String
    let imageURL: URL
    
    static func mockProfiles() -> [ProfileInfo] {
        return [
            ProfileInfo(id: 1, name: "Esther 1", imageURL: URL(string: "https://github.com/kkchow333/port/blob/main/esther%20profile.jpeg?raw=true")!),
            ProfileInfo(id: 2, name: "Esther 2", imageURL: URL(string: "https://github.com/kkchow333/port/blob/main/esther%20profile.jpeg?raw=true")!),
            ProfileInfo(id: 3, name: "Esther 3", imageURL: URL(string: "https://github.com/kkchow333/port/blob/main/esther%20profile.jpeg?raw=true")!),
            ProfileInfo(id: 4, name: "Esther 4", imageURL: URL(string: "https://github.com/kkchow333/port/blob/main/esther%20profile.jpeg?raw=true")!),
            ProfileInfo(id: 5, name: "Esther 5", imageURL: URL(string: "https://github.com/kkchow333/port/blob/main/esther%20profile.jpeg?raw=true")!),
            ProfileInfo(id: 6, name: "Esther 6", imageURL: URL(string: "https://github.com/kkchow333/port/blob/main/esther%20profile.jpeg?raw=true")!)
        ]
    }
} 
