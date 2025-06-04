# bad code
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

# good code
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
