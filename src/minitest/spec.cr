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

    macro it(name = "anonymous", &block)
      def test_{{ name.gsub(/[^0-9a-zA-Z]+/, "_").id }}
        {{ block.body.id }}
      end
    end
  end
end
