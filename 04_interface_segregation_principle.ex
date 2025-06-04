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
