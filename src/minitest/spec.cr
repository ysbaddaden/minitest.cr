module Minitest
  class Spec < Test
    macro before(&block)
      def setup
        super()
        {{ block.body.id }}
      end
    end

    macro after(&block)
      def teardown
        {{ block.body.id }}
        super()
      end
    end

    macro describe(name, &block)
      class {{
              name.strip
                .gsub(/[^0-9a-zA-Z]+/, "_")
                .split("_")
                .map { |s| s.capitalize }
                .join("")
                .id
            }} < {{ @class_name.id }}
        {{ block.body.id }}
      end
    end

    macro it(name = "anonymous", &block)
      def test_{{ name.strip.gsub(/[^0-9a-zA-Z]+/, "_").id }}
        {{ block.body.id }}
      end
    end
  end
end

macro describe(name, &block)
  class {{
          name.stringify
            .strip
            .gsub(/[^0-9a-zA-Z]+/, "_")
            .split("_")
            .map { |s| s.capitalize }
            .join("")
            .id
        }}Spec < Minitest::Spec
    {{ block.body.id }}
  end
end

