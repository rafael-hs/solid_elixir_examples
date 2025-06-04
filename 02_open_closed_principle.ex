defmodule PaymentProcessor do
  def process(order, tax_calculator) do
    tax = tax_calculator.(order)
    total = order.amount + tax
    {:ok, %{total: total, tax: tax, order: order}}
  end
end

IO.inspect(
  PaymentProcessor.process(%{amount: 100}, fn order ->
    order.amount * 0.1
  end)
)

IO.inspect(
  PaymentProcessor.process(%{amount: 100}, fn order ->
    order.amount * 0.2
  end)
)
