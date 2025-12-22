module Minitest
  class Runnable
    FOCUSES = Hash(String, Array(String)).new

    macro focus(definition)
      %focuses = FOCUSES[{{@type}}.name] ||= [] of String
      %focuses << {{definition.name.stringify}}
      {{definition}}
    end

    macro it(name = "anonymous", focus = false, &block)
      {% if focus %}focus{% end %} def test_{{ name.strip.gsub(/[^\p{L}\p{N}]+/, "_").id }}
        ret = {{ yield }}
      end
    end
  end

  class Test < Runnable
    def should_run?(name) : Bool
      focused_test?(name) && super(name)
    end

    def focused_test?(name) : Bool
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
