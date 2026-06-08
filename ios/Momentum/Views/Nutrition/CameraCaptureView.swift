import SwiftUI
import AVFoundation

struct CameraCaptureView: View {
    @ObservedObject var viewModel: NutritionViewModel
    @Environment(\.dismiss) var dismiss
    @State private var isFlashOn = false
    @State private var capturedImage: UIImage?
    @State private var showPreview = false
    
    var body: some View {
        ZStack {
            CameraPreview(isFlashOn: $isFlashOn, capturedImage: $capturedImage, showPreview: $showPreview)
                .ignoresSafeArea()
            
            // Overlay
            VStack {
                // Top bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    Spacer()
                    Button(action: { isFlashOn.toggle() }) {
                        Image(systemName: isFlashOn ? "bolt.fill" : "bolt.slash")
                            .font(.title2)
                            .foregroundColor(isFlashOn ? .momentumEnergy : .white)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                Spacer()
                
                // Bottom bar
                VStack(spacing: 24) {
                    // Frame guide
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 280, height: 280)
                        .overlay(
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 100))
                                .foregroundColor(.white.opacity(0.2))
                        )
                    
                    Text("Point at your meal")
                        .font(.momentumCallout)
                        .foregroundColor(.white)
                    
                    // Shutter button
                    Button(action: capturePhoto) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 72, height: 72)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 4)
                                    .frame(width: 84, height: 84)
                            )
                    }
                    
                    // Barcode scan shortcut
                    Button(action: { dismiss() }) {
                        Label("Scan Barcode Instead", systemImage: "barcode.viewfinder")
                            .font(.momentumSubheadline)
                            .foregroundColor(.momentumTextSecondary)
                    }
                }
                .padding(.bottom, 40)
            }
            
            // Analyze overlay
            if viewModel.isAnalyzing {
                ZStack {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                    VStack(spacing: 16) {
                        AIThinkingView(text: "Analyzing your meal")
                        Text("Using on-device AI")
                            .font(.momentumCaption)
                            .foregroundColor(.momentumTextSecondary)
                    }
                }
            }
            
            // Recognition result card
            if viewModel.showRecognitionCard, let food = viewModel.recognizedFood {
                VStack {
                    Spacer()
                    RecognitionCard(food: food) { mealType in
                        viewModel.confirmRecognition(mealType: mealType)
                        dismiss()
                    } onDismiss: {
                        viewModel.showRecognitionCard = false
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, 20)
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.showRecognitionCard)
            }
        }
    }
    
    private func capturePhoto() {
        viewModel.isAnalyzing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewModel.logFromPhoto()
        }
    }
}

struct CameraPreview: UIViewControllerRepresentable {
    @Binding var isFlashOn: Bool
    @Binding var capturedImage: UIImage?
    @Binding var showPreview: Bool
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        let session = AVCaptureSession()
        session.sessionPreset = .photo
        
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return controller
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        controller.view.layer.addSublayer(previewLayer)
        previewLayer.frame = controller.view.bounds
        
        context.coordinator.session = session
        
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let layer = uiViewController.view.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            layer.frame = uiViewController.view.bounds
        }
        if isFlashOn {
            toggleFlash(on: true)
        } else {
            toggleFlash(on: false)
        }
    }
    
    private func toggleFlash(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        if device.hasTorch {
            try? device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator {
        var parent: CameraPreview
        var session: AVCaptureSession?
        
        init(_ parent: CameraPreview) {
            self.parent = parent
        }
    }
}

struct RecognitionCard: View {
    let food: AIFoodRecognition
    let onConfirm: (MealType) -> Void
    let onDismiss: () -> Void
    @State private var selectedMealType: MealType = .lunch
    
    var body: some View {
        MomentumCard(glowColor: .momentumTeal, glowRadius: 16) {
            VStack(spacing: 16) {
                // Confidence badge
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.momentumTeal)
                    Text("\(Int(food.confidence * 100))% match")
                        .font(.momentumCallout)
                        .foregroundColor(.momentumTeal)
                    Spacer()
                    Text("On-Device AI")
                        .font(.momentumCaption)
                        .foregroundColor(.momentumTextTertiary)
                }
                
                // Food info
                VStack(spacing: 4) {
                    Text(food.name)
                        .font(.momentumTitle2)
                        .foregroundColor(.white)
                    if !food.alternativeNames.isEmpty {
                        Text("Could also be: \(food.alternativeNames.joined(separator: ", "))")
                            .font(.momentumCaption)
                            .foregroundColor(.momentumTextSecondary)
                    }
                }
                
                // Macros
                HStack(spacing: 16) {
                    MacroLabel(value: "\(food.estimatedCalories)", unit: "cal", color: .momentumEnergy)
                    MacroLabel(value: "\(Int(food.estimatedProtein))g", unit: "protein", color: .momentumFocus)
                    MacroLabel(value: "\(Int(food.estimatedCarbs))g", unit: "carbs", color: .momentumTeal)
                    MacroLabel(value: "\(Int(food.estimatedFat))g", unit: "fat", color: .momentumStress)
                }
                
                // Meal type picker
                Picker("Meal Type", selection: $selectedMealType) {
                    ForEach(MealType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                
                // Confirm button
                Button(action: { onConfirm(selectedMealType) }) {
                    Text("Log This Meal")
                        .font(.momentumHeadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.momentumTeal)
                        .cornerRadius(14)
                }
                
                Button(action: onDismiss) {
                    Text("Try Again")
                        .font(.momentumCallout)
                        .foregroundColor(.momentumTextSecondary)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct MacroLabel: View {
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.momentumTitle3)
                .foregroundColor(color)
            Text(unit)
                .font(.momentumCaption)
                .foregroundColor(.momentumTextTertiary)
        }
    }
}
