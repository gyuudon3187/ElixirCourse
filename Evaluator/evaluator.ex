defmodule Eval do

  def test() do
    # IO.write("test 1\n")
    # print(
    #   simplify(
    #     eval(
    #           {:add,
    #             {:add,
    #               {:mul,
    #                 {:num, 2}, {:var, :x}
    #               },
    #               {:num, 3}
    #             },
    #             {:q, 12, 7}
    #           },
    #           {:node, :x, {:q, 12, 10}, nil, nil}
    #         )
    #   ))

    # IO.write("\n\ntest 2\n")
    # print(
    #   simplify(
    #     eval(
    #           {:sub,{:num, 5}, {:var, :x}},
    #           {:node, :x, {:q, 1, 4}, nil, nil}
    #         )
    #   ))

    IO.write("\n\ntest 3\n")
    print(
      simplify(
        eval(
              {:div,{:num, 4}, {:var, :x}},
              {:node, :x, {:q, 1, 4}, nil, nil}
            )
      ))
  end

  def eval({:num, n}, _) do {:num, n} end
  def eval({:q, numerator, denominator}, _) do {:q, numerator, denominator} end
  def eval({:var, v}, env) do
    case EnvTree.lookup(v, env) do
      nil -> :error
      {_, val} -> val
    end
  end
  def eval({op, expr1, expr2}, env) do
    case op do
      :add -> add(eval(expr1, env), eval(expr2, env))
      :sub -> sub(eval(expr1, env), eval(expr2, env))
      :mul -> mul(eval(expr1, env), eval(expr2, env))
      :div -> divide(eval(expr1, env), eval(expr2, env))
    end
  end

  def add(:error, _) do :error end
  def add(_, :error) do :error end
  def add({:num, n1}, {:num, n2}) do {:num, n1 + n2} end
  def add({:q, numerator, denominator}, {:num, n}) do
    add({:q, numerator, denominator}, {:q, n, 1})
  end
  def add({:num, n}, {:q, numerator, denominator}) do
    add({:q, numerator, denominator}, {:q, n, 1})
  end
  def add({:q, numerator1, denominator1}, {:q, numerator2, denominator2}) do
    {:q,
      numerator1 * denominator2 + numerator2 * denominator1,
      denominator1 * denominator2
    }
  end

  def sub(:error, _) do :error end
  def sub(_, :error) do :error end
  def sub({:num, n1}, {:num, n2}) do {:num, n1 - n2} end
  def sub({:q, numerator, denominator}, {:num, n}) do
    sub({:q, numerator, denominator}, {:q, n, 1})
  end
  def sub({:num, n}, {:q, numerator, denominator}) do
    sub({:q, n, 1}, {:q, numerator, denominator})
  end
  def sub({:q, numerator1, denominator1}, {:q, numerator2, denominator2}) do
    {:q,
      numerator1 * denominator2 - numerator2 * denominator1,
      denominator1 * denominator2
    }
  end

  def mul(:error, _) do :error end
  def mul(_, :error) do :error end
  def mul({:num, n1}, {:num, n2}) do {:num, n1 * n2} end
  def mul({:q, numerator, denominator}, {:num, n}) do {:q, n * numerator, denominator} end
  def mul({:num, n}, {:q, numerator, denominator}) do {:q, n * numerator, denominator} end
  def mul({:q, numerator1, denominator1}, {:q, numerator2, denominator2}) do
    {:q, numerator1 * numerator2, denominator1 * denominator2}
  end

  def divide(:error, _) do :error end
  def divide(_, :error) do :error end
  def divide({:num, n1}, {:num, n2}) do
    if rem(n1, n2) == 0 do
      {:num, n1 / n2}
    else
      {:q, n1, n2}
    end
  end
  def divide({:q, numerator, denominator}, {:num, n}) do
    divide({:q, numerator, denominator}, {:q, n, 1})
  end
  def divide({:num, n}, {:q, numerator, denominator}) do
    divide({:q, n, 1}, {:q, numerator, denominator})
  end
  def divide({:q, numerator1, denominator1}, {:q, numerator2, denominator2}) do
    {:q, numerator1 * denominator2, numerator2 * denominator1}
  end

  def simplify(:error) do :error end
  def simplify({:num, n}) do {:num, n} end
  def simplify({:q, numerator, denominator}) do
    gcd = Integer.gcd(numerator, denominator)

    numerator = trunc(numerator / gcd)
    denominator = trunc(denominator / gcd)

    quotient = Kernel.floor(numerator / denominator)
    remainder = rem(numerator, denominator)

    cond do
      remainder == 0 -> {:num, quotient}
      numerator > denominator -> {:add, {:num, quotient}, {:q, remainder, denominator}}
      numerator < denominator -> {:q, numerator, denominator}
    end
  end

  def print(:error) do IO.write("Error") end
  def print({:num, n}) do
    "#{n}"
  end
  def print({:q, numerator, denominator}) do
    "#{numerator}/#{denominator}"
  end
  def print({:add, expr1, expr2}) do
    "#{print(expr1)} + #{print(expr2)}"
  end
end
