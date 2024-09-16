defmodule Train do
  def take(_, 0) do[] end
  def take([h | rest], n) do
    [h | take(rest, n - 1)]
  end

  def drop(rest, 0) do rest end
  def drop([_ | rest], n) do
    drop(rest, n - 1)
  end

  def append(train1, train2) do
    train1 ++ train2
  end

  def member([y | _], y) do true end
  def member([], _) do false end
  def member([_ | rest], y) do
    member(rest, y)
  end

  def position([y | _], y, acc) do acc end
  def position([], _, _) do false end
  def position([_ | rest], y, acc) do
    position(rest, y, acc + 1)
  end
  def position(train, y) do
    position(train, y, 1)
  end

  def split([], _, _) do false end
  def split([y | rest], y, train1) do
    {Enum.reverse(train1), rest}
  end
  def split([h | rest], y, train1) do
    split(rest, y, [h | train1])
  end
  def split(train, y) do
    split(train, y, [])
  end

  def main([], _, acc, _, _) do acc end
  def main([_ | rest], n, acc, remain, take) do
    main(rest, n - 1, acc + 1, remain, take)
  end
  def main(train, n) do
    acc = main(train, n, 0, [], [])

    if acc - n < 0 do
      {-(acc - n), [], train}
    else
      {0, take(train, acc - n), drop(train, acc - n)}
    end
  end

  def single(move, tracks) do
    main = elem(tracks, 0)
    one = elem(tracks, 1)
    two = elem(tracks, 2)

    case move do
      {:one, n} ->
        if n > 0 do
          {_, remain, take} = main(main, n)
          {remain, append(take, one), two}
        else
          remain = drop(one, -n)
          take = take(one, -n)
          {append(main, take), remain, two}
        end

      {:two, n} ->
        if n > 0 do
          {_, remain, take} = main(main, n)
          {remain, one, append(take, two)}
        else
          remain = drop(two, -n)
          take = take(two, -n)
          {append(main, take), one, remain}
        end

        {_, 0} -> tracks
    end
  end

  def sequence([], _) do [] end
  def sequence([h | seq], tracks) do
    updated_tracks = single(h, tracks)
    [updated_tracks | sequence(seq, updated_tracks)]
  end
end
