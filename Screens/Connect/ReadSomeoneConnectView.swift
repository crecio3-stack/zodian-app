import PhotosUI
import SwiftData
import SwiftUI
import UIKit

/// Production Connect surface. Saved people are local-only and never represent app accounts.
struct ConnectView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \SavedPerson.updatedAt, order: .reverse) private var people: [SavedPerson]

    @State private var editorMode: PersonEditorMode?
    @State private var selectedPerson: SavedPerson?
    @State private var savedToastName: String?

    var body: some View {
        NavigationStack {
            ZStack {
                ZD.Color.bg.ignoresSafeArea()

                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 24) {
                            header
                                .id("connect-intro")

                            PremiumGoldShimmerButton(
                                title: "Read someone",
                                action: {
                                    AnalyticsService.shared.track(.readSomeoneStarted)
                                    editorMode = .add
                                },
                                icon: "person.badge.plus"
                            )
                            .accessibilityHint("Add a person by name and birth date")

                            savedPeople
                        }
                        .padding(.horizontal, ZD.Spacing.l)
                        .padding(.top, 20)
                        .padding(.bottom, 120)
                    }
                    .onAppear {
                        restoreConnectIntroduction(using: proxy)
                    }
                    .onChange(of: selectedPerson?.id) { _, selectedID in
                        guard selectedID == nil else { return }
                        // NavigationStack keeps the tapped row visible when returning.
                        // Restore the editorial introduction after that selection clears.
                        restoreConnectIntroduction(using: proxy)
                    }
                }
            }
            .navigationDestination(item: $selectedPerson) { person in
                SavedPersonProfileView(person: person, onEdit: { editorMode = .edit(person) })
            }
            .sheet(item: $editorMode) { mode in
                SavedPersonEditorView(mode: mode) { saved in
                    if mode.person == nil {
                        showSavedToast(for: saved.name)
                    }
                    selectedPerson = saved
                }
            }
            .onAppear {
                AnalyticsService.shared.track(.readSomeoneOpened)
            }
        }
        .preferredColorScheme(.dark)
        .overlay(alignment: .top) {
            if let savedToastName {
                SavedPersonSuccessToast(name: savedToastName)
                    .padding(.horizontal, ZD.Spacing.l)
                    .padding(.top, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(20)
            }
        }
    }

    private func showSavedToast(for name: String) {
        withAnimation(.spring(response: 0.42, dampingFraction: 0.84)) {
            savedToastName = name
        }
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2.4))
            guard savedToastName == name else { return }
            withAnimation(.easeOut(duration: 0.22)) {
                savedToastName = nil
            }
        }
    }

    private func restoreConnectIntroduction(using proxy: ScrollViewProxy) {
        DispatchQueue.main.async {
            proxy.scrollTo("connect-intro", anchor: .top)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CONNECT")
                .font(ZD.Font.caption(.semibold))
                .tracking(2)
                .foregroundStyle(ZD.Color.accent)

            Text("Read someone")
                .font(ZD.Font.display())
                .foregroundStyle(ZD.Color.textPrimary)

            Text("See how someone thinks, connects, reacts, and moves through the world.")
                .font(ZD.Font.body())
                .foregroundStyle(ZD.Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var savedPeople: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("YOUR PEOPLE")
                    .font(ZD.Font.caption(.semibold))
                    .tracking(1.6)
                    .foregroundStyle(ZD.Color.textSecondary)
                Spacer()
                Text("Identity cards can be shared")
                    .font(ZD.Font.caption())
                    .foregroundStyle(ZD.Color.textSecondary.opacity(0.75))
            }

            if people.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(people) { person in
                        Button {
                            person.lastOpenedAt = Date()
                            try? context.save()
                            AnalyticsService.shared.track(.savedPersonOpened(identityID: person.archetype.id))
                            selectedPerson = person
                        } label: {
                            SavedPersonRow(person: person)
                        }
                        .buttonStyle(SavedPersonRowButtonStyle())
                        .accessibilityLabel(
                            "\(person.name), \(person.westernSign.displayName) by \(person.chineseSign.displayName), \(person.identityPresentation?.archetype ?? person.archetype.title). View Identity."
                        )
                        .accessibilityHint("Opens this person’s Identity.")
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 30, weight: .medium))
                .foregroundStyle(ZD.Color.accent)
            Text("No one saved yet")
                .font(ZD.Font.body(.semibold))
                .foregroundStyle(ZD.Color.textPrimary)
            Text("Add someone to see their identity and Daily Lens. Their birth details stay on this device.")
                .font(ZD.Font.caption())
                .foregroundStyle(ZD.Color.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous).fill(ZD.Color.card))
    }
}

private struct SavedPersonRow: View {
    let person: SavedPerson

    private var visualStyle: SavedPersonVisualStyle {
        SavedPersonVisualStyle(westernSign: person.westernSign, chineseSign: person.chineseSign)
    }

    private var archetypeTitle: String {
        person.identityPresentation?.archetype ?? person.archetype.title
    }

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            rowAvatar

