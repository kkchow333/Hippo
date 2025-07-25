import SwiftUI

struct ReminderView: View {
    let name: String
    let imageURL: URL
    let onDismiss: () -> Void
    let showProfileImage: Bool
    @State private var inputText: String = ""
    @State private var isEditing: Bool = false
    @State private var hasSubmittedText: Bool = false
    @State private var selectedTags: Set<String> = []
    @State private var isImageLoaded: Bool = false
    
    // Customizable window width
    let windowWidth: CGFloat = 500
    
    init(name: String, imageURL: URL, onDismiss: @escaping () -> Void, showProfileImage: Bool = true) {
        self.name = name
        self.imageURL = imageURL
        self.onDismiss = onDismiss
        self.showProfileImage = showProfileImage
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Main Reminder Content
            VStack(spacing: 20) {
                HStack(alignment: .top, spacing: 15) {
                    if showProfileImage {
                        // Profile Image with enhanced tap area
                        Button(action: handleDismiss) {
                            ProfileImageView(imageURL: imageURL, isLoaded: $isImageLoaded)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(!isImageLoaded)
                    }
                    
                    // Text Input or Message
                    if !hasSubmittedText || isEditing {
                        TextInputView(
                            inputText: $inputText,
                            hasSubmittedText: $hasSubmittedText,
                            isEditing: $isEditing
                        )
                    } else {
                        SubmittedTextView(
                            text: inputText,
                            onEdit: { isEditing = true }
                        )
                    }
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(20)
            
            // Tags Section
            TagList(selectedTags: $selectedTags, onDismiss: onDismiss)
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: windowWidth)
    }
    
    private func handleDismiss() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            onDismiss()
        }
    }
}

// MARK: - Subviews
private struct ProfileImageView: View {
    let imageURL: URL
    @Binding var isLoaded: Bool
    
    var body: some View {
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: 80, height: 80)
                    .onAppear { isLoaded = false }
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .onAppear { isLoaded = true }
            case .failure(_):
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
                    .onAppear { isLoaded = true }
            @unknown default:
                EmptyView()
                    .onAppear { isLoaded = false }
            }
        }
        .background(
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
        )
        .padding(10)
        .background(
            Circle()
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.2), radius: 5)
        )
    }
}

private struct TextInputView: View {
    @Binding var inputText: String
    @Binding var hasSubmittedText: Bool
    @Binding var isEditing: Bool
    
    var body: some View {
        HStack {
            TextField("Text Input", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.black)
                .accentColor(.black)
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
    }
}

private struct SubmittedTextView: View {
    let text: String
    let onEdit: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            Text(text)
                .font(.system(size: 20))
                .foregroundColor(.black)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            Button(action: onEdit) {
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

#Preview {
    ReminderView(
        name: "John Doe",
        imageURL: URL(string: "https://example.com/profile.jpg")!,
        onDismiss: {},
        showProfileImage: true
    )
}
