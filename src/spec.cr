require "./expectations"

module Minitest
  class Spec < Test
    macro let(name, &block)
      {% if name.is_a?(TypeDeclaration) %}
        {% if name.value && block %}
          {% raise "A let declaration MUST have a default value OR an initializer block but NOT both" %}
        {% end %}

        @{{name.var}} : {{name.type}} | Nil

        def {{name.var}} : {{name.type}}
          @{{name.var}} ||= {% if block %} {{yield}} {% else %} {{name.value}} {% end %}
        end
      {% else %}
        def {{name.id}}
          @{{name.id}} ||= {{yield}}
        end
      {% end %}
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
        def self.name
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

    def expect(value)
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
    def self.name
      {{ name.id.stringify }}
    end

    {{ yield }}
  end
end
