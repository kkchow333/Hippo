import SwiftUI

enum TagType {
    case time
    case date
    case location
    case plus
    case color
    case repeating
    case navigation
}

struct Tag: Identifiable, Hashable {
    let id = UUID()
    let type: TagType
    var title: String
    var isSelected: Bool
    var options: [String]
    
    static let locations = ["Front door", "Kitchen", "Desk", "Bedroom"]
    static let repeatOptions = ["Doesn't repeat", "Daily", "Weekly", "Monthly"]
}

struct TagList: View {
    @Binding var selectedTags: Set<String>
    @State private var showingTimePicker = false
    @State private var showingDatePicker = false
    @State private var selectedTime = Date()
    @State private var selectedDate = Date()
    @State private var currentLocationIndex = 0
    @State private var currentRepeatIndex = 0
    @State private var timeTagTitle = "Time"
    @State private var dateTagTitle = "Date"
    @State private var showingHiddenTags = false
    @State private var currentHiddenTagIndex = 0  // Track which hidden tag to show
    let onDismiss: () -> Void
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"  // Explicitly set the format
        return formatter
    }()
    
    // Replace the existing tag arrays with @State variables to make them mutable
    @State private var visibleTags: [Tag] = [
        Tag(type: .time, title: "Time", isSelected: false, options: []),
        Tag(type: .date, title: "Date", isSelected: false, options: []),
        Tag(type: .location, title: "Front door", isSelected: false, options: Tag.locations),
        Tag(type: .plus, title: "+", isSelected: false, options: [])
    ]
    
    @State private var hiddenTags: [Tag] = [
        Tag(type: .color, title: "Color", isSelected: false, options: []),
        Tag(type: .repeating, title: "Repeats", isSelected: false, options: Tag.repeatOptions),
        Tag(type: .navigation, title: "Navigation", isSelected: false, options: [])
    ]
    
    // Add new properties for positioning
    private let pickerWidth: CGFloat = 200
    private let datePickerWidth: CGFloat = 280  // Wider width specifically for date picker
    private let pickerHeight: CGFloat = 200
    private let containerHeight: CGFloat = 300 // Height to accommodate pickers
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Single container for all tags
            FlowLayout(
                mode: .scrollable,
                items: showingHiddenTags ?
                    (visibleTags + [hiddenTags[currentHiddenTagIndex]]) :
                    visibleTags,
                spacing: 8
            ) { tag in
                if tag.type == .plus {
                    TagButton(
                        title: "+",
                        type: .plus,
                        isSelected: showingHiddenTags,
                        isHiddenTag: false,
                        showingHiddenTags: showingHiddenTags,
                        action: {
                            if showingHiddenTags {
                                // Move to next hidden tag or hide if we've shown all
                                if currentHiddenTagIndex < hiddenTags.count - 1 {
                                    currentHiddenTagIndex += 1
                                } else {
                                    showingHiddenTags = false
                                    currentHiddenTagIndex = 0
                                }
                            } else {
                                showingHiddenTags = true
                                currentHiddenTagIndex = 0
                            }
                        }
                    )
                } else {
                    TagButton(
                        title: tag.type == .time ? timeTagTitle :
                              tag.type == .date ? dateTagTitle :
                              tag.title,
                        type: tag.type,
                        isSelected: tag.type == .time ? (showingTimePicker || selectedTags.contains(timeFormatter.string(from: selectedTime))) :
                                  tag.type == .date ? (showingDatePicker || selectedTags.contains(dateFormatter.string(from: selectedDate))) :
                                  selectedTags.contains(tag.title),
                        isHiddenTag: hiddenTags.contains(tag),
                        showingHiddenTags: showingHiddenTags,
                        action: {
                            if hiddenTags.contains(tag) {
                                moveTagToVisible(tag)
                                // Reset hidden tag index after moving a tag
                                currentHiddenTagIndex = 0
                            } else {
                                handleTagTap(tag)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.2))
            .cornerRadius(12)
            .frame(width: 500, height: 100)
            
            // Picker overlays
            if showingTimePicker {
                timePicker
                    .transition(.opacity)
            }
            
            if showingDatePicker {
                datePicker
                    .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // Create separate views for the pickers
    private var timePicker: some View {
        VStack(spacing: 0) {
            DatePicker("Select Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .frame(width: pickerWidth, height: pickerHeight)
                .clipped()
                .cornerRadius(10)
                .onChange(of: selectedTime) { _, newValue in
                    let timeString = timeFormatter.string(from: newValue)
                    timeTagTitle = timeString
                    selectedTags.insert(timeString)
                }
            
            Button("Set") {
                showingTimePicker = false
                let timeString = timeFormatter.string(from: selectedTime)
                timeTagTitle = timeString
                selectedTags.insert(timeString)
            }
            .frame(width: pickerWidth, height: 44)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .shadow(radius: 5)
    }
    
    private var datePicker: some View {
        VStack(spacing: 0) {
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .frame(width: datePickerWidth, height: pickerHeight)
                .clipped()
                .cornerRadius(10)
                .environment(\.locale, Locale(identifier: "en_US"))
                .onChange(of: selectedDate) { _, newValue in
                    let dateString = dateFormatter.string(from: newValue)
                    dateTagTitle = dateString
                    selectedTags.insert(dateString)
                }
            
            Button("Set") {
                showingDatePicker = false
                let dateString = dateFormatter.string(from: selectedDate)
                dateTagTitle = dateString
                selectedTags.insert(dateString)
            }
            .frame(width: datePickerWidth, height: 44)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .shadow(radius: 5)
    }
    
    // Add this new function to handle moving tags between visible and hidden
    private func moveTagToVisible(_ tag: Tag) {
        withAnimation {
            // Remove from hidden tags
            hiddenTags.removeAll(where: { $0.id == tag.id })
            
            // Find the plus button index
            if let plusIndex = visibleTags.firstIndex(where: { $0.type == .plus }) {
                // Insert the tag before the plus button
                visibleTags.insert(tag, at: plusIndex)
            }
            
            // If there are no more hidden tags, hide the menu
            if hiddenTags.isEmpty {
                showingHiddenTags = false
                currentHiddenTagIndex = 0
            }
        }
    }
    
    // Update handleTagTap to handle moving tags back to hidden if needed
    private func handleTagTap(_ tag: Tag) {
        switch tag.type {
        case .time:
            print("Time tag tapped - Picker showing: \(showingTimePicker)")
            if showingTimePicker {
                // If picker is showing, dismiss the entire view
                onDismiss()
            } else {
                // Show picker and reset title if no time is selected
                showingTimePicker = true
                showingDatePicker = false
                if timeTagTitle == "Time" {
                    // Initialize with current time when first opened
                    selectedTime = Date()
                    timeTagTitle = timeFormatter.string(from: selectedTime)
                }
            }
        case .date:
            showingDatePicker.toggle()
            showingTimePicker = false
            if !showingDatePicker && dateTagTitle == "Date" {
                // Initialize with current date when first opened
                selectedDate = Date()
                dateTagTitle = dateFormatter.string(from: selectedDate)
            }
        case .location:
            currentLocationIndex = (currentLocationIndex + 1) % Tag.locations.count
            selectedTags.remove(tag.title)
            selectedTags.insert(Tag.locations[currentLocationIndex])
        case .plus:
            withAnimation(.easeInOut(duration: 0.2)) {
                showingHiddenTags.toggle()
            }
        case .color:
            // Add color handling
            selectedTags.insert("Color")
        case .repeating:
            currentRepeatIndex = (currentRepeatIndex + 1) % Tag.repeatOptions.count
            selectedTags.remove(tag.title)
            selectedTags.insert(Tag.repeatOptions[currentRepeatIndex])
        case .navigation:
            // Add navigation handling
            selectedTags.insert("Navigation")
        }
    }
}

// Add extension for custom corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct TagButton: View {
    let title: String
    let type: TagType
    let isSelected: Bool
    let isHiddenTag: Bool
    let showingHiddenTags: Bool
    let action: () -> Void
    
    private let vPad: CGFloat = 8
    private let hPad: CGFloat = 16
    private let radius: CGFloat = 20
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 15))
                    .fontWeight(isSelected ? .medium : .regular)
                
                if type == .time || type == .date {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                        .rotationEffect(.degrees(isSelected ? 180 : 0))
                        .animation(.easeInOut, value: isSelected)
                } else if type == .location || type == .repeating {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 10))
                }
            }
        }
        .buttonStyle(CustomTagButtonStyle(isSelected: isSelected, isHiddenTag: isHiddenTag))
        // Only animate the opacity for hidden tags
        .opacity(isHiddenTag ? (showingHiddenTags ? 1 : 0) : 1)
        // Disable the default animation for position changes
        .transaction { transaction in
            if isHiddenTag {
                transaction.animation = .easeIn(duration: 0.2)
            } else {
                transaction.animation = nil
            }
        }
    }
}

