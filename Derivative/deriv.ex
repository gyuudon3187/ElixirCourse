defmodule Deriv do
  @type literal() :: {:num, number()} | {:var, atom()}
  @type expr() :: literal()
  | {:add, expr(), expr()}
  | {:mul, expr(), expr()}
  | {:exp, expr(), literal()}
  | {:ln, expr(), literal()}
  | {:sin, expr()}
  | {:cos, expr()}
  @type withRespectTo() :: {:var, atom()}

  def test1() do
    e = {:add,
          {:mul, {:num, 2}, {:var, :x}},
          {:num, 4}}
    d = deriv(e, :x)

    IO.write("expression: #{printDeriv(e)}\n")
    IO.write("derivative: #{printDeriv(d)}\n")
    IO.write("simplified: #{printDeriv(simplify(d))}\n")
  end

  def test2() do
    e = {:add,
          {:exp, {:var, :x}, {:num, 0.5}},
          {:num, 4}}
    d = deriv(e, :x)
    IO.write("expression: #{printDeriv(e)}\n")
    IO.write("derivative: #{printDeriv(d)}\n")
    IO.write("simplified: #{printDeriv(simplify(d))}\n")
  end

  def test3() do
    e = {:ln,
          {:var, :x},
          {:num, 1}
        }
    d = deriv(e, :x)
    IO.write("expression: #{printDeriv(e)}\n")
    IO.write("derivative: #{printDeriv(d)}\n")
    IO.write("simplified: #{printDeriv(simplify(d))}\n")
  end

  def test4() do
    e = {:sin,
          {:var, :x},
        }
    d = deriv(e, :x)
    IO.write("expression: #{printDeriv(e)}\n")
    IO.write("derivative: #{printDeriv(d)}\n")
    IO.write("simplified: #{printDeriv(simplify(d))}\n")
  end

  #derivating a literal
  def deriv({:num, _}, _) do {:num, 0} end
  def deriv({:var, withRespectTo}, withRespectTo) do {:num, 1} end
  def deriv({:var, _}, _) do {:num, 0} end

  #derivating an expression
  def deriv(expr, withRespectTo) do
    case expr do
      {:add, expr1, expr2} ->
        {:add, deriv(expr1, withRespectTo), deriv(expr2, withRespectTo)}

      {:mul, expr1, expr2} ->
        {:add,
          {:mul, deriv(expr1, withRespectTo), expr2},
          {:mul, expr1, deriv(expr2, withRespectTo)}
        }

      {:exp, expr, {:num, pow}} ->
        {:mul,
          {:mul,
            {:num, pow},
            {:exp,
              expr,
              {:num, pow-1}
            }
          },
          deriv(expr, withRespectTo)
        }

      {:ln, expr, {:num, pow}} ->
        {:mul,
          {:mul,
            {:num, pow},
            {:exp,
              expr,
              {:num, -1}
            }
          },
          deriv(expr, withRespectTo)
        }


      {:sin, expr} ->
        {:mul,
          {:cos, expr},
          deriv(expr, withRespectTo)
        }
    end
  end

  def simplify(expr) do
    case expr do
      {:add, expr1, expr2} -> simplify_add(simplify(expr1), simplify(expr2))
      {:mul, expr1, expr2} -> simplify_mul(simplify(expr1), simplify(expr2))
      literal -> literal
    end
  end

  def simplify_add({:num, 0}, expr2) do expr2 end
  def simplify_add(expr1, {:num, 0}) do expr1 end
  def simplify_add({:num, num1}, {:num, num2}) do
    {:num, num1 + num2}
  end
  def simplify_add(expr1, expr2) do {:add, expr1, expr2} end

  def simplify_mul({:num, 0}, _) do {:num, 0} end
  def simplify_mul({:num, 1}, expr2) do expr2 end
  def simplify_mul(_, {:num, 0}) do {:num, 0} end
  def simplify_mul(expr1, {:num, 1}) do expr1 end
  def simplify_mul({:num, num1}, {:num, num2}) do
    {:num, num1 * num2}
  end
  def simplify_mul(expr1, expr2) do {:mul, expr1, expr2} end

  def printDeriv(exprOrliteral) do
    case exprOrliteral do
      {:num, number} -> "#{number}"

      {:var, variable} -> "#{variable}"

      {:add, expr1, expr2} ->
        "(#{printDeriv(expr1)} + #{printDeriv(expr2)})"

      {:mul, expr1, expr2} ->
        "#{printDeriv(expr1)} * #{printDeriv(expr2)}"

      {:exp, expr1, expr2} ->
        "#{printDeriv(expr1)}^#{printDeriv(expr2)}"

      {:ln, {:var, v}, {:num, power}} -> "ln #{v}^#{power}"

      {:sin, {:var, v}} -> "sin(#{v})"

      {:cos, {:var, v}} -> "cos(#{v})"
    end
  end
end