            VStack(alignment: .leading, spacing: 6) {
                Text(person.name)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(ZD.Color.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(person.signLine)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(ZD.Color.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Text(archetypeTitle)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(ZD.Color.textPrimary.opacity(0.94))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .layoutPriority(1)

                Label("View Identity", systemImage: "book.closed")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(ZD.Color.accentSoft.opacity(0.84))
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(ZD.Color.textSecondary.opacity(0.64))
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .leading)
        .contentShape(RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous))
        .background(
            RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            ZD.Color.cardAlt.opacity(0.88),
                            visualStyle.accent.opacity(0.055),
                            ZD.Color.card.opacity(0.96),
                            ZD.Color.forest.opacity(0.78)
                        ],
                        startPoint: visualStyle.gradientStart,
                        endPoint: visualStyle.gradientEnd
                    )
                )
                .overlay(identityMotif.clipShape(RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)))
                .overlay(
                    RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    ZD.Color.accent.opacity(0.30),
                                    visualStyle.accent.opacity(0.30),
                                    ZD.Color.border.opacity(0.18)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .overlay(alignment: .top) {
                    LinearGradient(
                        colors: [Color.white.opacity(0.055), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 34)
                    .clipShape(RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous))
                }
                .shadow(color: ZD.Color.shadow.opacity(0.24), radius: 12, x: 0, y: 7)
        )
    }

    private var rowAvatar: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [visualStyle.accent.opacity(0.24), ZD.Color.forest.opacity(0.04)],
                        center: .center,
                        startRadius: 8,
                        endRadius: 38
                    )
                )
                .frame(width: 70, height: 70)

            SavedPersonAvatar(person: person, size: 56)
                .overlay(
                    Circle()
                        .stroke(visualStyle.accent.opacity(0.34), lineWidth: 1)
                )
        }
        .accessibilityHidden(true)
    }

    private var identityMotif: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let variant = CGFloat(visualStyle.variant)
            let horizontalShift = (variant - 3) * 7
            let verticalShift = (variant.truncatingRemainder(dividingBy: 3) - 1) * 8

            ZStack {
                Circle()
                    .stroke(visualStyle.accent.opacity(0.075), lineWidth: 1)
                    .frame(width: 190 + (variant * 8), height: 190 + (variant * 8))
                    .position(x: width * 0.76 + horizontalShift, y: height * 0.46 + verticalShift)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [visualStyle.accent.opacity(0.075), .clear],
                            center: .center,
                            startRadius: 2,
                            endRadius: 44
                        )
                    )
                    .frame(width: 88, height: 88)
                    .position(x: width * 0.91 - horizontalShift * 0.3, y: height * 0.30 - verticalShift)

                RadialGradient(
                    colors: [visualStyle.accent.opacity(0.11), .clear],
                    center: .leading,
                    startRadius: 2,
                    endRadius: 120
                )
                .frame(width: 170, height: height * 1.25)
                .position(x: 50, y: height * 0.50)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct SavedPersonVisualStyle {
    let accent: Color
    let variant: Int
    let gradientStart: UnitPoint
    let gradientEnd: UnitPoint

    init(westernSign: WesternZodiac, chineseSign: ChineseZodiac) {
        switch westernSign {
        case .aries, .leo, .sagittarius:
            accent = Color(red: 0.72, green: 0.43, blue: 0.20) // muted amber
        case .cancer, .scorpio, .pisces:
            accent = Color(red: 0.20, green: 0.48, blue: 0.46) // deep blue-green
        case .gemini, .libra, .aquarius:
            accent = Color(red: 0.72, green: 0.73, blue: 0.69) // pearl silver
        case .taurus, .virgo, .capricorn:
            accent = Color(red: 0.34, green: 0.43, blue: 0.27) // muted moss
        }

        let stableKey = "\(westernSign.rawValue)|\(chineseSign.rawValue)"
        variant = stableKey.utf8.reduce(0) { (($0 * 31) + Int($1)) % 7 }

        let directions: [(UnitPoint, UnitPoint)] = [
            (.topLeading, .bottomTrailing),
            (.top, .bottomTrailing),
            (.topTrailing, .bottomLeading),
            (.leading, .bottomTrailing)
        ]
        (gradientStart, gradientEnd) = directions[variant % directions.count]
    }
}

private struct SavedPersonRowButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.99 : 1)
            .opacity(configuration.isPressed ? 0.94 : 1)
            .animation(
                reduceMotion ? nil : .easeOut(duration: 0.12),
                value: configuration.isPressed
            )
    }
}

private enum PersonEditorMode: Identifiable {
    case add
    case edit(SavedPerson)

    var id: UUID { person?.id ?? UUID(uuidString: "00000000-0000-0000-0000-000000000001")! }
    var person: SavedPerson? { if case let .edit(person) = self { return person }; return nil }
}

struct SavedPersonPhotoCropSession: Identifiable {
    let id = UUID()
    let image: UIImage
}

