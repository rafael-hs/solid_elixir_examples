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
