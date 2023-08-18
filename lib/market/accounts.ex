defmodule Market.Accounts do
  import Ecto.Query, warn: false
  alias Market.Repo

  alias Market.Accounts.{Vendor, VendorToken, VendorNotifier}

  def get_vendor_by_email(email) when is_binary(email) do
    Repo.get_by(Vendor, email: email)
  end

  def get_vendor_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    vendor = Repo.get_by(Vendor, email: email)
    if Vendor.valid_password?(vendor, password), do: vendor
  end

  def get_vendor!(id), do: Repo.get!(Vendor, id)

  def register_vendor(attrs) do
    %Vendor{}
    |> Vendor.registration_changeset(attrs)
    |> Repo.insert()
  end

  def change_vendor_registration(%Vendor{} = vendor, attrs \\ %{}) do
    Vendor.registration_changeset(vendor, attrs, hash_password: false, validate_email: false)
  end

  def change_vendor_email(vendor, attrs \\ %{}) do
    Vendor.email_changeset(vendor, attrs, validate_email: false)
  end

  def apply_vendor_email(vendor, password, attrs) do
    vendor
    |> Vendor.email_changeset(attrs)
    |> Vendor.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  def update_vendor_email(vendor, token) do
    context = "change:#{vendor.email}"

    with {:ok, query} <- VendorToken.verify_change_email_token_query(token, context),
         %VendorToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(vendor_email_multi(vendor, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp vendor_email_multi(vendor, email, context) do
    changeset =
      vendor
      |> Vendor.email_changeset(%{email: email})
      |> Vendor.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:vendor, changeset)
    |> Ecto.Multi.delete_all(:tokens, VendorToken.vendor_and_contexts_query(vendor, [context]))
  end

  def deliver_vendor_update_email_instructions(%Vendor{} = vendor, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, vendor_token} = VendorToken.build_email_token(vendor, "change:#{current_email}")

    Repo.insert!(vendor_token)
    VendorNotifier.deliver_update_email_instructions(vendor, update_email_url_fun.(encoded_token))
  end

  def change_vendor_password(vendor, attrs \\ %{}) do
    Vendor.password_changeset(vendor, attrs, hash_password: false)
  end

  def update_vendor_password(vendor, password, attrs) do
    changeset =
      vendor
      |> Vendor.password_changeset(attrs)
      |> Vendor.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:vendor, changeset)
    |> Ecto.Multi.delete_all(:tokens, VendorToken.vendor_and_contexts_query(vendor, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{vendor: vendor}} -> {:ok, vendor}
      {:error, :vendor, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_vendor_session_token(vendor) do
    {token, vendor_token} = VendorToken.build_session_token(vendor)
    Repo.insert!(vendor_token)
    token
  end

  @doc """
  Gets the vendor with the given signed token.
  """
  def get_vendor_by_session_token(token) do
    {:ok, query} = VendorToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_vendor_session_token(token) do
    Repo.delete_all(VendorToken.token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  def deliver_vendor_confirmation_instructions(%Vendor{} = vendor, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if vendor.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, vendor_token} = VendorToken.build_email_token(vendor, "confirm")
      Repo.insert!(vendor_token)
      VendorNotifier.deliver_confirmation_instructions(vendor, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a vendor by the given token.

  If the token matches, the vendor account is marked as confirmed
  and the token is deleted.
  """
  def confirm_vendor(token) do
    with {:ok, query} <- VendorToken.verify_email_token_query(token, "confirm"),
         %Vendor{} = vendor <- Repo.one(query),
         {:ok, %{vendor: vendor}} <- Repo.transaction(confirm_vendor_multi(vendor)) do
      {:ok, vendor}
    else
      _ -> :error
    end
  end

  defp confirm_vendor_multi(vendor) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:vendor, Vendor.confirm_changeset(vendor))
    |> Ecto.Multi.delete_all(:tokens, VendorToken.vendor_and_contexts_query(vendor, ["confirm"]))
  end

  ## Reset password

  @doc ~S"""
  Delivers the reset password email to the given vendor.

  ## Examples

      iex> deliver_vendor_reset_password_instructions(vendor, &url(~p"/vendors/reset_password/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_vendor_reset_password_instructions(%Vendor{} = vendor, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, vendor_token} = VendorToken.build_email_token(vendor, "reset_password")
    Repo.insert!(vendor_token)
    VendorNotifier.deliver_reset_password_instructions(vendor, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the vendor by reset password token.

  ## Examples

      iex> get_vendor_by_reset_password_token("validtoken")
      %Vendor{}

      iex> get_vendor_by_reset_password_token("invalidtoken")
      nil

  """
  def get_vendor_by_reset_password_token(token) do
    with {:ok, query} <- VendorToken.verify_email_token_query(token, "reset_password"),
         %Vendor{} = vendor <- Repo.one(query) do
      vendor
    else
      _ -> nil
    end
  end

  @doc """
  Resets the vendor password.

  ## Examples

      iex> reset_vendor_password(vendor, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %Vendor{}}

      iex> reset_vendor_password(vendor, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_vendor_password(vendor, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:vendor, Vendor.password_changeset(vendor, attrs))
    |> Ecto.Multi.delete_all(:tokens, VendorToken.vendor_and_contexts_query(vendor, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{vendor: vendor}} -> {:ok, vendor}
      {:error, :vendor, changeset, _} -> {:error, changeset}
    end
  end
end
