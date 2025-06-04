# Exemplos de SOLID em Elixir

Este repositório contém exemplos dos princípios **SOLID** aplicados em **Elixir**. Cada princípio é demonstrado com um exemplo simples que mostra como implementá-lo na linguagem funcional de forma idiomática.

## Princípios

- **S** – Princípio da Responsabilidade Única (Single Responsibility Principle)
- **O** – Princípio Aberto/Fechado (Open/Closed Principle)
- **L** – Princípio da Substituição de Liskov (Liskov Substitution Principle)
- **I** – Princípio da Segregação de Interfaces (Interface Segregation Principle)
- **D** – Princípio da Inversão de Dependência (Dependency Inversion Principle)

---

## 1 - Princípio da Responsabilidade Única

**Definição:** Um módulo ou função deve ter apenas uma responsabilidade. A ideia é manter o código coeso e especializado.

### ❌ Código ruim:

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

### ✅ Código bom:

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

---

## 2 - Princípio Aberto/Fechado

**Definição:** Um módulo deve estar aberto para extensão, mas fechado para modificação. Em Elixir, podemos fazer isso usando **composição** e **funções de ordem superior**.

### ✅ Exemplo:

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

---

## 3 - Princípio da Substituição de Liskov

**Definição:** Qualquer implementação de um comportamento (`@behaviour`) deve poder ser substituída por outra implementação **sem quebrar o sistema**. Se não for possível substituir sem erro ou comportamento inesperado, o princípio está sendo violado.

### ❌ Implementação ruim:

```elixir
defmodule Car do
  @callback turn_on_engine() :: {:ok, String.t()}
  @callback accelerate() :: {:ok, String.t()}
end

defmodule MotorCar do
  @behaviour Car

  def turn_on_engine(), do: {:ok, "MotorCar engine started"}
  def accelerate(), do: {:ok, "MotorCar is accelerating"}
end

defmodule ElectricCar do
  @behaviour Car

  # Violação do LSP
  def turn_on_engine(), do: {:error, "ElectricCar has not engine"}
  def accelerate(), do: {:ok, "ElectricCar is accelerating quietly"}
end
```

### ✅ Implementação correta:

```elixir
defmodule Car do
  @callback accelerate() :: {:ok, String.t()}
end

defmodule MotorCar do
  @callback turn_on_engine() :: {:ok, String.t()}
  @behaviour Car
end

defmodule ElectricCar do
  @callback turn_on_engine() :: {:error, :has_no_engine}
  @behaviour Car
end

defmodule Gol do
  @behaviour MotorCar

  def turn_on_engine(), do: {:ok, "MotorCar engine started"}
  def accelerate(), do: {:ok, "MotorCar is accelerating"}
end

defmodule Byd do
  @behaviour ElectricCar

  def turn_on_engine(), do: {:error, :has_no_engine}
  def accelerate(), do: {:ok, "ElectricCar is accelerating quietly"}
end
```

---

## 4 - Princípio da Segregação de Interfaces

**Definição:** Interfaces grandes devem ser divididas em outras menores e mais específicas. Isso evita que módulos implementem funções que não utilizam.

### ❌ Código ruim:

```elixir
defmodule DatabaseBehaviour do
  @callback connect() :: {:ok, pid()} | {:error, String.t()}
  @callback disconnect(pid()) :: :ok | {:error, String.t()}
  @callback query(pid(), String.t()) :: {:ok, any()} | {:error, String.t()}
end
```

### ✅ Código bom:

```elixir
defmodule ConnectDatabaseBehaviour do
  @callback connect() :: {:ok, pid()} | {:error, String.t()}
end

defmodule DisconnectDatabaseBehaviour do
  @callback disconnect(pid()) :: :ok | {:error, String.t()}
end

defmodule QueryDatabaseBehaviour do
  @callback query(pid(), String.t()) :: {:ok, any()} | {:error, String.t()}
end
```

---

## 5 - Princípio da Inversão de Dependência

**Definição:** Módulos de alto nível **não devem depender diretamente** de módulos de baixo nível. Ambos devem depender de uma **abstração** (interface).

### ❌ Código ruim:

```elixir
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
```

> Nesse caso, `OrderNotifier` está acoplado diretamente ao `EmailService`.

---

### ✅ Código bom:

```elixir
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
  def notify(order, notifier \ EmailNotifier) do
    message = "Pedido ##{order.id} confirmado!"
    notifier.send(message)
  end
end

# Usa EmailNotifier por padrão
OrderNotifier.notify(%{id: 101})

# Troca por SMS em tempo de execução
OrderNotifier.notify(%{id: 101}, SmsNotifier)
```
