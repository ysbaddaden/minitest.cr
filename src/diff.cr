# Original diff algorithm written by TSUYUSATO Kitsune (MakeNowJust),
# distributed under the MIT license.
#
# See <https://github.com/makenowjust/crystal-diff/blob/master/src/diff.cr>
struct Minitest::Diff(T)
  enum Type
    DELETED
    APPENDED
    UNCHANGED

    def reverse : self
      case self
      in DELETED   then APPENDED
      in APPENDED  then DELETED
      in UNCHANGED then UNCHANGED
      end
    end
  end

  record Delta,
    type : Type,
    a : Range(Int32, Int32),
    b : Range(Int32, Int32) do
    def append(other : self) : self
      copy_with(
        a: a.begin...other.a.end,
        b: b.begin...other.b.end,
      )
    end

    def reverse : self
      Delta.new(@type.reverse, b, a)
    end
  end

  def self.line_diff(a : String, b : String)
    new(a.split('\n'), b.split('\n'))
  end

  getter a : T
  getter b : T
  @m : Int32
  @n : Int32

  def initialize(a : T, b : T)
    if swap = (b.size < a.size)
      @a, @m = b, b.size
      @b, @n = a, a.size
    else
      @a, @m = a, a.size
      @b, @n = b, b.size
    end

    @delta = @n - @m

    @path = Array(Int32).new(@m + 1 + @n + 1, -1)
    @points = [] of {Int32, Int32, Int32}
    @patch = [] of {Int32, Int32}
    @deltas = [] of Delta

    p = calculate_edit_distance
    generate_patch(p)
    generate_deltas

    if swap
      @a, @b = @b, @a
      @deltas = @deltas.map(&.reverse)
    end

    # the algorithm places appends before deletes, but diffs usually show the
    # opposite: the deleted (original) then the appended (that replaces the
    # original)
    swap_appends_and_deletes
  end

  def each(& : Delta ->) : Nil
    @deltas.each { |delta| yield delta }
  end

  private def swap_appends_and_deletes
    previous = nil

    @deltas.each_with_index do |current, i|
      if previous.try(&.appended?) && current.type.deleted?
        @deltas.swap(i - 1, i)
      end
      previous = current.type
    end
  end

  private def generate_deltas
    x = y = x0 = y0 = 0

    @patch.reverse_each do |(px, py)|
      while x < px && py - px < y - x
        x += 1
      end
      add_delta(:deleted, x0...x, y0...y) unless x0 == x
      x0 = x

      while y < py && py - px > y - x
        y += 1
      end
      add_delta(:appended, x0...x, y0...y) unless y0 == y
      y0 = y

      while x < px && y < py && py - px == y - x
        x += 1
        y += 1
      end
      add_delta(:unchanged, x0...x, y0...y) unless x0 == x
      x0, y0 = x, y
    end
  end

  private def add_delta(type : Type, a, b)
    delta = Delta.new(type, a, b)

    if (last = @deltas.last?) && delta.type == last.type
      @deltas[-1] = last.append(delta)
    else
      @deltas << delta
    end
  end

  private def calculate_edit_distance : Int32
    fp = Array(Int32).new(@m + 1 + @n + 1) { -1 }
    p = -1

    loop do
      p += 1

      (-p).upto(@delta - 1) do |k|
        fp[k] = snake(k, fp[k - 1] + 1, fp[k + 1])
      end

      (@delta + p).downto(@delta + 1) do |k|
        fp[k] = snake(k, fp[k - 1] + 1, fp[k + 1])
      end

      fp[@delta] = snake(@delta, fp[@delta - 1] + 1, fp[@delta + 1])

      break if fp[@delta] == @n
    end

    # edit distance is `@delta + 2 * p`
    p
  end

  private def snake(k : Int32, y0 : Int32, y1 : Int32) : Int32
    r = y0 > y1 ? @path[k - 1] : @path[k + 1]
    y = {y0, y1}.max
    x = y - k

    while (x < @m) && (y < @n) && (@a[x] == @b[y])
      x += 1
      y += 1
    end

    @path[k] = @points.size
    @points << {x, y, r}

    y
  end

  private def generate_patch(p : Int32)
    r = @path[@delta]
    until r == -1
      x, y, r = @points[r]
      @patch << {x, y}
    end
  end
end
