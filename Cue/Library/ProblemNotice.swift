import DesignSystem
import SwiftUI

/// Tells the user, in plain words, that their library could not be saved or read.
struct ProblemNotice: View {
    enum Problem {
        /// The saved library could not be opened; this session works in memory only.
        case notSavedOnDevice
        case lastChangeNotSaved
        case someTitlesMissing
    }

    let problem: Problem

    var body: some View {
        HStack(alignment: .top, spacing: CueSpacing.space3) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(CueColor.danger)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: CueSpacing.space1) {
                Text(title)
                    .cueTextStyle(.label)
                    .foregroundStyle(CueColor.ink)
                Text(detail)
                    .cueTextStyle(.callout)
                    .foregroundStyle(CueColor.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(CueSpacing.space4)
        .background(RoundedRectangle(cornerRadius: CueRadius.medium, style: .continuous).fill(CueColor.surface))
        .overlay(
            RoundedRectangle(cornerRadius: CueRadius.medium, style: .continuous)
                .strokeBorder(CueColor.danger, lineWidth: 1.5)
        )
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("library.problem")
    }

    private var title: String {
        switch problem {
        case .notSavedOnDevice: "Ahora mismo no se guarda nada"
        case .lastChangeNotSaved: "El último cambio no se ha guardado"
        case .someTitlesMissing: "Faltan algunos títulos"
        }
    }

    private var detail: String {
        switch problem {
        case .notSavedOnDevice:
            "No se ha podido abrir tu biblioteca guardada. Lo que hagas ahora se perderá al cerrar Cue. Cierra la app y vuelve a abrirla."
        case .lastChangeNotSaved:
            "Vuelve a intentarlo. Si sigue pasando, cierra la app y ábrela de nuevo."
        case .someTitlesMissing:
            "No se han podido leer todos tus títulos. Cierra la app y ábrela de nuevo."
        }
    }
}