private struct SavedPersonEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Query private var people: [SavedPerson]

    let mode: PersonEditorMode
    let onSaved: (SavedPerson) -> Void

    @State private var name = ""
    @State private var birthDate = Date()
    @State private var imageItem: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var photoRemoved = false
    @State private var photoCropSession: SavedPersonPhotoCropSession?
    @State private var cropScale: CGFloat = 1
    @State private var cropOffset: CGSize = .zero
    @State private var cropBaselineOffset: CGSize = .zero
    @State private var cropBaselineScale: CGFloat = 1
    @State private var isSaving = false
    @State private var error: String?
    @State private var duplicate: SavedPerson?
    @State private var showReview = false
    @FocusState private var isNameFocused: Bool

    private var signs: CombinedSignResult { AstrologyCalculator.combinedSigns(from: birthDate) }
    private var isEditing: Bool { mode.person != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name")
                                .font(ZD.Font.caption(.semibold))
                                .foregroundStyle(ZD.Color.textSecondary)
                                .accessibilityHidden(true)
                            TextField("Name", text: $name)
                                .textContentType(.name)
                                .focused($isNameFocused)
                                .submitLabel(.done)
                                .onSubmit { isNameFocused = false }
                                .accessibilityLabel("Person's name")
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(savedPersonInputCard)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Birth date")
                                .font(ZD.Font.body())
                                .foregroundStyle(ZD.Color.textPrimary)
                            DatePicker("Birth date", selection: $birthDate, in: ...Date(), displayedComponents: .date)
                                .datePickerStyle(.wheel)
                                .labelsHidden()
                                .tint(ZD.Color.accent)
                                .frame(maxWidth: .infinity)
                                .frame(height: 154)
                                .clipped()
                                .simultaneousGesture(
                                    TapGesture().onEnded { isNameFocused = false }
                                )
                                .accessibilityLabel("Birth date")
                                .accessibilityHint("Used to calculate Western and Chinese signs")
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 14)
                        .padding(.bottom, 8)
                        .background(savedPersonInputCard)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .listRowBackground(Color.clear)
                } header: {
                    Text("ABOUT THEM")
                }

                Section {
                    VStack(spacing: 0) {
                        PremiumSignRow(label: "Western sign", value: signs.western.displayName)
                        Divider().overlay(ZD.Color.border.opacity(0.32))
                        PremiumSignRow(label: "Chinese sign", value: signs.chinese.displayName)
                    }
                    .accessibilityElement(children: .contain)
                } header: {
                    Text("Identity")
                }

                Section {
                    ZodianPhotoPicker(
                        hasPhoto: image != nil,
                        onImageSelected: selectPhoto,
                        onRemove: removePhoto
                    ) {
                        HStack(spacing: 14) {
                            Image(systemName: image == nil ? "person.crop.circle.badge.plus" : "photo.badge.arrow.down")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(ZD.Color.accent)
                                .frame(width: 34, height: 34)
                                .background(Circle().fill(ZD.Color.accent.opacity(0.10)))
                            VStack(alignment: .leading, spacing: 3) {
                                Text(image == nil ? "Choose a photo" : "Change photo")
                                    .font(ZD.Font.body(.semibold))
                                    .foregroundStyle(ZD.Color.textPrimary)
                                Text(image == nil ? "Add a face to make this feel personal" : "Choose another photo and frame it")
                                    .font(ZD.Font.caption())
                                    .foregroundStyle(ZD.Color.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(ZD.Color.textSecondary)
                        }
                    }
                    .accessibilityLabel(image == nil ? "Choose optional photo" : "Change and adjust photo")
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 104, height: 104)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(ZD.Color.accent.opacity(0.55), lineWidth: 1.2))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 6)
                            .accessibilityLabel("Selected photo for \(name.isEmpty ? "person" : name)")
                    }
                } header: {
                    Text("Photo (optional)")
                        .textCase(nil)
                }

                Section {
                    Button(action: beginReview) {
                        Text(isSaving ? "Saving…" : "Review")
                            .font(ZD.Font.body(.semibold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(ZD.Gradient.gold)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(isSaving)
                    .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    .listRowBackground(Color.clear)
                }

                if let error {
                    Section { Text(error).foregroundStyle(.red) }
                }
            }
            .navigationTitle(isEditing ? "Edit someone" : "Read someone")
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.interactively)
            .background(ZD.Color.bg)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
            .alert("Already saved", isPresented: Binding(get: { duplicate != nil }, set: { if !$0 { duplicate = nil } })) {
                Button("Edit existing") { if let duplicate { dismiss(); onSaved(duplicate) } }
                Button("Cancel", role: .cancel) { duplicate = nil }
            } message: {
                Text("Someone with this name and birth date is already saved.")
            }
            .sheet(isPresented: $showReview) {
                SavedPersonReviewSheet(
                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                    signLine: "\(signs.western.displayName) × \(signs.chinese.displayName)",
                    image: image,
                    isSaving: isSaving,
                    primaryTitle: isEditing ? "Save changes" : "Save to Your People",
                    onSave: saveReviewedPerson
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(ZD.Color.card)
            }
            .fullScreenCover(item: $photoCropSession) { session in
                SavedPersonPhotoCropView(
                    image: session.image,
                    scale: $cropScale,
                    offset: $cropOffset,
                    baselineOffset: $cropBaselineOffset,
                    baselineScale: $cropBaselineScale,
                    onCancel: cancelPhotoCrop,
                    onConfirm: { confirmPhotoCrop(image: session.image) }
                )
            }
            .onAppear { loadExisting() }
        }
    }

    private var savedPersonInputCard: some View {
        RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
            .fill(ZD.Color.card)
            .overlay(
                RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                    .stroke(ZD.Color.border.opacity(0.30), lineWidth: 1)
            )
    }

    private func loadExisting() {
        guard let person = mode.person else { return }
        name = person.name
        birthDate = person.birthDate
        if let fileName = person.photoFileName { image = SavedPersonImageStore.load(fileName: fileName) }
    }

    private func selectPhoto(_ image: UIImage) {
        photoRemoved = false
        cropScale = 1
        cropBaselineScale = 1
        cropOffset = .zero
        cropBaselineOffset = .zero
        photoCropSession = SavedPersonPhotoCropSession(
            image: image.normalizedForSavedPersonCrop()
        )
    }

    private func removePhoto() {
        image = nil
        photoRemoved = true
        imageItem = nil
        photoCropSession = nil
    }

    private func cancelPhotoCrop() {
        photoCropSession = nil
        imageItem = nil
    }

    private func confirmPhotoCrop(image selectedImage: UIImage) {
        image = selectedImage.savedPersonCircularCrop(scale: cropScale, offset: cropOffset)
        photoCropSession = nil
        imageItem = nil
    }

    private func beginReview() {
        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (1...40).contains(cleanedName.count) else { error = "Enter a name between 1 and 40 characters."; return }
        let calendar = Calendar.current
        if let existing = people.first(where: { candidate in
            candidate.id != mode.person?.id && candidate.name.compare(cleanedName, options: .caseInsensitive) == .orderedSame && calendar.isDate(candidate.birthDate, inSameDayAs: birthDate)
        }) { duplicate = existing; return }

        showReview = true
    }

    private func saveReviewedPerson() {
        let cleanedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        isSaving = true
        let savedFileName: String?
        if photoRemoved {
            if let previous = mode.person?.photoFileName { SavedPersonImageStore.delete(fileName: previous) }
            savedFileName = nil
        } else {
            savedFileName = image.flatMap { SavedPersonImageStore.save($0, replacing: mode.person?.photoFileName) } ?? mode.person?.photoFileName
        }
        let result = AstrologyCalculator.combinedSigns(from: birthDate)
        let saved: SavedPerson
        if let person = mode.person {
            person.name = cleanedName; person.birthDate = birthDate; person.westernSignRaw = result.western.rawValue; person.chineseSignRaw = result.chinese.rawValue; person.photoFileName = savedFileName; person.updatedAt = Date(); saved = person
        } else {
            saved = SavedPerson(name: cleanedName, birthDate: birthDate, westernSignRaw: result.western.rawValue, chineseSignRaw: result.chinese.rawValue, photoFileName: savedFileName)
            context.insert(saved)
        }
        do {
            try context.save()
            AnalyticsService.shared.track(isEditing ? .savedPersonEdited(identityID: saved.archetype.id) : .savedPersonSaved(identityID: saved.archetype.id))
            dismiss()
            onSaved(saved)
        } catch let saveError {
            _ = saveError
            error = "Couldn’t save this person. Try again."
            isSaving = false
        }
    }
}

