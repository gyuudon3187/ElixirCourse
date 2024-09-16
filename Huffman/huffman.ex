defmodule Huffman do
  defmodule Node do
    defstruct [:left, :right]
  end

  defmodule Leaf do
    defstruct [:char]
  end

  def sample do
    'the quick brown fox jumps over the lazy dog
    this is a sample text that we will use when we build
    up a table we will only handle lower case letters and
    no punctuation symbols the frequency will of course not
    represent english but it is probably not that far off'
  end

  def text() do
    'this is something that we should encode'
  end

  def test(str) do
    huffman(freq(str))
  end

  def freq(sample \\ sample())
  def freq(sample) do
    sample
    |> charlist()
    |> Enum.reduce(%{}, fn char, map -> Map.update(map, char, 1, fn val -> val + 1 end) end)
    |> Enum.sort_by(fn {_, freq} -> freq end)
    |> Enum.map(fn {key, freq} -> { %Leaf{char: key}, freq } end)
  end

  def huffman(listWithFreq \\ freq())
  def huffman([{tree, _}]) do tree end
  def huffman([{na, naf}, {nb, nbf} | lst]) do
    [ { %Node{left: na, right: nb}, naf + nbf } | lst ]
    |> Enum.sort_by(fn {_, freq} -> freq end)
    |> huffman
  end

  def charlist(sample, list \\ [])
  def charlist([], list) do list end
  def charlist([char | sample], list) do
    charlist(sample, [List.to_string([char]) | list])
  end

  def find(tree, ch, path \\ [])
  def find(%Leaf{char: ch}, ch, path) do { ch, Enum.reverse(path) } end
  def find(%Leaf{char: _}, _, _) do nil end
  def find(%Node{left: l, right: r}, ch, path) do
    find(l, ch, [0 | path]) || find(r, ch, [1 | path])
  end

  def findBits(tree, ch, path \\ "")
  def findBits(%Leaf{char: ch}, ch, path) do { ch, path } end
  def findBits(%Leaf{char: _}, _, _) do nil end
  def findBits(%Node{left: l, right: r}, ch, path) do
    findBits(l, ch, <<path::bits, 0::1>>) || findBits(r, ch, <<path::bits, 1::1>>)
  end

  def encode(sample \\ sample()) do
    get_table(sample)
    |> Enum.reduce([], fn {_, lst}, acc -> acc ++ lst end)
  end

  def get_table(sample) do
    tree = freq(sample) |> huffman()
    sample = charlist(sample)
    Enum.reverse(Enum.map(sample, fn ch -> find(tree, ch) end))
  end

  def decode([], _) do [] end
  def decode(seq, table) do
    {ch, rest} = decode_char(seq, 1, table)
    List.to_string([ch | decode(rest, table)])
  end

  def decode_char(seq, n, table) do
    {code, rest} = Enum.split(seq, n)
    case List.keyfind(table, code, 1) do
      {ch, _} -> {ch, rest}
      nil -> decode_char(seq, n+1, table)
    end
  end

  def read(file, n) do
    {:ok, fd} = File.open(file, [:read, :utf8])
     binary = IO.read(fd, n)
     File.close(fd)

     length = byte_size(binary)
     case :unicode.characters_to_list(binary, :utf8) do
       {:incomplete, chars, rest} ->
         {chars, length - byte_size(rest)}
       chars ->
         {chars, length}
     end
   end

  def bench(file, n) do
    {text, b} = read(file, n)
    c = length(text)
    {tree, t2} = time(fn -> huffman(freq(text)) end)
    {table, t3} = time(fn -> get_table(text) end)
    s = length(table)
    {encoded, t5} = time(fn -> encode(text) end)

    e = div(length(encoded), 8)
    r = Float.round(e / b, 3)
    {_, t6} = time(fn -> decode(encoded, table) end)

    IO.puts("text of #{c} characters")
    IO.puts("tree built in #{t2} ms")
    IO.puts("table of size #{s} in #{t3} ms")
    IO.puts("encoded in #{t5} ms")
    IO.puts("decoded in #{t6} ms")
    IO.puts("source #{b} bytes, encoded #{e} bytes, compression #{r}")
  end

  def time(func) do
    initial = Time.utc_now()
    result = func.()
    final = Time.utc_now()
    {result, Time.diff(final, initial, :microsecond) / 1000}
  end
end
