import Testing
@testable import VoiceInk

struct SendItCommandDetectorTests {
    @Test func stripsTrailingPhraseAfterComma() {
        let detection = SendItCommandDetector.detect(in: "Fix the login bug, send it.")
        #expect(detection == .init(text: "Fix the login bug", triggered: true))
    }

    @Test func stripsTrailingPhraseWithoutSeparator() {
        let detection = SendItCommandDetector.detect(in: "fix the bug send it")
        #expect(detection == .init(text: "fix the bug", triggered: true))
    }

    @Test func barePhraseTriggersWithEmptyText() {
        #expect(SendItCommandDetector.detect(in: "Send it") == .init(text: "", triggered: true))
        #expect(SendItCommandDetector.detect(in: "send it.") == .init(text: "", triggered: true))
        #expect(SendItCommandDetector.detect(in: "SEND IT!") == .init(text: "", triggered: true))
    }

    @Test func keepsInteriorSentencePunctuation() {
        let detection = SendItCommandDetector.detect(in: "does that look right? send it")
        #expect(detection == .init(text: "does that look right?", triggered: true))
    }

    @Test func survivesParagraphFormatterNewlines() {
        let detection = SendItCommandDetector.detect(in: "Fix the bug.\n\nSend it.")
        #expect(detection == .init(text: "Fix the bug.", triggered: true))
    }

    @Test func stripsDanglingDashSeparator() {
        let detection = SendItCommandDetector.detect(in: "fix the bug — send it")
        #expect(detection == .init(text: "fix the bug", triggered: true))
    }

    @Test func rejectsInWordMatches() {
        #expect(SendItCommandDetector.detect(in: "resend it") == .init(text: "resend it", triggered: false))
        #expect(SendItCommandDetector.detect(in: "suspend it.") == .init(text: "suspend it.", triggered: false))
    }

    @Test func rejectsHyphenAttachedMatches() {
        #expect(SendItCommandDetector.detect(in: "please re-send it") == .init(text: "please re-send it", triggered: false))
        #expect(SendItCommandDetector.detect(in: "fix the retry logic and re-send it") == .init(text: "fix the retry logic and re-send it", triggered: false))
    }

    @Test func collapsesRepeatedPhrase() {
        #expect(SendItCommandDetector.detect(in: "send it, send it") == .init(text: "", triggered: true))
        #expect(SendItCommandDetector.detect(in: "fix the bug send it send it") == .init(text: "fix the bug", triggered: true))
    }

    @Test func toleratesUnicodeEllipsis() {
        #expect(SendItCommandDetector.detect(in: "Send it…") == .init(text: "", triggered: true))
    }

    @Test func rejectsPhraseNotAtEnd() {
        let text = "please send it to the team"
        #expect(SendItCommandDetector.detect(in: text) == .init(text: text, triggered: false))
    }

    @Test func rejectsNonMatches() {
        #expect(SendItCommandDetector.detect(in: "") == .init(text: "", triggered: false))
        #expect(SendItCommandDetector.detect(in: "send") == .init(text: "send", triggered: false))
        #expect(SendItCommandDetector.detect(in: "it") == .init(text: "it", triggered: false))
    }
}
