defmodule EnvTree do

  def args([], _, env) do env end
  def args([par | pars], [str | strs], env) do
    args(pars, strs, add(par, str, env))
  end

  def closure(keys, env) do closure(keys, env, new()) end
  def closure([], _, newEnv) do newEnv end
  def closure([key | keys], env, newEnv) do
    closure(keys, env, add(key, elem(lookup(key, env), 1), newEnv))
  end

  def findMin({:node, key, val, :nil, right}) do {key, val, right} end
  def findMin({:node, key, val, left, right}) do
    {minKey, minVal, minRight} = findMin(left)
    newRight = {:node, key, val, minRight, right}
    {minKey, minVal, newRight}
  end

  def new() do nil end

  def remove(_, :nil) do :nil end
  def remove(:nil, env) do env end
  def remove([key | rest], env) do
    remove(rest, remove(key, env))
  end
  def remove(key, {:node, key, _, :nil, :nil}) do :nil end
  def remove(key, {:node, key, _, left, :nil}) do left end
  def remove(key, {:node, key, _, :nil, right}) do right end
  def remove(key, {:node, key, _, left, right}) do
    {keySwapped, valSwapped, newRight} = findMin(right)
    {:node, keySwapped, valSwapped, left, newRight}
  end
  def remove(key, {:node, k, v, left, right}) do
    if key < k do
      {:node, k, v, remove(key, left), right}
    else
      {:node, k, v, left, remove(key, right)}
    end
  end

  def add(key, value, :nil) do {:node, key, value, :nil, :nil} end
  def add(key, value, {:node, key, _, left, right}) do {:node, key, value, left, right} end
  def add(key, value, {:node, k, v , left, right}) do
    if key < k do
      {:node, k, v, add(key, value, left), right}
    else
      {:node, k, v, left, add(key, value, right)}
    end
  end

  def modify(_, _, :nil) do :nil end
  def modify(key, value, {:node, key, _, left, right}) do
    {:node, key, value, left, right}
  end
  def modify(key, value, {:node, k, v, left, right}) do
    if key < k do
      {:node, k, v, modify(key, value, left), right}
    else
      {:node, k, v, left, modify(key, value, right)}
    end
  end

  def lookup(_, :nil) do nil end # emtpy tree
  def lookup(key, {:node, key, value, _, _}) do {key, value} end # matching leaf
  def lookup(key, {:node, k, _, left, right}) do # continue search for matching leaf
    if key < k do
      lookup(key, left)
    else
      lookup(key, right)
    end
  end
end
