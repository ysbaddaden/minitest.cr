module Minitest
  class Runnable
    FOCUSES = Hash(String, Array(String)).new

    macro focus(definition)
      %focuses = FOCUSES[{{@type}}.name] ||= [] of String
      %focuses << {{definition.name.stringify}}
      {{definition}}
    end

    macro it(name = "anonymous", focus = false, &block)
      {% if focus %}focus{% end %} def test_{{ name.strip.gsub(/[^0-9a-zA-Z:]+/, "_").id }}
        ret = {{ yield }}
      end
    end
  end

  class Test < Runnable
    def should_run?(name)
      focused_test?(name) && super(name)
    end

    def focused_test?(name)
      if FOCUSES.empty?
        true
      else
        {% begin %}
          if focuses = FOCUSES[{{@type}}.name]?
            focuses.includes?(name)
          else
            false
          end
        {% end %}
      end
    end
  end
end