private struct PremiumSignRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let label: String
    let value: String

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 5) {
                    labelText
                    valueText
                }
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 18) {
                    labelText
                    Spacer(minLength: 12)
                    valueText
                        .multilineTextAlignment(.trailing)
                }
            }
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label), \(value)")
    }

    private var labelText: some View {
        Text(label)
            .font(ZD.Font.caption())
            .foregroundStyle(ZD.Color.textSecondary)
    }

    private var valueText: some View {
        Text(value)
            .font(ZD.Font.body(.semibold))
            .foregroundStyle(ZD.Color.accent.opacity(0.92))
            .fixedSize(horizontal: false, vertical: true)
    }
}

private struct SavedPersonReviewSheet: View {
    @Environment(\.dismiss) private var dismiss
    let name: String
    let signLine: String
    let image: UIImage?
    let isSaving: Bool
    let primaryTitle: String
    let onSave: () -> Void

    var body: some View {
        VStack(spacing: 22) {
            Spacer(minLength: 8)

            Group {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    ZStack {
                        Circle().fill(ZD.Color.accent.opacity(0.10))
                        Image(systemName: "person.fill")
                            .font(.system(size: 34, weight: .medium))
                            .foregroundStyle(ZD.Color.accent.opacity(0.82))
                    }
                }
            }
            .frame(width: 92, height: 92)
            .clipShape(Circle())
            .overlay(Circle().stroke(ZD.Color.accent.opacity(0.48), lineWidth: 1.2))
            .accessibilityHidden(true)

            VStack(spacing: 7) {
                Text(name)
                    .font(ZD.Font.display())
                    .foregroundStyle(ZD.Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
                Text(signLine)
                    .font(ZD.Font.body(.semibold))
                    .foregroundStyle(ZD.Color.accent.opacity(0.92))
                Text("You can edit this later.")
                    .font(ZD.Font.caption())
                    .foregroundStyle(ZD.Color.textSecondary)
            }
            .accessibilityElement(children: .combine)

            Button(action: onSave) {
                HStack(spacing: 10) {
                    if isSaving { ProgressView().tint(.black) }
                    Text(isSaving ? "Saving…" : primaryTitle)
                }
                .font(ZD.Font.body(.semibold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(ZD.Gradient.gold)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(isSaving)
            .accessibilityHint("Saves this person to Your People")

            Button("Keep editing") { dismiss() }
                .font(ZD.Font.caption(.semibold))
                .foregroundStyle(ZD.Color.textSecondary)
                .disabled(isSaving)
        }
        .padding(.horizontal, 28)
        .padding(.bottom, 20)
    }
}

private let savedPersonCropSize = min(UIScreen.main.bounds.width - 56, 344)

struct SavedPersonPhotoCropView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let image: UIImage
    @Binding var scale: CGFloat
    @Binding var offset: CGSize
    @Binding var baselineOffset: CGSize
    @Binding var baselineScale: CGFloat
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [ZD.Color.card, Color.black, ZD.Color.bg],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button("Cancel", action: onCancel)
                        .foregroundStyle(ZD.Color.textSecondary)
                    Spacer()
                    Text("Position photo")
                        .font(ZD.Font.caption(.semibold))
                        .tracking(1.2)
                        .textCase(.uppercase)
                        .foregroundStyle(ZD.Color.accent)
                    Spacer()
                    Text("Cancel").hidden()
                }
                .padding(.horizontal, 22)
                .padding(.top, 18)

                Spacer()

                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: savedPersonCropSize, height: savedPersonCropSize)
                        .scaleEffect(scale)
                        .offset(offset)
                        .clipShape(Circle())

