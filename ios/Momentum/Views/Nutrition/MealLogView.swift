import SwiftUI

struct MealLogView: View {
    @ObservedObject var viewModel: NutritionViewModel
    @Environment(\.dismiss) var dismiss
    @State private var descriptionText = ""
    @State private var selectedMealType: MealType = .lunch
    
    var body: some View {
        ZStack {
            Color.momentumBg.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    HStack {
                        Text("Log Meal")
                            .font(.momentumLargeTitle)
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.momentumTextSecondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Meal Type Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Meal Type")
                            .font(.momentumHeadline)
                            .foregroundColor(.white)
                        Picker("Meal Type", selection: $selectedMealType) {
                            ForEach(MealType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal)
                    
                    // Quick Photo
                    Button(action: {
                        viewModel.logFromPhoto()
                        dismiss()
                    }) {
                        MomentumCard {
                            HStack {
                                Image(systemName: "camera.fill")
                                    .font(.title2)
                                    .foregroundColor(.momentumTeal)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Take Photo")
                                        .font(.momentumCallout)
                                        .foregroundColor(.white)
                                    Text("AI recognizes your food instantly")
                                        .font(.momentumCaption)
                                        .foregroundColor(.momentumTextSecondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.momentumTextTertiary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Barcode Scan
                    Button(action: {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            viewModel.isShowingBarcodeScanner = true
                        }
                    }) {
                        MomentumCard {
                            HStack {
                                Image(systemName: "barcode.viewfinder")
                                    .font(.title2)
                                    .foregroundColor(.momentumFocus)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Scan Barcode")
                                        .font(.momentumCallout)
                                        .foregroundColor(.white)
                                    Text("Look up packaged food nutrition")
                                        .font(.momentumCaption)
                                        .foregroundColor(.momentumTextSecondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.momentumTextTertiary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Restaurant
                    Button(action: {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            // Trigger restaurant flow
                            viewModel.descriptionText = ""
                        }
                    }) {
                        MomentumCard {
                            HStack {
                                Image(systemName: "building.columns.fill")
                                    .font(.title2)
                                    .foregroundColor(.momentumEnergy)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Restaurant Meal")
                                        .font(.momentumCallout)
                                        .foregroundColor(.white)
                                    Text("Chipotle, Sweetgreen, Chick-fil-A, McDonald's, Subway")
                                        .font(.momentumCaption)
                                        .foregroundColor(.momentumTextSecondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.momentumTextTertiary)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Describe Food
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Describe Your Meal")
                            .font(.momentumHeadline)
                            .foregroundColor(.white)
                        TextField("e.g., I had avocado toast with eggs", text: $descriptionText)
                            .font(.momentumBody)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.momentumGlass)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
                            )
                        if !descriptionText.isEmpty {
                            Button(action: {
                                viewModel.logFromDescription(descriptionText)
                                descriptionText = ""
                                dismiss()
                            }) {
                                Text("Analyze & Log")
                                    .font(.momentumHeadline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.momentumFocus)
                                    .cornerRadius(14)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer().frame(height: 40)
                }
                .padding(.top)
            }
        }
    }
}
