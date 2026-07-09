import Foundation

/// Detects the "send it" command word: a dictation that ends with the phrase has it
/// stripped from the delivered text, and delivery fires a one-shot Return afterwards.
/// A bare "send it" utterance types nothing and just presses Return, submitting
/// whatever is already in the target app's input.
enum SendItCommandDetector {
    struct Detection: Equatable {
        let text: String
        let triggered: Bool
    }

    private static let phrase = "send it"
    /// Punctuation the ASR may append after the spoken phrase ("Send it." / "Send it…").
    private static let trailingPunctuation = Set(",.!?;:…")
    /// Separators that only introduced the phrase ("fix the bug, send it") and should
    /// not survive in the delivered text. Sentence punctuation (. ? !) is kept.
    private static let danglingSeparators = Set(",;:-—–")

    static func detect(in text: String) -> Detection {
        var candidate = text
        var triggered = false

        // Strip repeatedly so "send it, send it" collapses to a bare submit.
        while true {
            var working = candidate
            while let last = working.last, last.isWhitespace || trailingPunctuation.contains(last) {
                working.removeLast()
            }

            guard let range = working.range(of: phrase, options: [.backwards, .anchored, .caseInsensitive]) else {
                break
            }

            if range.lowerBound > working.startIndex {
                let preceding = working[working.index(before: range.lowerBound)]
                // Only a whitespace-separated phrase counts: rejects in-word and
                // hyphen-attached matches like "resend it" / "re-send it".
                if !preceding.isWhitespace {
                    break
                }
            }

            var remainder = String(working[..<range.lowerBound])
            while let last = remainder.last, last.isWhitespace {
                remainder.removeLast()
            }
            if let last = remainder.last, danglingSeparators.contains(last) {
                remainder.removeLast()
                while let last = remainder.last, last.isWhitespace {
                    remainder.removeLast()
                }
            }

            triggered = true
            candidate = remainder
        }

        return triggered ? Detection(text: candidate, triggered: true) : Detection(text: text, triggered: false)
    }
}
