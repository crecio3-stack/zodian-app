import AVFoundation
import PhotosUI
import SwiftUI
import UIKit

/// Shared, native source chooser for local profile photos. Selection is deliberately
/// separate from cropping so each surface can retain its established crop treatment.
struct ZodianPhotoPicker<Label: View>: View {
    let hasPhoto: Bool
    let onImageSelected: (UIImage) -> Void
    let onRemove: () -> Void
    @ViewBuilder let label: () -> Label

    @State private var showsSourceChooser = false
    @State private var showsLibrary = false
    @State private var showsCamera = false
    @State private var showsCameraAccessAlert = false

    var body: some View {
        Button { showsSourceChooser = true } label: { label() }
            .buttonStyle(.plain)
            .confirmationDialog("Profile photo", isPresented: $showsSourceChooser, titleVisibility: .visible) {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button("Take Photo") { requestCameraThenPresent() }
                }
                Button("Choose from Library") { showsLibrary = true }
                if hasPhoto { Button("Remove Photo", role: .destructive, action: onRemove) }
                Button("Cancel", role: .cancel) { }
            }
            .sheet(isPresented: $showsLibrary) {
                ZodianSystemImagePicker(sourceType: .photoLibrary, onImageSelected: select)
            }
            .sheet(isPresented: $showsCamera) {
                ZodianSystemImagePicker(sourceType: .camera, onImageSelected: select)
            }
            .alert("Camera access is needed", isPresented: $showsCameraAccessAlert) {
                Button("Open Settings") {
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(url)
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Allow camera access in Settings to take a profile photo.")
            }
    }

    private func select(_ image: UIImage) {
        showsLibrary = false
        showsCamera = false
        onImageSelected(image)
    }

    private func requestCameraThenPresent() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showsCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async { granted ? (showsCamera = true) : (showsCameraAccessAlert = true) }
            }
        case .denied, .restricted:
            showsCameraAccessAlert = true
        @unknown default:
            showsCameraAccessAlert = true
        }
    }
}

private struct ZodianSystemImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImageSelected: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator { Coordinator(onImageSelected: onImageSelected, dismiss: dismiss) }
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let controller = UIImagePickerController()
        controller.sourceType = sourceType
        controller.delegate = context.coordinator
        controller.allowsEditing = false
        return controller
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) { }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let onImageSelected: (UIImage) -> Void
        let dismiss: DismissAction
        init(onImageSelected: @escaping (UIImage) -> Void, dismiss: DismissAction) {
            self.onImageSelected = onImageSelected; self.dismiss = dismiss
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { dismiss() }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage { onImageSelected(image) }
            dismiss()
        }
    }
}