                    Circle()
                        .strokeBorder(Color.white.opacity(0.88), lineWidth: 1.5)
                        .frame(width: savedPersonCropSize, height: savedPersonCropSize)
                        .shadow(color: ZD.Color.accent.opacity(0.28), radius: 22)
                        .allowsHitTesting(false)
                }
                .frame(width: savedPersonCropSize, height: savedPersonCropSize)
                .contentShape(Circle())
                .highPriorityGesture(dragGesture)
                .simultaneousGesture(magnificationGesture)
                .accessibilityLabel("Circular photo crop preview")
                .accessibilityHint("Drag to reposition and pinch to zoom")

                Text("Pinch to zoom · Drag to reposition")
                    .font(ZD.Font.caption())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .padding(.top, 22)

                Spacer()

                HStack(spacing: 12) {
                    Button("Reset") {
                        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
                            scale = 1
                            baselineScale = 1
                            offset = .zero
                            baselineOffset = .zero
                        }
                    }
                    .font(ZD.Font.body(.semibold))
                    .foregroundStyle(ZD.Color.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(ZD.Color.card.opacity(0.78))
                    .clipShape(Capsule())

                    Button(action: onConfirm) {
                        Label("Use photo", systemImage: "checkmark")
                            .font(ZD.Font.body(.semibold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(ZD.Gradient.gold)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 24)
            }
        }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { value in
                offset = clamped(
                    CGSize(
                        width: baselineOffset.width + value.translation.width,
                        height: baselineOffset.height + value.translation.height
                    ),
                    scale: scale
                )
            }
            .onEnded { _ in baselineOffset = offset }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = min(max(baselineScale * value, 1), 3.2)
                offset = clamped(offset, scale: scale)
            }
            .onEnded { _ in
                baselineScale = scale
                baselineOffset = offset
            }
    }

    private func clamped(_ proposed: CGSize, scale: CGFloat) -> CGSize {
        let aspect = image.size.width / max(image.size.height, 1)
        let baseWidth = aspect >= 1 ? savedPersonCropSize * aspect : savedPersonCropSize
        let baseHeight = aspect >= 1 ? savedPersonCropSize : savedPersonCropSize / max(aspect, 0.001)
        let xLimit = max((baseWidth * scale - savedPersonCropSize) / 2, 0)
        let yLimit = max((baseHeight * scale - savedPersonCropSize) / 2, 0)
        return CGSize(
            width: min(max(proposed.width, -xLimit), xLimit),
            height: min(max(proposed.height, -yLimit), yLimit)
        )
    }
}

private struct SavedPersonSuccessToast: View {
    let name: String

    var body: some View {
        Label("\(name) added to Your People", systemImage: "checkmark.circle.fill")
            .font(ZD.Font.body(.semibold))
            .foregroundStyle(ZD.Color.textPrimary)
            .padding(.horizontal, 18)
            .padding(.vertical, 13)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(Capsule().stroke(ZD.Color.accent.opacity(0.38), lineWidth: 1))
            .shadow(color: .black.opacity(0.28), radius: 18, y: 8)
            .accessibilityAddTraits(.isStaticText)
    }
}

extension UIImage {
    func normalizedForSavedPersonCrop() -> UIImage {
        guard imageOrientation != .up else { return self }
        let format = UIGraphicsImageRendererFormat()
        format.scale = scale
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }

    func savedPersonCircularCrop(scale zoom: CGFloat, offset: CGSize) -> UIImage {
        let normalized = normalizedForSavedPersonCrop()
        let cropSize = savedPersonCropSize
        let aspect = normalized.size.width / max(normalized.size.height, 1)
        let baseScale = aspect >= 1
            ? cropSize / normalized.size.height
            : cropSize / normalized.size.width
        let displayScale = baseScale * min(max(zoom, 1), 3.2)
        let sourceSide = cropSize / displayScale
        let center = CGPoint(
            x: normalized.size.width / 2 - offset.width / displayScale,
            y: normalized.size.height / 2 - offset.height / displayScale
        )
        let sourceRect = CGRect(
            x: min(max(center.x - sourceSide / 2, 0), max(normalized.size.width - sourceSide, 0)),
            y: min(max(center.y - sourceSide / 2, 0), max(normalized.size.height - sourceSide, 0)),
            width: min(sourceSide, normalized.size.width),
            height: min(sourceSide, normalized.size.height)
        )
        let pixelScale = normalized.scale
        let pixelRect = CGRect(
            x: sourceRect.minX * pixelScale,
            y: sourceRect.minY * pixelScale,
            width: sourceRect.width * pixelScale,
            height: sourceRect.height * pixelScale
        ).integral
        guard let cgImage = normalized.cgImage?.cropping(to: pixelRect) else {
            return normalized
        }
        return UIImage(cgImage: cgImage, scale: normalized.scale, orientation: .up)
    }
}