// Add this new style struct
struct CustomTagButtonStyle: ButtonStyle {
    let isSelected: Bool
    let isHiddenTag: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isHiddenTag ? Color.white.opacity(0.3) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(isHiddenTag ? Color.clear : Color(.systemGray4), lineWidth: 1)
                    )
            )
            .foregroundColor(isHiddenTag ? .white : Color(.darkGray))
    }
}

struct TagList_Previews: PreviewProvider {
    static var previews: some View {
        TagList(selectedTags: .constant(["Time"]), onDismiss: {})
    }
}

// Add this FlowLayout view
struct FlowLayout<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable {
    enum Mode {
        case scrollable
        case stack
    }
    
    let mode: Mode
    let items: Data
    let spacing: CGFloat
    let content: (Data.Element) -> Content
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                var width = CGFloat.zero
                var height = CGFloat.zero
                
                ZStack(alignment: .topLeading) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        content(item)
                            .padding(spacing)
                            .alignmentGuide(.leading) { d in
                                if abs(width - d.width) > geometry.size.width {
                                    width = 0
                                    height -= d.height
                                }
                                let result = width
                                if index == items.count - 1 {
                                    width = 0
                                } else {
                                    width -= d.width
                                }
                                return result
                            }
                            .alignmentGuide(.top) { d in
                                let result = height
                                return result
                            }
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top) // Force alignment to top
        }
    }
}
