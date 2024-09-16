defmodule Morse do

  def sample() do
    '.- .-.. .-.. ..-- -.-- --- ..- .-. ..-- -... .- ... . ..-- .- .-. . ..-- -... . .-.. --- -. --. ..-- - --- ..-- ..- ... '
  end

  def sample1() do
    '.- .-.. .-.. ..-- -.-- --- ..- .-. ..-- -... .- ... . ..-- .- .-. . ..-- -... . .-.. --- -. --. ..-- - --- ..-- ..- ... '
  end

  def sample2() do
    '.... - - .--. ... ---... .----- .----- .-- .-- .-- .-.-.- -.-- --- ..- - ..- -... . .-.-.- -.-. --- -- .----- .-- .- - -.-. .... ..--.. ...- .----. -.. .--.-- ..... .---- .-- ....- .-- ----. .--.-- ..... --... --. .--.-- ..... ---.. -.-. .--.-- ..... .---- '
  end

  def morse() do
    {:node, :na,
      {:node, 116,
        {:node, 109,
          {:node, 111,
            {:node, :na, {:node, 48, nil, nil}, {:node, 57, nil, nil}},
            {:node, :na, nil, {:node, 56, nil, {:node, 58, nil, nil}}}},
          {:node, 103,
            {:node, 113, nil, nil},
            {:node, 122,
              {:node, :na, {:node, 44, nil, nil}, nil},
              {:node, 55, nil, nil}}}},
        {:node, 110,
          {:node, 107, {:node, 121, nil, nil}, {:node, 99, nil, nil}},
          {:node, 100,
            {:node, 120, nil, nil},
            {:node, 98, nil, {:node, 54, {:node, 45, nil, nil}, nil}}}}},
      {:node, 101,
        {:node, 97,
          {:node, 119,
            {:node, 106,
              {:node, 49, {:node, 47, nil, nil}, {:node, 61, nil, nil}},
              nil},
            {:node, 112,
              {:node, :na, {:node, 37, nil, nil}, {:node, 64, nil, nil}},
              nil}},
          {:node, 114,
            {:node, :na, nil, {:node, :na, {:node, 46, nil, nil}, nil}},
            {:node, 108, nil, nil}}},
        {:node, 105,
          {:node, 117,
            {:node, 32,
              {:node, 50, nil, nil},
              {:node, :na, nil, {:node, 63, nil, nil}}},
            {:node, 102, nil, nil}},
          {:node, 115,
            {:node, 118, {:node, 51, nil, nil}, nil},
            {:node, 104, {:node, 52, nil, nil}, {:node, 53, nil, nil}}}}}}
  end

  def test() do
    {:node, :na,
      {:node, 66,
        {:node, 65, nil, nil},
        {:node, 67, nil, nil}
      },
      {:node, :na,
        {:node, 68, nil, nil},
        {:node, 70, nil, nil}
      }
    }
  end

  def codes() do
    [{32,"..--"},
     {37,".--.--"},
     {44,"--..--"},
     {45,"-....-"},
     {46,".-.-.-"},
     {47,".-----"},
     {48,"-----"},
     {49,".----"},
     {50,"..---"},
     {51,"...--"},
     {52,"....-"},
     {53,"....."},
     {54,"-...."},
     {55,"--..."},
     {56,"---.."},
     {57,"----."},
     {58,"---..."},
     {61,".----."},
     {63,"..--.."},
     {64,".--.-."},
     {97,".-"},
     {98,"-..."},
     {99,"-.-."},
     {100,"-.."},
     {101,"."},
     {102,"..-."},
     {103,"--."},
     {104,"...."},
     {105,".."},
     {106,".---"},
     {107,"-.-"},
     {108,".-.."},
     {109,"--"},
     {110,"-."},
     {111,"---"},
     {112,".--."},
     {113,"--.-"},
     {114,".-."},
     {115,"..."},
     {116,"-"},
     {117,"..-"},
     {118,"...-"},
     {119,".--"},
     {120,"-..-"},
     {121,"-.--"},
     {122,"--.."}]
  end

  # def encode(str) do
  #   table = traverse()
  #   Enum.map(charlist(str), fn ch ->
  #     Enum.find(table, fn {_, val} ->
  #       ch == val end) |> elem(0) end)
  #   |> Enum.reduce([], fn lst, acc -> insert_last(acc ++ lst, " ") end)
  #   |> Enum.reduce("", fn ch, acc -> List.to_string([acc | ch]) end)
  # end

  def traverse(morse \\ morse(), path \\ [], table \\ %{})
  def traverse({:node, val, nil, nil}, path, map) do
    case val do
      :na -> map
      _ -> Map.put(map, List.to_string([val]), path)
    end
  end
  def traverse({:node, val, left, nil}, path, map) do
    case val do
      :na -> traverse(left, insert_last(path, "-"), map)
      _ -> traverse(left, insert_last(path, "-"), Map.put(map, List.to_string([val]), path))
    end
  end
  def traverse({:node, val, nil, right}, path, map) do
    case val do
      :na -> traverse(right, insert_last(path, "."), map)
      _ -> traverse(right, insert_last(path, "."), Map.put(map, List.to_string([val]), path))
    end
  end
  def traverse({:node, :na, left, right}, path, map) do
    map = traverse(left, insert_last(path, "-"), map)
    traverse(right, insert_last(path, "."), map)
  end
  def traverse({:node, val, left, right}, path, map) do
    map = traverse(left, insert_last(path, "-"), Map.put(map, List.to_string([val]), path))
    traverse(right, insert_last(path, "."), map)
  end

  def insert_last([], val) do [val] end
  def insert_last([h | rest], val) do
    [h | insert_last(rest, val)]
  end

  def charlist(text, list \\ [])
  def charlist([], list) do Enum.reverse(list) end
  def charlist([char | text], list) do
    charlist(text, [List.to_string([char]) | list])
  end

  def encode(str) do
    table = codes()
    foldleft(Enum.reverse(str), table, [])
    |> List.to_string()
  end

  def foldleft([], _, final) do final end
  def foldleft([ch | rest], table, sofar) do
    code = Enum.find(table, fn {key, _} -> ch == key end) |> elem(1)
    code = code <> " "
    foldleft(rest, table, [code | sofar])
  end

  def decode(seq \\ sample2(), tree \\ morse())
  def decode([], _) do [] end
  def decode(seq, tree) do
    {ch, rest} = lookup(seq, tree)
    [ch | decode(rest, tree)]
  end

  def lookup([sign | rest], {:node, ch, left, right}) do
    case sign do
      46 -> lookup(rest, right)
      45 -> lookup(rest, left)
      32 -> {ch, rest}
    end
  end

    # def lookup([sign | rest], tree) do
  #   {tree[sign], rest}
  # end

  # def huffman(listWithFreq \\ freq())
  # def huffman([{tree, _}]) do tree end
  # def huffman([{na, naf}, {nb, nbf} | lst]) do
  #   [ { %Node{left: na, right: nb}, naf + nbf } | lst ]
  #   |> Enum.sort_by(fn {_, freq} -> freq end)
  #   |> huffman
  # end

  # def find(tree, ch, path \\ [])
  # def find(%Leaf{char: ch}, ch, path) do { ch, path } end
  # def find(%Leaf{char: _}, _, _) do nil end
  # def find(%Node{left: l, right: r}, ch, path) do
  #   find(l, ch, path <> ".") || find(r, ch, path <> "-")
  # end

  # def get_table(sample \\ sample())
  # def get_table(sample) do
  #   tree = freq(sample) |> huffman()
  #   sample = charlist(sample)
  #   Enum.reverse(Enum.map(sample, fn ch -> find(tree, ch) end))
  # end

  # def decode([], _) do [] end
  # def decode(seq, table) do
  #   {ch, rest} = decode_char(seq, 1, table)
  #   List.to_string([ch | decode(rest, table)])
  # end

  # def decode_char(seq, n, table) do
  #   {code, rest} = Enum.split(seq, n)
  #   case List.keyfind(table, code, 1) do
  #     {ch, _} -> {ch, rest}
  #     nil -> decode_char(seq, n+1, table)
  #   end
  # end

  # def freq(code \\ sample())
  # def freq(code) do
  #   String.split(code, " ")
  #   |> Enum.reduce(%{}, fn code, acc -> Map.update(acc, code, 1, fn val -> val + 1 end) end)
  #   |> Map.delete("")
  #   |> Enum.map(fn {key, freq} -> { %Leaf{char: key}, freq } end)
  # end

  # def freq(sample) do
  #   sample
  #   |> charlist()
  #   |> Enum.reduce(%{}, fn char, map -> Map.update(map, char, 1, fn val -> val + 1 end) end)
  #   |> Enum.sort_by(fn {_, freq} -> freq end)
  #   |> Enum.map(fn {key, freq} -> { %Leaf{char: key}, freq } end)
  # end

end
