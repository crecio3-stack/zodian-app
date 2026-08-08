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

    var body: some View {
        NavigationStack {
            ZStack {
                ZD.Color.bg.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        header

                        Button {
                            AnalyticsService.shared.track(.readSomeoneStarted)
                            editorMode = .add
                        } label: {
                            Label("Read someone", systemImage: "person.badge.plus")
                                .font(ZD.Font.body(.semibold))
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Capsule().fill(ZD.Color.accent))
                        }
                        .buttonStyle(.plain)
                        .accessibilityHint("Add a person by name and birth date")

                        savedPeople
                    }
                    .padding(.horizontal, ZD.Spacing.l)
                    .padding(.top, 20)
                    .padding(.bottom, 120)
                }
            }
            .navigationTitle("Connect")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(item: $selectedPerson) { person in
                SavedPersonProfileView(person: person, onEdit: { editorMode = .edit(person) })
            }
            .sheet(item: $editorMode) { mode in
                SavedPersonEditorView(mode: mode) { saved in
                    selectedPerson = saved
                }
            }
            .onAppear {
                AnalyticsService.shared.track(.readSomeoneOpened)
            }
        }
        .preferredColorScheme(.dark)
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
                Text("SAVED PEOPLE")
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
                        .buttonStyle(.plain)
                        .accessibilityLabel("Open \(person.name), \(person.signLine)")
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

    var body: some View {
        HStack(spacing: 14) {
            SavedPersonAvatar(person: person, size: 52)
            VStack(alignment: .leading, spacing: 4) {
                Text(person.name)
                    .font(ZD.Font.body(.semibold))
                    .foregroundStyle(ZD.Color.textPrimary)
                Text(person.signLine)
                    .font(ZD.Font.caption(.semibold))
                    .foregroundStyle(ZD.Color.accent)
                Text(person.archetype.tagline)
                    .font(ZD.Font.caption())
                    .foregroundStyle(ZD.Color.textSecondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(ZD.Color.textSecondary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous)
                .fill(ZD.Color.card)
                .overlay(RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous).stroke(ZD.Color.border.opacity(0.25), lineWidth: 1))
        )
    }
}

private enum PersonEditorMode: Identifiable {
    case add
    case edit(SavedPerson)

    var id: UUID { person?.id ?? UUID(uuidString: "00000000-0000-0000-0000-000000000001")! }
    var person: SavedPerson? { if case let .edit(person) = self { return person }; return nil }
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
    @State private var isSaving = false
    @State private var error: String?
    @State private var duplicate: SavedPerson?
    @State private var showReview = false

    private var signs: CombinedSignResult { AstrologyCalculator.combinedSigns(from: birthDate) }
    private var isEditing: Bool { mode.person != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("ABOUT THEM") {
                    TextField("Name", text: $name)
                        .textContentType(.name)
                        .accessibilityLabel("Person's name")
                    DatePicker("Birth date", selection: $birthDate, in: ...Date(), displayedComponents: .date)
                        .accessibilityHint("Used to calculate Western and Chinese signs")
                }

                Section("IDENTITY") {
                    LabeledContent("Western sign", value: signs.western.displayName)
                    LabeledContent("Chinese sign", value: signs.chinese.displayName)
                    Text("Birth time and location are not needed for this read.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Section("PHOTO") {
                    PhotosPicker(selection: $imageItem, matching: .images) {
                        Label(image == nil ? "Add optional photo" : "Change photo", systemImage: "photo")
                    }
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 84, height: 84)
                            .clipShape(Circle())
                            .accessibilityLabel("Selected photo for \(name.isEmpty ? "person" : name)")
                    }
                }

                Section {
                    Button(isSaving ? "Saving…" : "Review person") { beginReview() }
                        .disabled(isSaving)
                }

