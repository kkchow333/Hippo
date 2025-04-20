import SwiftUI

enum TagType {
    case time
    case date
    case location
    case repeating
    case add
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
    let onDismiss: () -> Void
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    let tags: [Tag] = [
        Tag(type: .time, title: "Time", isSelected: false, options: []),
        Tag(type: .date, title: "Date", isSelected: false, options: []),
        Tag(type: .location, title: "Front door", isSelected: false, options: Tag.locations),
        Tag(type: .repeating, title: "Repeats", isSelected: false, options: Tag.repeatOptions)
    ]
    
    // Add new properties for positioning
    private let pickerWidth: CGFloat = 200
    private let datePickerWidth: CGFloat = 280  // Wider width specifically for date picker
    private let pickerHeight: CGFloat = 200
    private let containerHeight: CGFloat = 300 // Height to accommodate pickers
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background container with fixed height
            Color.clear
                .frame(height: containerHeight)
            
            VStack(alignment: .leading, spacing: 10) {
                // Tags Row with proper spacing and layout
                HStack(spacing: 12) { // Adjusted spacing between tags
                    ForEach(tags) { tag in
                        TagButton(
                            title: tag.type == .time ? timeTagTitle :
                                  tag.type == .date ? dateTagTitle :
                                  tag.title,
                            type: tag.type,
                            isSelected: tag.type == .time ? (showingTimePicker || selectedTags.contains(timeFormatter.string(from: selectedTime))) :
                                      tag.type == .date ? (showingDatePicker || selectedTags.contains(dateFormatter.string(from: selectedDate))) :
                                      selectedTags.contains(tag.title),
                            action: {
                                handleTagTap(tag)
                            }
                        )
                        .fixedSize() // Allow tag to size based on content
                    }
                }
                .padding(.horizontal, 8) // Add some padding to align with content
            }
            
            // Time Picker Overlay
            if showingTimePicker {
                VStack(spacing: 0) {
                    DatePicker("Select Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .frame(width: pickerWidth, height: pickerHeight)
                        .clipped()
                        .cornerRadius(10, corners: [.topLeft, .topRight])
                        .onChange(of: selectedTime) { oldValue, newValue in
                            let timeString = timeFormatter.string(from: newValue)
                            timeTagTitle = timeString
                            selectedTags.insert(timeString)
                        }
                    
                    Button(action: {
                        showingTimePicker = false
                        let timeString = timeFormatter.string(from: selectedTime)
                        timeTagTitle = timeString
                        selectedTags.insert(timeString)
                        print("Time set to: \(timeString)")
                    }) {
                        Text("Set")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(width: pickerWidth)
                            .frame(height: 44)
                            .background(Color.blue)
                            .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
                    }
                }
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                .offset(y: 50) // Fixed distance from top
            }
            
            // Date Picker Overlay
            if showingDatePicker {
                VStack(spacing: 0) {
                    DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .frame(width: datePickerWidth, height: pickerHeight)
                        .clipped()
                        .cornerRadius(10, corners: [.topLeft, .topRight])
                        .onChange(of: selectedDate) { oldValue, newValue in
                            let dateString = dateFormatter.string(from: newValue)
                            dateTagTitle = dateString
                            selectedTags.insert(dateString)
                        }
                    
                    Button(action: {
                        showingDatePicker = false
                        let dateString = dateFormatter.string(from: selectedDate)
                        dateTagTitle = dateString
                        selectedTags.insert(dateString)
                        print("Date set to: \(dateString)")
                    }) {
                        Text("Set")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(width: datePickerWidth)
                            .frame(height: 44)
                            .background(Color.blue)
                            .cornerRadius(10, corners: [.bottomLeft, .bottomRight])
                    }
                }
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                .offset(x: pickerWidth + 10, y: 50) // Fixed distance from top, positioned after time picker
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
    
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
        case .repeating:
            currentRepeatIndex = (currentRepeatIndex + 1) % Tag.repeatOptions.count
            selectedTags.remove(tag.title)
            selectedTags.insert(Tag.repeatOptions[currentRepeatIndex])
        case .add:
            break
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
    let action: () -> Void
    
    private let vPad: CGFloat = 8  // Reduced vertical padding
    private let hPad: CGFloat = 16 // Adjusted horizontal padding
    private let radius: CGFloat = 20 // Adjusted corner radius
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) { // Reduced spacing between text and icon
                Text(title)
                    .font(.system(size: 15)) // Adjusted font size
                    .fontWeight(isSelected ? .medium : .regular)
                
                if type == .time || type == .date {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10)) // Smaller icon
                        .rotationEffect(.degrees(isSelected ? 180 : 0))
                        .animation(.easeInOut, value: isSelected)
                } else if type == .location || type == .repeating {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 10)) // Smaller icon
                }
            }
            .padding(.vertical, vPad)
            .padding(.horizontal, hPad)
            .foregroundColor(isSelected ? .white : .gray)
            .background(isSelected ? Color.blue : Color.clear)
            .cornerRadius(radius)
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(isSelected ? Color.clear : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct TagList_Previews: PreviewProvider {
    static var previews: some View {
        TagList(selectedTags: .constant(["Time"]), onDismiss: {})
    }
}
