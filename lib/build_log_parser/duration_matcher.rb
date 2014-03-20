module BuildLogParser
  module DurationMatcher
    DURATION_PATTERNS = [
      /^finished in (.*)/i,
      /^finished tests in ([\d]\.[\d]+s),/i,
      /ran [\d]+ tests in (.*)\n?/i,
      /time: (.*), memory:/i,
      /[\d]+ passing (.*)/
    ]

    def fetch_duration(str)
      DURATION_PATTERNS.map { |p| scan_duration(str, p) }.compact.reduce(:+)
    end

    private

    def scan_duration(str, pattern)
      str.
        gsub(/(seconds|minutes|hours)\s\((.*)\)/, "").
        gsub(/(([\d]+)ms)/) { |m| "0.#{$2}s" }.
        scan(pattern).
        flatten.
        map { |m| ChronicDuration.parse(m) }.
        reduce(:+)
    end
  end
end