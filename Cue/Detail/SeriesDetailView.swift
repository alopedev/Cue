import CueKit
import DesignSystem
import SwiftUI

/// A series' sheet: what comes next, what is left (RF-35) and every episode by season.
struct SeriesDetailView: View {
    let series: SeriesEntry
    let library: LibraryModel

    var body: some View {
        List {
            Section {
                DetailHeader(
                    title: details.series.title,
                    facts: facts,
                    status: status,
                    note: LibraryText.airingStatus(details.series.airingStatus)
                )
            }
            Section { nextUp }
            if !series.progress.remainingEpisodes.isEmpty {
                Section {
                    statsLayout {
                        DetailStat(
                            label: "Episodios por ver",
                            value: "\(series.progress.remainingEpisodes.count)"
                        )
                        DetailStat(
                            label: "Tiempo estimado",
                            value: DurationText.string(minutes: series.progress.remainingMinutes)
                        )
                    }
                    .padding(.vertical, CueSpacing.space1)
                    .listRowBackground(CueColor.surface)
                }
            }
            ForEach(details.seasons, id: \.number) { season in
                Section {
                    ForEach(episodes(of: season.number)) { episode in
                        EpisodeRow(
                            episode: episode,
                            isWatched: series.watchedEpisodes.contains(episode.id),
                            hasAired: series.progress.hasAired(episode.id),
                            toggle: { Task { await library.toggle(episode.id) } },
                            markThrough: { Task { await library.markThrough(episode.id) } }
                        )
                        .listRowBackground(CueColor.surface)
                    }
                } header: {
                    SeasonHeader(
                        number: season.number,
                        watched: watchedCount(in: season.number),
                        total: season.episodeCount
                    )
                }
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(CueSpacing.space4)
    }

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    /// Side by side; one above the other with the largest text sizes, so numbers are not cut.
    private var statsLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: CueSpacing.space3))
            : AnyLayout(HStackLayout(spacing: CueSpacing.space4))
    }

    private var details: SeriesDetails { series.details }

    private var facts: [String] {
        [
            details.series.year.map(String.init), LibraryText.seasons(details.series.seasonCount),
        ].compactMap { $0 }
    }

    private var status: String { LibraryText.seriesStatus(series.tracking.status) }

    @ViewBuilder
    private var nextUp: some View {
        if let next = series.progress.currentEpisode {
            NextEpisodeCard(episode: next) {
                Task { await library.markNextEpisode(of: series.id) }
            }
            .listRowBackground(CueColor.surface)
        } else {
            CaughtUpCard(series: series)
                .listRowBackground(CueColor.surface)
        }
    }

    private func episodes(of season: Int) -> [Episode] {
        series.progress.episodes.filter { $0.id.seasonNumber == season }
    }

    private func watchedCount(in season: Int) -> Int {
        episodes(of: season).filter { series.watchedEpisodes.contains($0.id) }.count
    }

}

/// The next episode to watch and the one-tap button to mark it (RF-30).
private struct NextEpisodeCard: View {
    let episode: Episode
    let mark: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: CueSpacing.space3) {
            VStack(alignment: .leading, spacing: CueSpacing.space1) {
                Text("Siguiente")
                    .cueTextStyle(.caption)
                    .foregroundStyle(CueColor.inkMuted)
                Text(episode.title)
                    .cueTextStyle(.label)
                    .foregroundStyle(CueColor.ink)
                Text(meta)
                    .cueTextStyle(.minutes)
                    .foregroundStyle(CueColor.inkMuted)
            }
            .accessibilityElement(children: .combine)
            Button("Marcar visto", action: mark)
                .buttonStyle(.cuePrimary)
                .accessibilityIdentifier("detail.markNext")
        }
        .padding(.vertical, CueSpacing.space2)
    }

    private var meta: String {
        let code = LibraryText.episodeCode(episode.id)
        return episode.runtimeMinutes.map { "\(code) · \(DurationText.string(minutes: $0))" } ?? code
    }
}

/// Shown when there is nothing to watch right now: up to date, finished or not aired yet.
private struct CaughtUpCard: View {
    let series: SeriesEntry

    var body: some View {
        HStack(spacing: CueSpacing.space4) {
            MascotStage(Image("mascot-up-to-date"), size: .small)
            VStack(alignment: .leading, spacing: CueSpacing.space1) {
                Text(title)
                    .cueTextStyle(.label)
                    .foregroundStyle(CueColor.ink)
                Text(detail)
                    .cueTextStyle(.callout)
                    .foregroundStyle(CueColor.inkMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, CueSpacing.space2)
        .accessibilityElement(children: .combine)
    }

    private var nextAirDate: Date? {
        series.progress.episodes.first { !series.progress.hasAired($0.id) }?.airDate
    }

    private var title: String {
        series.tracking.status == .finished ? "La has terminado" : "Estás al día"
    }

    private var detail: String {
        if series.tracking.status == .finished { return "Has visto todos los episodios." }
        if let nextAirDate { return "El próximo episodio sale el \(LibraryText.shortDate(nextAirDate))." }
        return "Has visto todo lo emitido."
    }
}

private struct SeasonHeader: View {
    let number: Int
    let watched: Int
    let total: Int

    var body: some View {
        HStack {
            Text("Temporada \(number)")
            Spacer()
            Text("\(watched) de \(total)")
                .monospacedDigit()
        }
        .font(.footnote.weight(.semibold))
        .foregroundStyle(CueColor.inkMuted)
        .accessibilityElement(children: .combine)
    }
}
