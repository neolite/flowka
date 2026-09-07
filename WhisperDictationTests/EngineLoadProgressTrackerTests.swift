import XCTest

@testable import WhisperDictation

/// Поток событий здесь взят не из головы: он снят с реального запуска Parakeet
/// на прогретом кэше (`downloading(0,0) → compiling("Preprocessor") →
/// compiling("") → …` и так на каждую из моделей). Именно из-за него нужен
/// трекер: сырая доля откатывается назад на каждой модели.
final class EngineLoadProgressTrackerTests: XCTestCase {

    private func tracker(totalModels: Int = 4) -> EngineLoadProgressTracker {
        EngineLoadProgressTracker(totalModels: totalModels)
    }

    // MARK: - Монотонность

    func testFractionNeverGoesBackwards() {
        let t = tracker()
        var seen: [Double] = []
        for name in ["Preprocessor", "", "Encoder", "", "Decoder", "", "Joint", ""] {
            let p = t.update(phase: .compiling(model: name), rawFraction: name.isEmpty ? 1.0 : 0.5)
            if let f = p.fraction { seen.append(f) }
        }
        XCTAssertEqual(seen, seen.sorted(), "доля обязана только расти: \(seen)")
    }

    /// Компиляция идёт ПОСЛЕ скачивания, но её сырая доля начинается заново с
    /// нуля. Без разнесения по стадиям полоса прыгала бы назад на переходе.
    func testCompilingStaysAboveCompletedDownload() {
        let t = tracker()
        let downloaded = t.update(phase: .downloading(completed: 5, total: 5), rawFraction: 1.0)
        let compiling = t.update(phase: .compiling(model: "Preprocessor"), rawFraction: 0.0)
        XCTAssertNotNil(downloaded.fraction)
        XCTAssertGreaterThanOrEqual(compiling.fraction ?? 0, downloaded.fraction ?? 0)
    }

    // MARK: - Кэш-хит

    /// На прогретом кэше FluidAudio всё равно шлёт `.downloading`, но с нулевым
    /// счётчиком файлов. Писать «Downloading model…» там — врать пользователю.
    func testEmptyDownloadIsReportedAsPreparing() {
        let p = tracker().update(phase: .downloading(completed: 0, total: 0), rawFraction: 0.5)
        XCTAssertEqual(p.label, "Preparing download…")
        XCTAssertFalse(p.isDeterminate)
    }

    func testRealDownloadKeepsFileCount() {
        let p = tracker().update(phase: .downloading(completed: 3, total: 5), rawFraction: 0.6)
        XCTAssertEqual(p.label, "Downloading model… 3 of 5 files")
        XCTAssertTrue(p.isDeterminate)
    }

    // MARK: - Счёт моделей

    /// Пустое имя — сигнал «эта модель дошла», а не пятая модель.
    func testBlankModelNameDoesNotCountAsNewModel() {
        let t = tracker(totalModels: 4)
        _ = t.update(phase: .compiling(model: "Preprocessor"), rawFraction: 0.5)
        let after = t.update(phase: .compiling(model: ""), rawFraction: 1.0)
        XCTAssertEqual(after.label, "Optimizing for this Mac… 1 of 4")
    }

    func testRepeatedModelNameCountsOnce() {
        let t = tracker(totalModels: 4)
        _ = t.update(phase: .compiling(model: "Encoder"), rawFraction: 0.5)
        let again = t.update(phase: .compiling(model: "Encoder"), rawFraction: 0.9)
        XCTAssertEqual(again.label, "Optimizing for this Mac… 1 of 4")
    }

    func testCompilingCountAdvancesPerDistinctModel() {
        let t = tracker(totalModels: 4)
        _ = t.update(phase: .compiling(model: "Preprocessor"), rawFraction: 0.5)
        _ = t.update(phase: .compiling(model: "Encoder"), rawFraction: 0.5)
        let third = t.update(phase: .compiling(model: "Decoder"), rawFraction: 0.5)
        XCTAssertEqual(third.label, "Optimizing for this Mac… 3 of 4")
    }

    /// Список моделей мог поменяться в новой версии пакета — деление на ноль
    /// или доля >1 не должны утекать в `ProgressView`.
    func testMoreModelsThanExpectedStaysWithinBounds() {
        let t = tracker(totalModels: 1)
        _ = t.update(phase: .compiling(model: "A"), rawFraction: 0.5)
        let second = t.update(phase: .compiling(model: "B"), rawFraction: 0.5)
        XCTAssertLessThanOrEqual(second.fraction ?? 0, 1.0)
    }

    func testZeroTotalModelsIsIndeterminate() {
        let p = tracker(totalModels: 0).update(phase: .compiling(model: "A"), rawFraction: 0.5)
        XCTAssertNil(p.fraction)
    }

    // MARK: - Реальная запись

    /// Дословный поток с прогретого кэша (12 колбэков, снятых с запуска сборки
    /// Release). Сырые доли там пилят 0.5 → 1.0 → 0.5 на каждую модель; тест
    /// держит то, что наружу это уходит монотонно и заканчивается крутилкой
    /// словаря, а не откатом.
    func testReplayOfRecordedCacheHitStream() {
        let t = tracker(totalModels: 4)
        let recorded: [(EngineLoadProgressTracker.RawPhase, Double)] = [
            (.downloading(completed: 0, total: 0), 0.5),
            (.compiling(model: "Preprocessor.mlmodelc"), 0.5),
            (.compiling(model: ""), 1.0),
            (.downloading(completed: 0, total: 0), 0.5),
            (.compiling(model: "Encoder.mlmodelc"), 0.5),
            (.compiling(model: ""), 1.0),
            (.downloading(completed: 0, total: 0), 0.5),
            (.compiling(model: "Decoder.mlmodelc"), 0.5),
            (.compiling(model: ""), 1.0),
            (.downloading(completed: 0, total: 0), 0.5),
            (.compiling(model: "JointDecisionv3.mlmodelc"), 0.5),
            (.compiling(model: ""), 1.0),
        ]

        var fractions: [Double] = []
        var labels: [String] = []
        for (phase, raw) in recorded {
            let p = t.update(phase: phase, rawFraction: raw)
            if let f = p.fraction { fractions.append(f) }
            labels.append(p.label)
        }

        XCTAssertEqual(fractions, fractions.sorted(), "полоса откатилась назад: \(fractions)")
        XCTAssertEqual(fractions.last, 1.0, "все четыре модели скомпилированы — полоса обязана дойти до конца")
        // Ничего не качалось: слова про загрузку в подписях появиться не должны.
        XCTAssertFalse(labels.contains { $0.hasPrefix("Downloading") }, "\(labels)")
        XCTAssertEqual(labels.last, "Optimizing for this Mac… 4 of 4")
    }

    // MARK: - Словарь

    func testVocabularyPhaseIsIndeterminate() {
        let t = tracker()
        _ = t.update(phase: .compiling(model: "Joint"), rawFraction: 1.0)
        let p = t.update(phase: .configuringVocabulary, rawFraction: nil)
        XCTAssertEqual(p.label, "Configuring vocabulary…")
        XCTAssertNil(p.fraction)
    }
}
