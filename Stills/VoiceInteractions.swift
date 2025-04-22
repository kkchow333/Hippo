/*import SwiftUI
import Speech
import AVFoundation
import NaturalLanguage
import Intents
import IntentsUI
import EventKit

class ReminderIntentHandler: NSObject, ReminderIntentHandling {
    private let eventStore = EKEventStore()
    
    func handle(intent: CreateReminderIntent, completion: @escaping (CreateReminderIntentResponse) -> Void) {
        guard let title = intent.title else {
            completion(CreateReminderIntentResponse(code: .failure, userActivity: nil))
            return
        }
        
        // Request authorization for reminders
        if #available(iOS 17.0, *) {
            Task {
                do {
                    let granted = try await eventStore.requestAccess(to: .reminder)
                    handleReminderCreation(title: title, dueDate: intent.dueDate, granted: granted, completion: completion)
                } catch {
                    completion(CreateReminderIntentResponse(code: .failure, userActivity: nil))
                }
            }
        } else {
            eventStore.requestAccess(to: .reminder) { granted, error in
                if granted {
                    self.handleReminderCreation(title: title, dueDate: intent.dueDate, granted: granted, completion: completion)
                } else {
                    completion(CreateReminderIntentResponse(code: .failure, userActivity: nil))
                }
            }
        }
    }
    
    private func handleReminderCreation(title: String, dueDate: DateComponents?, granted: Bool, completion: @escaping (CreateReminderIntentResponse) -> Void) {
        guard granted else {
            completion(CreateReminderIntentResponse(code: .failure, userActivity: nil))
            return
        }
        
        // Create EKReminder
        let ekReminder = EKReminder(eventStore: eventStore)
        ekReminder.title = title
        ekReminder.calendar = eventStore.defaultCalendarForNewReminders()
        
        // Set due date if provided
        if let dueDate = dueDate {
            ekReminder.dueDateComponents = dueDate
        }
        
        do {
            try eventStore.save(ekReminder, commit: true)
            completion(CreateReminderIntentResponse(code: .success, userActivity: nil))
        } catch {
            completion(CreateReminderIntentResponse(code: .failure, userActivity: nil))
        }
    }
    
    func resolveTitle(for intent: CreateReminderIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        if let title = intent.title, !title.isEmpty {
            completion(.success(with: title))
        } else {
            completion(.needsValue())
        }
    }
    
    func resolveDueDate(for intent: CreateReminderIntent, with completion: @escaping (INDateComponentsResolutionResult) -> Void) {
        if let dueDate = intent.dueDate {
            completion(.success(with: dueDate))
        } else {
            completion(.notRequired())
        }
    }
}

class VoiceInteractionManager: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var transcribedText = ""
    @Published var isAuthorized = false
    @Published var shouldShowReminder = false
    @Published var reminderText = ""
    @Published var selectedTags: Set<String> = []
    
    // Date and time extracted from speech
    @Published var extractedDate: Date?
    @Published var extractedTime: Date?
    
    private var audioEngine = AVAudioEngine()
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    private let intentHandler = ReminderIntentHandler()
    
    override init() {
        super.init()
        checkAuthorization()
    }
    
    private func checkAuthorization() {
        INPreferences.requestSiriAuthorization { status in
            DispatchQueue.main.async {
                self.isAuthorized = status == .authorized
            }
        }
    }
    
    func startRecording() {
        guard !isRecording else { return }
        
        resetAudio()
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error.localizedDescription)")
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                let text = result.bestTranscription.formattedString
                self.transcribedText = text
                self.processVoiceCommand(text)
            }
            
            if error != nil {
                self.stopRecording()
            }
        }
        
        isRecording = true
    }
    
    func stopRecording() {
        resetAudio()
        isRecording = false
    }
    
    private func resetAudio() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
    }
    
    private func processVoiceCommand(_ text: String) {
        // Check for reminder trigger phrases
        let lowerText = text.lowercased()
        if lowerText.hasPrefix("set reminder") || lowerText.hasPrefix("set a reminder") {
            shouldShowReminder = true
            
            // Remove trigger phrase to get the actual reminder text
            let reminderContent = text.replacingOccurrences(of: "set reminder", with: "", options: [.caseInsensitive])
                .replacingOccurrences(of: "set a reminder", with: "", options: [.caseInsensitive])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            reminderText = reminderContent
            
            // Process the text for date and time information
            processDateAndTime(reminderContent)
        }
    }
    
    private func processDateAndTime(_ text: String) {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
        let range = NSRange(location: 0, length: text.utf16.count)
        
        guard let detector = detector else { return }
        
        detector.enumerateMatches(in: text, options: [], range: range) { result, _, _ in
            if let match = result, let date = match.date {
                let calendar = Calendar.current
                
                // Check if the match includes a time component
                if calendar.component(.hour, from: date) != 0 || calendar.component(.minute, from: date) != 0 {
                    self.extractedTime = date
                    if let timeString = self.timeFormatter.string(from: date).nilIfEmpty {
                        self.selectedTags.insert(timeString)
                    }
                }
                
                // Always set the date
                self.extractedDate = date
                if let dateString = self.dateFormatter.string(from: date).nilIfEmpty {
                    self.selectedTags.insert(dateString)
                }
            }
        }
    }
    
    func handleSiriRequest() {
        let intent = CreateReminderIntent()
        intent.suggestedInvocationPhrase = "Set a reminder"
        
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { error in
            if let error = error {
                print("Donation failed: \(error.localizedDescription)")
            }
        }
    }
}

struct VoiceButton: View {
    @ObservedObject var voiceManager: VoiceInteractionManager
    @State private var showingSiri = false
    
    var body: some View {
        Button(action: {
            showingSiri = true
        }) {
            Image(systemName: "mic.circle.fill")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(.blue)
        }
        .disabled(!voiceManager.isAuthorized)
        .sheet(isPresented: $showingSiri) {
            SiriUI()
        }
    }
}

struct SiriUI: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> INUIAddVoiceShortcutViewController {
        let intent = CreateReminderIntent()
        intent.suggestedInvocationPhrase = "Set a reminder"
        
        let shortcut = INShortcut(intent: intent)
        let viewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
        viewController.delegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: INUIAddVoiceShortcutViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, INUIAddVoiceShortcutViewControllerDelegate {
        let parent: SiriUI
        
        init(_ parent: SiriUI) {
            self.parent = parent
        }
        
        func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
            controller.dismiss(animated: true)
        }
        
        func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
            controller.dismiss(animated: true)
        }
    }
}

// Helper extension
extension String {
    var nilIfEmpty: String? {
        self.isEmpty ? nil : self
    }
}

#Preview {
    VoiceButton(voiceManager: VoiceInteractionManager())
}
*/
