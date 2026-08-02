import SwiftUI

struct BirthdayPickerSheet: View {
    @Binding var birthday: Date
    let onConfirm: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                VStack(spacing: 5) {
                    Text("Choose their birthday")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundStyle(ZD.Color.textPrimary)

                    Text(birthday.formatted(date: .long, time: .omitted))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(ZD.Color.accent)
                }
                .frame(maxWidth: .infinity)

                DatePicker(
                    "Birthday",
                    selection: $birthday,
                    in: ...Date(),
                    displayedComponents: [.date]
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .tint(ZD.Color.accent)
                .frame(maxWidth: .infinity)

                Button(action: onConfirm) {
                    Text("Confirm birthday")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Capsule(style: .continuous).fill(ZD.Color.accent))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, ZD.Spacing.l)
            .padding(.top, 12)
            .padding(.bottom, 18)
            .background(ZD.Color.bg.ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(ZD.Color.textSecondary)
                }
            }
        }
    }
}
