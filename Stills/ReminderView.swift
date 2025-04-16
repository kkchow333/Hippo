import SwiftUI

struct ReminderView: View {
    let name: String
    let imageURL: URL
    let onDismiss: () -> Void
    @State private var inputText: String = ""
    @State private var isEditing: Bool = false
    @State private var hasSubmittedText: Bool = false
    
    // Customizable window width
    let windowWidth: CGFloat = 500  // Increased width
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Profile Image
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 80, height: 80)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                case .failure(_):
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            
            // Text Input or Message
            if !hasSubmittedText || isEditing {
                HStack {
                    TextField("Text Input", text: $inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .onSubmit {
                            if !inputText.isEmpty {
                                hasSubmittedText = true
                                isEditing = false
                            }
                        }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .cornerRadius(25)
            } else {
                HStack(alignment: .top) {
                    Text(inputText)
                        .font(.system(size: 20))
                        .foregroundColor(.black)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                    
                    Button(action: {
                        isEditing = true
                    }) {
                        Image(systemName: "pencil")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .cornerRadius(25)
            }
        }
        .padding(20)
        .frame(width: windowWidth)
        .background(Color.white)
        .cornerRadius(20)
    }
}
