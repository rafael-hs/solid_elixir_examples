# SOLID examples in Elixir

This repository contains examples of the SOLID principles applied in Elixir. Each principle is demonstrated with a simple example that illustrates how to implement it in Elixir.

- **S** – Single Responsibility Principle
- **O** – Open/Closed Principle
- **L** – Liskov Substitution Principle
- **I** – Interface Segregation Principle
- **D** – Dependency Inversion Principle

---

## 1 - Single Responsibility Principle

**Definition:** The idea is to have cohesive and specialized modules and functions. Example when creating a user in the database:

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

---

**2 - Open/Closed Principle**

**Definition:** You can use composition or higher-order functions to allow for different behaviors without changing the internal code.

**Example:**

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

**3 - Liskov Substitution Principle**

**Definition:** Any module implementing a behavior must follow its contract so that it can be replaced by any other implementation without breaking the system.

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

---

# good implementation of the Liskov Substitution Principle
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

---

**4 - Interface Segregation Principle**

**Definition:** When you find an interface doing too many things, it's probably time to break it into smaller, more specific ones.

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

---

**5 - Dependency Inversion Principle**

**Definition:** High-level modules should not depend directly on low-level implementations. Both should depend on abstractions (via behaviors).

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

# --------------------------------------------------------------------------------------------

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

# EmailNotifier by default
OrderNotifier.notify(%{id: 101})
# used SMS Notifier instead of the default EmailNotifier
OrderNotifier.notify(%{id: 101}, SmsNotifier)
```
