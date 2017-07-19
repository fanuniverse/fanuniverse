alias Fanuniverse.User

defimpl Canada.Can, for: User do
  # TODO: add more granular permissions

  def can?(%User{role: "administrator"}, :access, :admin), do: true
  def can?(_, :access, :admin), do: false
end
