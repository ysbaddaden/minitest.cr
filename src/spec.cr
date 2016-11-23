require "./expectations"

module Minitest
  class Spec < Test
    macro let(name, &block)
      def {{ name.id }}
        @{{ name.id }} ||= begin; {{ yield }}; end
      end
    end

    macro before(&block)
      def setup
        super()
        {{ yield }}
      end
    end

    macro after(&block)
      def teardown
        {{ yield }}
        super()
      end
    end

    macro describe(name, &block)
      {%
        class_name = name.id.stringify
          .gsub(/[^0-9a-zA-Z:]+/, "_")
          .gsub(/^_|_$/, "")
          .split("_").map { |s| [s[0...1].upcase, s[1..-1]].join("") }.join("")
          .split("::").map { |s| [s[0...1].upcase, s[1..-1]].join("") }.join("::")
      %}
      class {{ class_name.id }}Spec < {{ @type }}
        def self.name
          "#{ {{ @type }}.name }::{{ name.id }}"
        end

        {{ yield }}
      end
    end

    macro it(name = "anonymous", &block)
      def test_{{ name.strip.gsub(/[^0-9a-zA-Z:]+/, "_").id }}
        {{ yield }}
      end
    end

    def expect(value)
      Expectation.new(value)
    end
  end
end

# TODO: allow to inherit from specific classes (configurable with matcher)
macro describe(name, &block)
  {%
    class_name = name.id.stringify
      .gsub(/[^0-9a-zA-Z:]+/, "_")
      .gsub(/^_|_$/, "")
      .split("_").map { |s| [s[0...1].upcase, s[1..-1]].join("") }.join("")
      .split("::").map { |s| [s[0...1].upcase, s[1..-1]].join("") }.join("::")
  %}
  class {{ class_name.id }}Spec < Minitest::Spec
    def self.name
      {{ name.id.stringify }}
    end

    {{ yield }}
  end
end
