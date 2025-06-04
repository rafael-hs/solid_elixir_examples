# SOLID examples in Elixir

This repository contains examples of the SOLID principles applied in Elixir. Each principle is demonstrated with a simple example that illustrates how to implement it in Elixir.

- **S** – Single Responsibility Principle (Princípio da Responsabilidade Única)
- **O** – Open/Closed Principle (Princípio Aberto/Fechado)
- **L** – Liskov Substitution Principle (Princípio da Substituição de Liskov)
- **I** – Interface Segregation Principle (Princípio da Segregação de Interfaces)
- **D** – Dependency Inversion Principle (Princípio da Inversão de Dependência)

**1 - Single Responsibility Principle**

**Definição:** A ideia no geral é ter módulos e funções coesas e especializados, exemplo de um código ao criar um usuário na base de dados:

**Bad Code:**

```elixir
defmodule User do
  def create_user(attrs) do
	  user =
			  %User{attrs}
			  |> Repo.insert!()
    Email.send_welcome(user)
    Logger.info("User created: #{user.id}")
    user
  end
end
```

**Good Code:**

```elixir
defmodule UserCreator do
  def create(attrs) do
    Repo.insert!(%UserStruct{attrs})
  end
end

defmodule WelcomeNotifier do
  def send_welcome_email(user) do
    Email.send_welcome(user)
  end
end
```

**2 - Open/Closed Principle**

**Definição:** Pode usar **Composição** ou **Funções de ordem superior** para permitir comportamentos diferentes sem alterar o código interno existente.

**Exemplo:**

```elixir
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
```

**3 - Liskov Substitution Principle**

**Definição:** Qualquer interface que implementar um comportamento deve obedecer todas as regras da interface implementada ou seja, poderia ser substituída pela interface sem que seu **programa/sistema** quebre, caso isso não acontece está ferindo o princípio de **Liskov**.

```elixir
# bad implementation of the Liskov Substitution Principle
defmodule Car do
  @callback turn_on_engine() :: {:ok, String.t()}
  @callback accelerate() :: {:ok, String.t()}
end

defmodule MotorCar do
  @behaviour Car

  def turn_on_engine() do
    {:ok, "MotorCar engine started"}
  end

  def accelerate() do
    {:ok, "MotorCar is accelerating"}
  end
end

defmodule ElectricCar do
  @behaviour Car

  # This implementation violates the Liskov Substitution Principle
  def turn_on_engine() do
    {:error, "ElectricCar has not engine"}
  end

  def accelerate() do
    {:ok, "ElectricCar is accelerating quietly"}
  end
end

# -------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------
# good implementation of the Liskov Substitution Principle
defmodule Car do
  @callback accelerate() :: {:ok, String.t()}
end

defmodule MotorCar do
  @callback turn_on_engine() :: {:ok, String.t()} | {:error, :has_no_engine}

  @behaviour Car
end

defmodule ElectricCar do
  @callback turn_on_engine() :: {:error, :has_no_engine}

  @behaviour Car
end

defmodule Gol do
  @behaviour MotorCar

  def turn_on_engine() do
    {:ok, "MotorCar engine started"}
  end

  def accelerate() do
    {:ok, "MotorCar is accelerating"}
  end
end

defmodule Byd do
  @behaviour ElectricCar

  def turn_on_engine() do
    {:error, :has_no_engine}
  end

  def accelerate() do
    {:ok, "ElectricCar is accelerating quietly"}
  end
end
```

**4 - Interface Segregation Principle**

**Definição:** No momento que você tiver uma interface com muitas funcionalidade é bem provável que seja necessário segregar as interfaces em interfaces menores para respeitar esse princípio.

```elixir
# bad code example of the Interface Segregation Principle
defmodule DatabaseBehaviour do
  @callback connect() :: {:ok, pid()} | {:error, String.t()}
  @callback disconnect(pid()) :: :ok | {:error, String.t()}
  @callback query(pid(), String.t()) :: {:ok, any()} | {:error, String.t()}
end

# good code example of the Interface Segregation Principle
defmodule ConnectDatabaseBehaviour do
  @callback disconnect(pid()) :: :ok | {:error, String.t()}
end

defmodule DisconnectDatabaseBehaviour do
  @callback disconnect(pid()) :: :ok | {:error, String.t()}
end

defmodule QueryDatabaseBehaviour do
  @callback query(pid(), String.t()) :: {:ok, any()} | {:error, String.t()}
end
```

**5 - Dependency Inversion Principle**

Definição: Módulos de alto nível não devem depender da implementação de módulos de baixo nível.

```elixir
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
# ------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------
# ------------------------------------------------------------------------------------------------

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

```
