require "./expectations"

module Minitest
  class Spec < Test
    def after_teardown
      super()

      if memoized = @_memoized
        memoized.clear
      end
    end

    # NOTE: we can't use Reference as a generic (yet) so we can't just rely on a
    #       Hash to memoize the let values and clear it on each teardown. We
    #       thus keep a list of generated keys to force the regeneration of a
    #       variable on each test.
    macro let(name, &block)
      def {{ name.id }}
        #@_memoized ||= {} of String => Reference
        #@_memoized[{{ name.id.stringify }}] ||= begin; {{ yield }}; end

        %memoized = @_memoized ||= [] of String

        unless %memoized.includes?({{ name.id.stringify }})
          %memoized << {{ name.id.stringify }}
          @{{ name.id }} = nil
        end

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
          .id
      %}
      class {{ class_name }}Spec < {{ @type.name.id }}
        def self.name
          "#{ {{ @type.name.id }}.name }::{{ name.id }}"
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
      .id
  %}
  class {{ class_name }}Spec < Minitest::Spec
    def self.name
      {{ name.id.stringify }}
    end

    {{ yield }}
  end
end