                if let error {
                    Section { Text(error).foregroundStyle(.red) }
                }
            }
            .navigationTitle(isEditing ? "Edit someone" : "Read someone")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
            .alert("Already saved", isPresented: Binding(get: { duplicate != nil }, set: { if !$0 { duplicate = nil } })) {
                Button("Edit existing") { if let duplicate { dismiss(); onSaved(duplicate) } }
                Button("Cancel", role: .cancel) { duplicate = nil }
            } message: {
                Text("Someone with this name and birth date is already saved.")
            }
            .confirmationDialog(
                "Review \(name.trimmingCharacters(in: .whitespacesAndNewlines))",
                isPresented: $showReview,
                titleVisibility: .visible
            ) {
                Button("Save person") { saveReviewedPerson() }
                Button("Keep editing", role: .cancel) { }
            } message: {
                Text("\(signs.western.displayName) × \(signs.chinese.displayName). Birth time and location are not required or saved.")
            }
            .task(id: imageItem) { await loadImage() }
            .onAppear { loadExisting() }
        }
    }

    private func loadExisting() {
        guard let person = mode.person else { return }
        name = person.name
        birthDate = person.birthDate
        if let fileName = person.photoFileName { image = SavedPersonImageStore.load(fileName: fileName) }
    }

    private func loadImage() async {
        guard let imageItem,
              let data = try? await imageItem.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }
        self.image = image
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
        let savedFileName = image.flatMap { SavedPersonImageStore.save($0, replacing: mode.person?.photoFileName) } ?? mode.person?.photoFileName
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

private struct SavedPersonProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    let person: SavedPerson
    let onEdit: () -> Void
    @State private var showsDeleteConfirmation = false
    @State private var sharePayload: SharePayload?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 14) {
                    SavedPersonAvatar(person: person, size: 64)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(person.name).font(ZD.Font.heading()).foregroundStyle(ZD.Color.textPrimary)
                        Text(person.signLine).font(ZD.Font.caption(.semibold)).foregroundStyle(ZD.Color.accent)
                        Text(person.archetype.tagline).font(ZD.Font.caption()).foregroundStyle(ZD.Color.textSecondary)
                    }
                    Spacer()
                }

                IdentityRevealCardView(content: person.identityCardContent, animatesIdentityTitle: !UIAccessibility.isReduceMotionEnabled)
                    .accessibilityLabel("\(person.name)'s identity card. \(person.identityCardContent.signCombination). \(person.identityCardContent.identityName).")

                NavigationLink { SavedPersonIdentityView(person: person) } label: { actionRow("Read full identity", icon: "book.closed") }
                NavigationLink { SavedPersonTodayLensView(person: person) } label: { actionRow("Open \(person.name)'s Daily Lens", icon: "sun.max") }
                Button { if let image = IdentityRevealShareRenderer.renderImage(for: person.identityCardContent) { sharePayload = SharePayload(image: image) }; AnalyticsService.shared.track(.savedPersonShared(identityID: person.archetype.id)) } label: { actionRow("Share identity card", icon: "square.and.arrow.up") }
                    .buttonStyle(.plain)
                Button(action: onEdit) { actionRow("Edit person", icon: "pencil") }.buttonStyle(.plain)
                Button(role: .destructive) { showsDeleteConfirmation = true } label: { actionRow("Remove person", icon: "trash", destructive: true) }.buttonStyle(.plain)
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
    }

    private func actionRow(_ title: String, icon: String, destructive: Bool = false) -> some View {
        HStack { Label(title, systemImage: icon).font(ZD.Font.body(.semibold)); Spacer(); Image(systemName: "chevron.right").font(.caption.bold()) }
            .foregroundStyle(destructive ? .red : ZD.Color.textPrimary)
            .padding(16).frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous).fill(ZD.Color.card))
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
    let person: SavedPerson
    var body: some View {
        ScrollView { VStack(alignment: .leading, spacing: 20) {
            IdentityRevealCardView(content: person.identityCardContent, animatesIdentityTitle: !UIAccessibility.isReduceMotionEnabled)
            identitySection("HOW THEY MOVE", text: person.archetype.howYouMove ?? person.archetype.overview)
            identitySection("CONNECTION", text: person.archetype.friendshipStyle)
            identitySection("UNDER PRESSURE", text: person.archetype.emotionalPattern)
        }.padding(ZD.Spacing.l) }
        .background(ZD.Color.bg.ignoresSafeArea()).navigationTitle("\(person.name)’s Identity").navigationBarTitleDisplayMode(.inline)
        .onAppear { AnalyticsService.shared.track(.savedPersonIdentityViewed(identityID: person.archetype.id)) }
    }
    private func identitySection(_ title: String, text: String) -> some View { VStack(alignment: .leading, spacing: 8) { Text(title).font(ZD.Font.caption(.semibold)).tracking(1.3).foregroundStyle(ZD.Color.accent); Text(text).font(ZD.Font.body()).foregroundStyle(ZD.Color.textSecondary).fixedSize(horizontal: false, vertical: true) }.padding(16).background(RoundedRectangle(cornerRadius: ZD.Radius.m, style: .continuous).fill(ZD.Color.card)) }
}

