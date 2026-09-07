import XCTest

@testable import WhisperDictation

/// `EngineLoadProgress` — единственное место, где фаза подготовки движка
/// превращается в то, что видит пользователь. Тесты держат именно это: подписи
/// и нормализацию доли. Саму загрузку моделей FluidAudio тут не трогаем — она
/// требует сети и ~470МБ, и проверяется запуском приложения.
final class EngineLoadProgressTests: XCTestCase {

    // MARK: - Подписи

    func testDownloadingLabelShowsFileCount() {
        let p = EngineLoadProgress(phase: .downloading(completed: 3, total: 5), fraction: 0.62)
        XCTAssertEqual(p.label, "Downloading model… 3 of 5 files")
    }

    /// FluidAudio присылает `.downloading` ещё до того, как узнает список файлов.
    /// «0 of 0 files» выглядело бы как ошибка, поэтому счётчик прячем.
    func testDownloadingLabelOmitsCountWhenTotalUnknown() {
        let p = EngineLoadProgress(phase: .downloading(completed: 0, total: 0), fraction: 0)
        XCTAssertEqual(p.label, "Downloading model…")
    }

    func testListingLabel() {
        XCTAssertEqual(EngineLoadProgress(phase: .listing, fraction: nil).label, "Preparing download…")
    }

    /// Компиляция CoreML — это те самые ~30 секунд ПОСЛЕ скачивания, из-за
    /// которых раньше казалось, что приложение зависло.
    func testCompilingLabel() {
        let p = EngineLoadProgress(phase: .compiling(model: "parakeet-encoder", completed: 2, total: 4), fraction: 0.9)
        XCTAssertEqual(p.label, "Optimizing for this Mac… 2 of 4")
    }

    /// Пакет мог поменять состав моделей — тогда знаменателя нет, но подпись
    /// всё равно обязана быть осмысленной.
    func testCompilingLabelWithoutTotal() {
        let p = EngineLoadProgress(phase: .compiling(model: "x", completed: 0, total: 0), fraction: nil)
        XCTAssertEqual(p.label, "Optimizing for this Mac…")
    }

    func testConfiguringVocabularyLabel() {
        let p = EngineLoadProgress(phase: .configuringVocabulary, fraction: nil)
        XCTAssertEqual(p.label, "Configuring vocabulary…")
    }

    // MARK: - Нормализация доли

    /// Доля приходит из чужой библиотеки, а уезжает прямо в `ProgressView`,
    /// который на значении вне 0…1 рисует мусор.
    func testFractionIsClamped() {
        XCTAssertEqual(EngineLoadProgress(phase: .listing, fraction: 1.5).fraction, 1.0)
        XCTAssertEqual(EngineLoadProgress(phase: .listing, fraction: -0.2).fraction, 0.0)
        XCTAssertEqual(EngineLoadProgress(phase: .listing, fraction: 0.42).fraction, 0.42)
    }

    func testNonFiniteFractionBecomesIndeterminate() {
        XCTAssertNil(EngineLoadProgress(phase: .listing, fraction: .nan).fraction)
        XCTAssertNil(EngineLoadProgress(phase: .listing, fraction: .infinity).fraction)
    }

    /// У догрузки словаря (CtcModels) прогресс-хендлера в FluidAudio нет вообще,
    /// поэтому фаза принципиально неопределённая — врать процентами не надо.
    func testConfiguringVocabularyIsAlwaysIndeterminate() {
        let p = EngineLoadProgress(phase: .configuringVocabulary, fraction: 0.99)
        XCTAssertNil(p.fraction)
        XCTAssertFalse(p.isDeterminate)
    }

    func testIsDeterminateReflectsFraction() {
        XCTAssertTrue(EngineLoadProgress(phase: .listing, fraction: 0.5).isDeterminate)
        XCTAssertFalse(EngineLoadProgress(phase: .listing, fraction: nil).isDeterminate)
    }
}