private struct SavedPersonProfileView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let person: SavedPerson
    let onEdit: () -> Void
    @State private var showsDeleteConfirmation = false
    @State private var sharePayload: SharePayload?
    @State private var showCompatibilityTeaser = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                compactIdentityHeader

                IdentityRevealCardView(content: person.identityCardContent, animatesIdentityTitle: !UIAccessibility.isReduceMotionEnabled)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(person.name)'s identity card. \(person.identityCardContent.signCombination). \(person.identityCardContent.identityName).")

                actionSectionLabel("UNDERSTAND")

                NavigationLink { SavedPersonIdentityView(person: person) } label: {
                    primaryActionRow("Read full Identity", icon: "book.closed")
                }

                NavigationLink { SavedPersonTodayLensView(person: person) } label: {
                    primaryActionRow("View Daily Lens", icon: "sun.max")
                }

                Button {
                    AnalyticsService.shared.track(.compatibilityTeaserTapped(identityID: person.archetype.id, premiumActive: store.effectivePremiumAccess))
                    showCompatibilityTeaser = true
                } label: {
                    primaryActionRow(
                        "See How You Connect",
                        icon: "heart",
                        trailingIcon: store.effectivePremiumAccess ? "chevron.right" : "lock.fill",
                        trailingAccessibilityValue: store.effectivePremiumAccess ? nil : "Premium"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("See How You Connect")
                .accessibilityHint(store.effectivePremiumAccess ? "Shows the Compatibility preview" : "Shows the Zodian Premium Compatibility preview")

                Button {
                    if let image = IdentityRevealShareRenderer.renderImage(for: person.identityCardContent) {
                        sharePayload = SharePayload(image: image)
                    }
                    AnalyticsService.shared.track(.savedPersonShared(identityID: person.archetype.id))
                } label: {
                    primaryActionRow("Share identity card", icon: "square.and.arrow.up")
                }
                .buttonStyle(.plain)

                actionSectionLabel("MANAGE")

                Button(action: onEdit) {
                    managementActionRow("Edit person", icon: "pencil")
                }
                .buttonStyle(.plain)

                Button(role: .destructive) {
                    showsDeleteConfirmation = true
                } label: {
                    managementActionRow("Remove person", icon: "trash", destructive: true)
                }
                .buttonStyle(.plain)
            }
            .padding(ZD.Spacing.l)
            .padding(.bottom, 40)
        }
        .background(ZD.Color.bg.ignoresSafeArea())
        .navigationTitle(person.name)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Remove \(person.name)?", isPresented: $showsDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive, action: remove)
        } message: { Text("This removes their locally saved identity. It does not affect your own profile or Daily Lens.") }
        .sheet(item: $sharePayload) { payload in ActivityShareSheet(activityItems: [payload.image]) }
        .sheet(isPresented: $showCompatibilityTeaser) {
            CompatibilityTeaserSheet(person: person, user: store.currentUser)
                .environmentObject(store)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationContentInteraction(.scrolls)
                .preferredColorScheme(.dark)
        }
    }

    @ViewBuilder
    private var compactIdentityHeader: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 12) {
                SavedPersonAvatar(person: person, size: 60)
                    .accessibilityHidden(true)
                compactIdentityHeaderText
            }
        } else {
            HStack(alignment: .center, spacing: 14) {
                SavedPersonAvatar(person: person, size: 60)
                    .accessibilityHidden(true)
                compactIdentityHeaderText
                Spacer(minLength: 0)
            }
        }
    }

    private var compactIdentityHeaderText: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(person.name)
                .font(ZD.Font.heading())
                .foregroundStyle(ZD.Color.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Text(person.signLine)
                .font(ZD.Font.caption(.semibold))
                .foregroundStyle(ZD.Color.accent)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func actionSectionLabel(_ title: String) -> some View {
        Text(title)
            .font(ZD.Font.caption(.semibold))
            .tracking(1.4)
            .foregroundStyle(ZD.Color.textSecondary)
            .padding(.top, 4)
    }

    private func primaryActionRow(
        _ title: String,
        icon: String,
        trailingIcon: String = "chevron.right",
        trailingAccessibilityValue: String? = nil
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(ZD.Color.accent)
                .frame(width: 28)

            Text(title)
                .font(ZD.Font.body(.semibold))

            Spacer(minLength: 12)

            Image(systemName: trailingIcon)
                .font(.caption.bold())
                .foregroundStyle(trailingIcon == "lock.fill" ? ZD.Color.accent : ZD.Color.textSecondary)
                .accessibilityValue(trailingAccessibilityValue ?? "")
        }
        .foregroundStyle(ZD.Color.textPrimary)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous)
                .fill(ZD.Color.card)
                .overlay(
                    RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous)
                        .stroke(ZD.Color.accent.opacity(0.14), lineWidth: 1)
                )
        )
    }

    private func managementActionRow(_ title: String, icon: String, destructive: Bool = false) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .frame(width: 22)

            Text(title)
                .font(ZD.Font.caption(.semibold))

            Spacer(minLength: 0)
        }
        .foregroundStyle(destructive ? .red.opacity(0.82) : ZD.Color.textSecondary)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous)
                .fill(ZD.Color.card.opacity(0.54))
        )
    }

    private func remove() {
        if let fileName = person.photoFileName { SavedPersonImageStore.delete(fileName: fileName) }
        AnalyticsService.shared.track(.savedPersonRemoved(identityID: person.archetype.id))
        context.delete(person)
        try? context.save()
        dismiss()
    }
}

private struct SavedPersonIdentityView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let person: SavedPerson

    private var presentation: IdentityPresentation? {
        person.identityPresentation
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollProxy in
                ScrollView {
                    Group {
                        if let canonical = person.canonicalIdentityProfile {
                            IdentityCanonicalProfileView(
                                cardContent: person.identityCardContent,
                                profile: canonical,
                                onSectionExpanded: { section in
                                    scrollCanonicalSection(section, proxy: scrollProxy)
                                }
                            )
                        } else if let presentation {
                            IdentityEditorialProfileView(
                                cardContent: person.identityCardContent,
                                presentation: presentation,
                                closeCompany: person.identityEditorialProfile?.closeCompany
                                    ?? person.archetype.compatibilityNotes,
                                onSectionExpanded: { section in
                                    scrollExpandedSection(section, proxy: scrollProxy)
                                }
                            )
                        } else {
                            Text("This identity is unavailable right now.")
                                .font(ZD.Font.body())
                                .foregroundStyle(ZD.Color.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.top, 18)
                    .padding(.horizontal, 20)
                    .padding(
                        .bottom,
                        IdentityEditorialNavigationClearance.bottomInset(
                            safeAreaBottom: geometry.safeAreaInsets.bottom
                        )
                    )
                }
            }
        }
        .background(
            ZD.Color.bg
                .overlay(
                    RadialGradient(
                        colors: [ZD.Color.accent.opacity(0.08), .clear],
                        center: .topLeading,
                        startRadius: 20,
                        endRadius: 560
                    )
                )
                .ignoresSafeArea()
        )
        .navigationTitle("\(person.name)’s Identity")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            AnalyticsService.shared.track(.savedPersonIdentityViewed(identityID: person.archetype.id))
        }
    }

    private func scrollExpandedSection(
        _ section: IdentityEditorialSectionKind,
        proxy: ScrollViewProxy
    ) {
        let scroll = {
            // Match the owner route: reveal the opened section without
            // discarding the reader's current position.
            proxy.scrollTo(section.id)
        }

        if reduceMotion {
            scroll()
        } else {
            withAnimation(.easeInOut(duration: 0.24), scroll)
        }
    }

    private func scrollCanonicalSection(
        _ section: String,
        proxy: ScrollViewProxy
    ) {
        let scroll = { proxy.scrollTo(section) }
        if reduceMotion {
            scroll()
        } else {
            withAnimation(.easeInOut(duration: 0.24), scroll)
        }
    }
}

