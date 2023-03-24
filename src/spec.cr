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
          .split("::")
          .map(&.gsub(/[^0-9a-zA-Z]+/, "_").gsub(/^_|_$/, "").capitalize)
          .join("::")
      %}
      class {{ class_name.id }}Spec < {{ @type }}
        def self.name : String
          "#{ {{ @type }}.name }::{{ name.id }}"
        end

        {{ yield }}
      end
    end

    macro it(name = "anonymous", &block)
      def test_{{ name.strip.gsub(/[^0-9a-zA-Z]+/, "_").id }}
        {{ yield }}
      end
    end

    def expect(value) : Expectation
      Expectation.new(value)
    end
  end
end

# TODO: allow to inherit from specific classes (configurable with matcher)
macro describe(name, &block)
  {%
    class_name = name.id.stringify
      .split("::")
      .map(&.gsub(/[^0-9a-zA-Z]+/, "_").gsub(/^_|_$/, "").capitalize)
      .join("::")
  %}
  class {{ class_name.id }}Spec < Minitest::Spec
    def self.name : String
      {{ name.id.stringify }}
    end

    {{ yield }}
  end
end
