defmodule Shunt do

  def find([], []) do [] end
  def find(xs, [y | ys]) do
    {hs, ts} = Train.split(xs, y)
    hn = Enum.reduce(hs, 0, fn(_, acc) -> acc + 1 end)
    tn = Enum.reduce([y|ts], 0, fn(_, acc) -> acc + 1 end)
    [{:one, tn}, {:two, hn}, {:one, -tn}, {:two, -hn} | find(Train.append(hs, ts), ys)]
  end

  def few([], []) do [] end
  def few([y | xs], [y | ys]) do few(xs, ys) end
  def few(xs, [y | ys]) do
    {hs, ts} = Train.split(xs, y)
    hn = Enum.reduce(hs, 0, fn(_, acc) -> acc + 1 end)
    tn = Enum.reduce([y|ts], 0, fn(_, acc) -> acc + 1 end)
    [{:one, tn}, {:two, hn}, {:one, -tn}, {:two, -hn} | few(Train.append(hs, ts), ys)]
  end

  def compress(ms) do
    ns = rules(ms)
    if ns == ms do
      ms
    else
      compress(ns)
    end
  end

  def rules([]) do [] end
  def rules([{:one, 0} | rest]) do rules(rest) end
  def rules([{:two, 0} | rest]) do rules(rest) end
  def rules([{:one, n} | [{:one, m} | rest]]) do [{:one, n+m} | rules(rest)] end
  def rules([{:two, n} | [{:two, m} | rest]]) do [{:two, n+m} | rules(rest)] end
  def rules([h | rest]) do [h | rules(rest)] end
end