private struct SavedPersonTodayLensView: View {
    let person: SavedPerson
    @State private var content: DailyLensContent?
    @State private var errorMessage: String?
#if DEBUG
    @State private var debugFreshnessMetadata: DailyRitualFetchMetadata?
    @State private var debugEditorialVoiceV21Diagnostics: TodaysLensEditorialVoiceV21Amendment1Diagnostics?
    @State private var debugTerminalError: String?
#endif

    var body: some View {
        GeometryReader { geometry in
            Group {
                if let content {
                    ScrollView {
                        VStack(spacing: 12) {
#if DEBUG
                            if let debugFreshnessMetadata {
                                DailyLensFreshnessDiagnosticsView(metadata: debugFreshnessMetadata)
                            }
                            savedPersonLensRequestDiagnostics
                            if DailyLensCandidateRuntimeFixture.isEditorialVoiceV21Amendment1Enabled {
                                TodaysLensEditorialVoiceV21Amendment1PreviewControls(
                                    reload: {
                                        Task { await loadLens() }
                                    },
                                    diagnostics: debugEditorialVoiceV21Diagnostics
                                )
                            }
#endif
                            SavedPersonLensEditorialCard(
                                signLine: person.signLine,
                                content: content
                            )
                        }
                        .padding(.horizontal, ZD.Spacing.l)
                        .padding(.top, 20)
                        .padding(
                            .bottom,
                            IdentityEditorialNavigationClearance.bottomInset(
                                safeAreaBottom: geometry.safeAreaInsets.bottom
                            )
                        )
                    }
                } else if let errorMessage {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(errorMessage)
                            .font(ZD.Font.body())
                            .foregroundStyle(ZD.Color.textSecondary)
#if DEBUG
                        savedPersonLensRequestDiagnostics
#endif
                    }
                    .padding(ZD.Spacing.l)
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    ProgressView("Preparing \(person.name)’s Lens…")
                        .tint(ZD.Color.accent)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(
            ZD.Color.bg
                .overlay(
                    RadialGradient(
                        colors: [ZD.Color.forest.opacity(0.40), .clear],
                        center: .topTrailing,
                        startRadius: 10,
                        endRadius: 520
                    )
                )
                .ignoresSafeArea()
        )
        .navigationTitle("\(person.name)’s Lens")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadLens()
        }
    }

    private func loadLens() async {
        errorMessage = nil
        content = nil
#if DEBUG
        debugFreshnessMetadata = nil
        debugEditorialVoiceV21Diagnostics = nil
        debugTerminalError = nil

        if DailyLensCandidateRuntimeFixture.isEditorialVoiceV21Amendment1Enabled {
            let date = Self.localDateString(Date())
            let selection = TodaysLensEditorialVoiceV21Amendment1Preview.selection(
                date: date,
                westernSign: person.westernSign.displayName,
                easternSign: person.chineseSign.displayName
            )
            guard let fixture = selection.fixture else {
                errorMessage = "The selected Editorial Voice v2.1 candidate is unavailable."
                return
            }
            let control = DailyLensCandidateRuntimeFixture.editorialVoiceV21Amendment1ControlResponse(
                fixture: fixture,
                date: date
            )
            content = await resolveLensContent(for: control)
            debugEditorialVoiceV21Diagnostics = TodaysLensEditorialVoiceV21Amendment1Diagnostics.make(
                selection: selection
            )
            AnalyticsService.shared.track(.savedPersonLensViewed(identityID: person.archetype.id))
            return
        }
#endif

        let outcome = await DailyRitualService.shared.fetchTodaysLens(
            westernSign: person.westernSign.displayName,
            easternSign: person.chineseSign.displayName,
            requestScope: .savedPerson
        )
        switch outcome {
        case .ready(let lens, let metadata):
            content = lens
#if DEBUG
            debugFreshnessMetadata = metadata
#endif
        case .notReady:
            errorMessage = "Daily Lens is still being prepared."
#if DEBUG
            debugTerminalError = "unavailable"
#endif
        case .failed(let message):
            errorMessage = message
#if DEBUG
            debugTerminalError = message
#endif
        }
        AnalyticsService.shared.track(.savedPersonLensViewed(identityID: person.archetype.id))
    }

#if DEBUG
    private var savedPersonLensRequestDiagnostics: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("SAVED PERSON LENS REQUEST")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
            diagnosticLine("identity", "\(person.westernSign.displayName.lowercased()) × \(person.chineseSign.displayName.lowercased())")
            diagnosticLine("environment", AppConfiguration.environment.rawValue)
            diagnosticLine("content date", Self.localDateString(Date()))
            diagnosticLine("batch id", debugFreshnessMetadata?.batchID ?? "unavailable")
            diagnosticLine("cache", debugFreshnessMetadata?.origin == .deviceCache ? "hit" : "miss")
            diagnosticLine("endpoint", debugFreshnessMetadata?.endpointStatus.map(String.init) ?? "no network response")
            diagnosticLine(
                "provenance",
                debugFreshnessMetadata?.storedProvenance
                    ?? content.map {
                        $0.version == .editorialVoiceV21Amendment1
                            ? "native_v2_1_amendment_1"
                            : $0.version.rawValue
                    }
                    ?? "unavailable"
            )
            diagnosticLine(
                "status",
                debugFreshnessMetadata.map {
                    "\($0.freshness.rawValue) / \($0.publicationStatus ?? "unknown")"
                } ?? "unavailable"
            )
            diagnosticLine("terminal error", debugTerminalError ?? "none")
        }
        .font(.system(size: 10, weight: .medium, design: .monospaced))
        .foregroundStyle(ZD.Color.textSecondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(ZD.Color.card.opacity(0.72))
        )
    }

    private func diagnosticLine(_ label: String, _ value: String) -> some View {
        Text("\(label): \(value)")
            .fixedSize(horizontal: false, vertical: true)
    }
