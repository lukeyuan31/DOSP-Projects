defmodule TwitterSimulator.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias TwitterSimulator.Accounts.{User,Password}

  schema "users" do
    field :password, :string
    field :username, :string

    #virtual fields
    field :input_password, :string , virtual:true
    field :password_confirmation, :string, virtual:true

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password])
    |> validate_required([:username, :password])
    |> validate_length([:password, min:6])
    |> validate_confirmation(:password)
    |> validate_format(:username,~r/^[a-z0-9][a-z0-9]+[a-z0-9]$/i)
    |> validate_length(:username, min: 3)
    |> downcase_username
    |> unique_constraint(:username)
  end

  defp downcase_username(changeset) do
    update_change(changeset, :username, &String.downcase/1)
  end

end
