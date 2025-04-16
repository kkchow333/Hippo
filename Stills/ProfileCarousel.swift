import SwiftUI

struct ProfileCarousel: View {
    let name: String
    let imageURL: URL
    let id: Int
    let isSelected: Bool
    let distance: Double
    
    var body: some View {
        VStack {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 120, height: 120)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                case .failure(_):
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            .background(
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 8)
                    .frame(width: 122, height: 122)
            )
            
            Text(name)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
                .padding()
        }
        .scaleEffect(isSelected ? 1.3 : (1.0 - abs(distance) * 0.2))
        .opacity(isSelected ? 1.0 : (1.0 - abs(distance) * 0.3))
    }
} 
