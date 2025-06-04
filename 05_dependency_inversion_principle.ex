# bad code example of the Dependency Inversion Principle
defmodule OrderNotifier do
  def notify(order) do
    EmailService.send("Pedido ##{order.id} confirmado!")
  end
end

defmodule EmailService do
  def send(message) do
    IO.puts("Enviando e-mail: #{message}")
  end
end

# In this case, the `OrderNotifier` module is directly dependent on the `EmailService` module.

# good code example of the Dependency Inversion Principle
defmodule Notifier do
  @callback send(String.t()) :: :ok | {:error, term()}
end

defmodule EmailNotifier do
  @behaviour Notifier

  def send(message) do
    IO.puts("Enviando e-mail: #{message}")
    :ok
  end
end

defmodule SmsNotifier do
  @behaviour Notifier

  def send(message) do
    IO.puts("Enviando SMS: #{message}")
    :ok
  end
end

defmodule OrderNotifier do
  def notify(order, notifier \\ EmailNotifier) do
    message = "Pedido ##{order.id} confirmado!"
    notifier.send(message)
  end
end

# usa EmailNotifier por padrão
OrderNotifier.notify(%{id: 101})
# troca por SMS em tempo de execução
OrderNotifier.notify(%{id: 101}, SmsNotifier)
