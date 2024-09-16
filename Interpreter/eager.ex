defmodule Eager do
  def eval_expr({:atm, id}, _) do {:ok, id} end
  def eval_expr({:var, id}, env) do
    case EnvTree.lookup(id, env) do
      nil -> :error
      {_, str} -> {:ok, str}
    end
  end
  def eval_expr({:cons, expr1, expr2}, env) do
    case eval_expr(expr1, env) do
      :error -> IO.write("2"); :error
      {:ok, head} ->
        case eval_expr(expr2, env) do
          :error -> IO.write("3"); :error
          {:ok, tails} -> {:ok, {head, tails}}
      end
    end
  end
  def eval_expr({:case, expr, cls}, env) do
    case eval_expr(expr, env) do
      :error -> :error
      {:ok, str} -> eval_cls(cls, str, env)
    end
  end
  def eval_expr({:lambda, par, free, seq}, env) do
    case EnvTree.closure(free, env) do
      :error -> IO.write("5"); :error
      closure -> {:ok, {:closure, par, seq, closure}}
    end
  end
  def eval_expr({:apply, expr, args}, env) do
    case eval_expr(expr, env) do
      :error -> IO.write("6"); :error
      {:ok, {:closure, par, seq, closure}} ->
        case eval_args(args, env) do
          :error -> IO.write("7"); :error
          {:ok, strs} ->
            env = EnvTree.args(par, strs, closure)
            eval_seq(seq, env)
        end
    end
  end
  def eval_expr({:fun, id}, _) do
    {par, seq} = apply(Prgm, id, [])
    {:ok, {:closure, par, seq, EnvTree.new()}}
  end

  def eval_args(args, env) do eval_args(args, env, []) end
  def eval_args([], _, strs) do {:ok, strs} end
  def eval_args([arg | args], env, strs) do
    eval_args(args, env, strs ++ [elem(eval_expr(arg, env), 1)])
  end

  def eval_cls([], _, _) do :error end
  def eval_cls([{:clause, ptr, seq} | cls], str, env) do
    case eval_match(ptr, str, env) do
      :fail -> eval_cls(cls, str, env)
      {:ok, env} -> eval_seq(seq, env)
    end
  end

  def eval_match(:ignore, _, env) do {:ok, env} end
  def eval_match({:atm, id}, id, env) do {:ok, env} end
  def eval_match({:var, id}, str, env) do
    case EnvTree.lookup(id, env) do
      nil -> {:ok, EnvTree.add(id, str, env)}
      {_, ^str} -> {:ok, env}
      {_, _} -> :fail
    end
  end
  def eval_match({:cons, hp, tp}, {hexp, texp}, env) do
    case eval_match(hp, hexp, env) do
      :fail -> :fail
      {:ok, newEnv} -> eval_match(tp, texp, newEnv)
    end
  end
  def eval_match(_, _, _) do :fail end

  def extract_vars(expr) do
    case expr do
      {_, v} -> v
      {_, {:var, v1}, {:var, v2}} -> [v1, v2]
      {_, {:var, v}, _} -> v
      {_, _, {:var, v}} -> v
    end
  end

  def eval_scope(expr, env) do
    EnvTree.remove(extract_vars(expr), env)
  end

  def eval_seq([expr], env) do
    eval_expr(expr, env)
  end

  def eval_seq([{:match, ptr, expr} | rest], env) do
    case eval_expr(expr, env) do
      :error -> :error
      {:ok, str} ->
        env = eval_scope(ptr, env)
        case eval_match(ptr, str, env) do
          :fail -> :error
          {:ok, env} -> eval_seq(rest, env)
        end
    end
  end

  def eval(seq) do eval_seq(seq, nil) end
end