#endif

    private func resolveLensContent(for ritual: DailyRitualResponse) async -> DailyLensContent {
        #if DEBUG
        let router = DailyLensCandidateRuntimeFixture.routerIfRequested() ?? DailyLensContentRouter()
        #else
        let router = DailyLensContentRouter()
        #endif
        return await router.resolve(
            control: ritual,
            date: Self.localDateString(Date()),
            westernSign: person.westernSign.displayName,
            easternSign: person.chineseSign.displayName
        )
    }

    private static func localDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "America/Los_Angeles") ?? .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

private struct SavedPersonLensEditorialCard: View {
    let signLine: String
    let content: DailyLensContent

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            ZD.Color.card.opacity(0.98),
                            ZD.Color.forest.opacity(0.92),
                            ZD.Color.cardAlt.opacity(0.96)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            savedPersonLensAtmosphere

            VStack(alignment: .leading, spacing: 18) {
                VStack(alignment: .leading, spacing: 7) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12, weight: .semibold))
                        Text("DAILY LENS")
                            .font(ZD.Font.caption(.semibold))
                            .tracking(1.8)
                    }
                    .foregroundStyle(ZD.Color.accent)

                    Text(signLine)
                        .font(ZD.Font.caption(.semibold))
                        .tracking(1.1)
                        .foregroundStyle(ZD.Color.textSecondary.opacity(0.88))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [ZD.Color.accent.opacity(0.62), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 112, height: 1)

                DailyLensTitleReadView(
                    content: content,
                    titleBaseSize: 29,
                    readBaseSize: 16
                )
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 26)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            ZD.Color.accent.opacity(0.38),
                            ZD.Color.accentSoft.opacity(0.12),
                            ZD.Color.border.opacity(0.22)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.30), radius: 22, y: 12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(signLine). \(content.accessibilityLabel)")
    }

    private var savedPersonLensAtmosphere: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                RadialGradient(
                    colors: [ZD.Color.accent.opacity(0.085), .clear],
                    center: .topTrailing,
                    startRadius: 4,
                    endRadius: max(width, height) * 0.62
                )

                Circle()
                    .stroke(ZD.Color.accent.opacity(0.09), lineWidth: 1)
                    .frame(width: width * 0.72, height: width * 0.72)
                    .position(x: width * 0.88, y: height * 0.22)

                Ellipse()
                    .stroke(Color.white.opacity(0.045), lineWidth: 1)
                    .frame(width: width * 1.16, height: min(height * 0.52, 230))
                    .rotationEffect(.degrees(-11))
                    .position(x: width * 0.46, y: height * 0.55)

                Ellipse()
                    .stroke(
                        ZD.Color.accent.opacity(0.055),
                        style: StrokeStyle(lineWidth: 1, dash: [7, 11])
                    )
                    .frame(width: width * 0.86, height: min(height * 0.38, 170))
                    .rotationEffect(.degrees(13))
                    .position(x: width * 0.52, y: height * 0.58)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct SavedPersonAvatar: View {
    let name: String
    let photoFileName: String?
    let size: CGFloat

    init(person: SavedPerson, size: CGFloat) {
        self.init(name: person.name, photoFileName: person.photoFileName, size: size)
    }

    init(name: String, photoFileName: String?, size: CGFloat) {
        self.name = name
        self.photoFileName = photoFileName
        self.size = size
    }

    var body: some View {
        Group {
            if let photoFileName, let image = SavedPersonImageStore.load(fileName: photoFileName) {
                Image(uiImage: image).resizable().scaledToFill()
            } else {
                Text(String(name.prefix(1)).uppercased())
                    .font(.system(size: size * 0.38, weight: .bold, design: .serif))
                    .foregroundStyle(ZD.Color.accent)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(ZD.Color.cardAlt)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .accessibilityLabel("Photo for \(name)")
    }
}

enum SavedPersonImageStore {
    static func save(_ image: UIImage, replacing previous: String?) -> String? { guard let data = image.jpegData(compressionQuality: 0.84) else { return nil }; let name = "saved-person-\(UUID().uuidString).jpg"; let url = url(for: name); do { try data.write(to: url, options: .atomic); if let previous { delete(fileName: previous) }; return name } catch { return nil } }
    static func load(fileName: String) -> UIImage? { UIImage(contentsOfFile: url(for: fileName).path) }
    static func delete(fileName: String) { try? FileManager.default.removeItem(at: url(for: fileName)) }
    private static func url(for fileName: String) -> URL { let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("SavedPeople", isDirectory: true); try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true); return root.appendingPathComponent(fileName) }
}

private struct SharePayload: Identifiable {
    let id = UUID()
    let image: UIImage
}
