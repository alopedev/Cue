import CueKit
import DesignSystem
import SwiftUI

/// The row of shelf chips above the grid. Scrolls sideways when the shelves do not fit.
struct ShelfBar: View {
    let shelves: [LibraryShelf]
    @Binding var selected: LibraryShelf
    let count: (LibraryShelf) -> Int

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: CueSpacing.space2) {
                ForEach(shelves, id: \.self) { shelf in
                    CueChip(LibraryText.shelfName(shelf), count: count(shelf), isSelected: shelf == selected) {
                        selected = shelf
                    }
                    .accessibilityIdentifier("shelf.\(shelf)")
                }
            }
            .padding(.vertical, CueSpacing.space1)
            .padding(.horizontal, CueSpacing.space4)
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal, -CueSpacing.space4)
    }
}

/// What a shelf with no titles says. Never blames the user.
struct ShelfEmptyMessage: View {
    let shelf: LibraryShelf

    var body: some View {
        VStack(spacing: CueSpacing.space2) {
            Text(title)
                .cueTextStyle(.label)
                .foregroundStyle(CueColor.ink)
            Text(detail)
                .cueTextStyle(.body)
                .foregroundStyle(CueColor.inkMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, CueSpacing.space12)
    }

    private var title: String {
        switch shelf {
        case .watching: "Ahora mismo no estás viendo nada"
        default: "Aquí no hay nada"
        }
    }

    private var detail: String {
        switch shelf {
        case .watching: "Marca el primer episodio de una serie pendiente y aparecerá aquí."
        default: "Cuando un título pase a este estado, lo verás aquí."
        }
    }
}
