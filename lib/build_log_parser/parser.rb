require "build_log_parser/duration_matcher"

module BuildLogParser
  class Parser
    include DurationMatcher

    attr_reader :body

    def initialize(body)
      @body = body
    end

    def duration
      fetch_duration(body)
    end

    def tests
      rspec_stats || test_unit_stats
    end

    def coverage
      if body =~ /\s([\d]+) \/ ([\d]+) LOC \(([\d]+\.[\d]+)%\) covered\./
        {
          lines:            $1.to_i,
          lines_total:      $2.to_i,
          coverage_percent: $3.to_f
        }
      else
        nil
      end
    end

    private

    def rspec_stats
      matches = body.scan(/^([\d]+) examples, ([\d]+) failures(, ([\d]+) pending)?/m)
      return if matches.empty?

      result = { count: 0, failures: 0, pending: 0 }

      matches.each do |m|
        result[:count]    += m[0].to_i if m[0] # examples
        result[:failures] += m[1].to_i if m[1] # failures
        result[:pending]  += m[3].to_i if m[3] # pending
      end

      result
    end

    def test_unit_stats
      if body =~ /^([\d]+) tests, ([\d]+) assertions, ([\d]+) failures, ([\d]+) errors$/m
        {
          count:    $1.to_i,
          failures: $3.to_i,
          pending:  nil
        }
      end
    end
  end
end