private struct SavedPersonTodayLensView: View {
    let person: SavedPerson
    @State private var reading: DailyReading?
    var body: some View {
        Group {
            if let reading { ScrollView { VStack(alignment: .leading, spacing: 18) {
                Text("DAILY LENS FOR \(person.name.uppercased())").font(ZD.Font.caption(.semibold)).tracking(1.5).foregroundStyle(ZD.Color.accent)
                Text(person.signLine).font(ZD.Font.body(.semibold)).foregroundStyle(ZD.Color.textPrimary)
                lensCard(title: reading.identity, text: reading.insight)
                lensCard(title: "Focus", text: reading.focus)
                lensCard(title: "Watch for", text: reading.caution)
            }.padding(ZD.Spacing.l) } } else { ProgressView("Preparing \(person.name)’s Lens…").tint(ZD.Color.accent) }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity).background(ZD.Color.bg.ignoresSafeArea())
        .navigationTitle("\(person.name)’s Lens").navigationBarTitleDisplayMode(.inline)
        .task { let archetype = person.archetype; reading = DailyReadingGenerator.generate(context: .init(archetype: archetype, user: nil, streak: nil)); AnalyticsService.shared.track(.savedPersonLensViewed(identityID: archetype.id)) }
    }
    private func lensCard(title: String, text: String) -> some View { VStack(alignment: .leading, spacing: 8) { Text(title).font(ZD.Font.heading()).foregroundStyle(ZD.Color.textPrimary); Text(text).font(ZD.Font.body()).foregroundStyle(ZD.Color.textSecondary).fixedSize(horizontal: false, vertical: true) }.padding(18).frame(maxWidth: .infinity, alignment: .leading).background(RoundedRectangle(cornerRadius: ZD.Radius.l, style: .continuous).fill(ZD.Color.card)) }
}

private struct SavedPersonAvatar: View {
    let person: SavedPerson; let size: CGFloat
    var body: some View { Group { if let fileName = person.photoFileName, let image = SavedPersonImageStore.load(fileName: fileName) { Image(uiImage: image).resizable().scaledToFill() } else { Text(String(person.name.prefix(1)).uppercased()).font(.system(size: size * 0.38, weight: .bold, design: .serif)).foregroundStyle(ZD.Color.accent).frame(maxWidth: .infinity, maxHeight: .infinity).background(ZD.Color.cardAlt) } }.frame(width: size, height: size).clipShape(Circle()).accessibilityLabel("Photo for \(person.name)") }
}

private enum SavedPersonImageStore {
    static func save(_ image: UIImage, replacing previous: String?) -> String? { guard let data = image.jpegData(compressionQuality: 0.84) else { return nil }; let name = "saved-person-\(UUID().uuidString).jpg"; let url = url(for: name); do { try data.write(to: url, options: .atomic); if let previous { delete(fileName: previous) }; return name } catch { return nil } }
    static func load(fileName: String) -> UIImage? { UIImage(contentsOfFile: url(for: fileName).path) }
    static func delete(fileName: String) { try? FileManager.default.removeItem(at: url(for: fileName)) }
    private static func url(for fileName: String) -> URL { let root = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("SavedPeople", isDirectory: true); try? FileManager.default.createDirectory(at: root, withIntermediateDirectories: true); return root.appendingPathComponent(fileName) }
}

private struct SharePayload: Identifiable {
    let id = UUID()
    let image: UIImage
}
