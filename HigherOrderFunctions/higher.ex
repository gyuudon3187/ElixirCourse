defmodule Higher do
  def double(lst) do double_five_animal(:double, lst) end

  def five(lst) do double_five_animal(:five, lst) end

  def animal(lst) do double_five_animal(:animal, lst) end

  def double_five_animal(_, []) do [] end
  def double_five_animal(type, [itm | rest]) do
    case type do
      :double -> [itm*2 | double_five_animal(type, rest)]
      :five -> [itm+5 | double_five_animal(type, rest)]
      :animal ->
        [if itm == :dog do :fido else itm end | double_five_animal(type, rest)]
    end
  end

  def apply_to_all([], _) do [] end
  def apply_to_all([itm | rest], f) do [f.(itm) | apply_to_all(rest, f)] end

  def sum([]) do 0 end
  def sum([n | rest]) do n + sum(rest) end

  def prod([]) do 1 end
  def prod([n | rest]) do n * prod(rest) end

  def fold_right([], acc, _) do acc end
  def fold_right([itm | rest], acc, f) do
    f.(itm, fold_right(rest, acc, f))
  end

  def fold_left([], acc, _) do acc end
  def fold_left([itm | rest], acc, f) do
    fold_left(rest, f.(itm, acc), f)
  end

  def odd([]) do [] end
  def odd([n | rest]) do
    if rem(n, 2) == 1 do
      [n | odd(rest)]
    else
      odd(rest)
    end
  end

  def filter([], _) do [] end
  def filter([itm | rest], f) do
    if f.(itm) do
      [itm | filter(rest, f)]
    else
      filter(rest, f)
    end
  end

end
