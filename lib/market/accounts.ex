defmodule Market.Accounts do
  import Ecto.Query, warn: false
  alias Market.Repo

  alias Market.Accounts.{Vendor, VendorToken, VendorNotifier}
  alias Market.Accounts.{Retailer, RetailerToken, RetailerNotifier}

  ### Vendor
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

  def deliver_vendor_update_email_instructions(
        %Vendor{} = vendor,
        current_email,
        update_email_url_fun
      )
      when is_function(update_email_url_fun, 1) do
    {encoded_token, vendor_token} =
      VendorToken.build_email_token(vendor, "change:#{current_email}")

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

  def generate_vendor_session_token(vendor) do
    {token, vendor_token} = VendorToken.build_session_token(vendor)
    Repo.insert!(vendor_token)
    token
  end

  def get_vendor_by_session_token(token) do
    {:ok, query} = VendorToken.verify_session_token_query(token)
    Repo.one(query)
  end

  def delete_vendor_session_token(token) do
    Repo.delete_all(VendorToken.token_and_context_query(token, "session"))
    :ok
  end

  def deliver_vendor_confirmation_instructions(%Vendor{} = vendor, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if vendor.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, vendor_token} = VendorToken.build_email_token(vendor, "confirm")
      Repo.insert!(vendor_token)

      VendorNotifier.deliver_confirmation_instructions(
        vendor,
        confirmation_url_fun.(encoded_token)
      )
    end
  end

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

  def deliver_vendor_reset_password_instructions(%Vendor{} = vendor, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, vendor_token} = VendorToken.build_email_token(vendor, "reset_password")
    Repo.insert!(vendor_token)

    VendorNotifier.deliver_reset_password_instructions(
      vendor,
      reset_password_url_fun.(encoded_token)
    )
  end

  def get_vendor_by_reset_password_token(token) do
    with {:ok, query} <- VendorToken.verify_email_token_query(token, "reset_password"),
         %Vendor{} = vendor <- Repo.one(query) do
      vendor
    else
      _ -> nil
    end
  end

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

  # Retailer
  def get_retailer_by_email(email) when is_binary(email) do
    Repo.get_by(Retailer, email: email)
  end

  def get_retailer_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    retailer = Repo.get_by(Retailer, email: email)
    if Retailer.valid_password?(retailer, password), do: retailer
  end

  def get_retailer!(id), do: Repo.get!(Retailer, id)

  def register_retailer(attrs) do
    %Retailer{}
    |> Retailer.registration_changeset(attrs)
    |> Repo.insert()
  end

  def change_retailer_registration(%Retailer{} = retailer, attrs \\ %{}) do
    Retailer.registration_changeset(retailer, attrs, hash_password: false, validate_email: false)
  end

  def change_retailer_email(retailer, attrs \\ %{}) do
    Retailer.email_changeset(retailer, attrs, validate_email: false)
  end

  def apply_retailer_email(retailer, password, attrs) do
    retailer
    |> Retailer.email_changeset(attrs)
    |> Retailer.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  def update_retailer_email(retailer, token) do
    context = "change:#{retailer.email}"

    with {:ok, query} <- RetailerToken.verify_change_email_token_query(token, context),
         %RetailerToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(retailer_email_multi(retailer, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp retailer_email_multi(retailer, email, context) do
    changeset =
      retailer
      |> Retailer.email_changeset(%{email: email})
      |> Retailer.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:retailer, changeset)
    |> Ecto.Multi.delete_all(
      :tokens,
      RetailerToken.retailer_and_contexts_query(retailer, [context])
    )
  end

  def deliver_retailer_update_email_instructions(
        %Retailer{} = retailer,
        current_email,
        update_email_url_fun
      )
      when is_function(update_email_url_fun, 1) do
    {encoded_token, retailer_token} =
      RetailerToken.build_email_token(retailer, "change:#{current_email}")

    Repo.insert!(retailer_token)

    RetailerNotifier.deliver_update_email_instructions(
      retailer,
      update_email_url_fun.(encoded_token)
    )
  end

  def change_retailer_password(retailer, attrs \\ %{}) do
    Retailer.password_changeset(retailer, attrs, hash_password: false)
  end

  def update_retailer_password(retailer, password, attrs) do
    changeset =
      retailer
      |> Retailer.password_changeset(attrs)
      |> Retailer.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:retailer, changeset)
    |> Ecto.Multi.delete_all(:tokens, RetailerToken.retailer_and_contexts_query(retailer, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{retailer: retailer}} -> {:ok, retailer}
      {:error, :retailer, changeset, _} -> {:error, changeset}
    end
  end

  def generate_retailer_session_token(retailer) do
    {token, retailer_token} = RetailerToken.build_session_token(retailer)
    Repo.insert!(retailer_token)
    token
  end

  def get_retailer_by_session_token(token) do
    {:ok, query} = RetailerToken.verify_session_token_query(token)
    Repo.one(query)
  end

  def delete_retailer_session_token(token) do
    Repo.delete_all(RetailerToken.token_and_context_query(token, "session"))
    :ok
  end

  def deliver_retailer_confirmation_instructions(%Retailer{} = retailer, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if retailer.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, retailer_token} = RetailerToken.build_email_token(retailer, "confirm")
      Repo.insert!(retailer_token)

      RetailerNotifier.deliver_confirmation_instructions(
        retailer,
        confirmation_url_fun.(encoded_token)
      )
    end
  end

  def confirm_retailer(token) do
    with {:ok, query} <- RetailerToken.verify_email_token_query(token, "confirm"),
         %Retailer{} = retailer <- Repo.one(query),
         {:ok, %{retailer: retailer}} <- Repo.transaction(confirm_retailer_multi(retailer)) do
      {:ok, retailer}
    else
      _ -> :error
    end
  end

  defp confirm_retailer_multi(retailer) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:retailer, Retailer.confirm_changeset(retailer))
    |> Ecto.Multi.delete_all(
      :tokens,
      RetailerToken.retailer_and_contexts_query(retailer, ["confirm"])
    )
  end

  def deliver_retailer_reset_password_instructions(%Retailer{} = retailer, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, retailer_token} = RetailerToken.build_email_token(retailer, "reset_password")
    Repo.insert!(retailer_token)

    RetailerNotifier.deliver_reset_password_instructions(
      retailer,
      reset_password_url_fun.(encoded_token)
    )
  end

  def get_retailer_by_reset_password_token(token) do
    with {:ok, query} <- RetailerToken.verify_email_token_query(token, "reset_password"),
         %Retailer{} = retailer <- Repo.one(query) do
      retailer
    else
      _ -> nil
    end
  end

  def reset_retailer_password(retailer, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:retailer, Retailer.password_changeset(retailer, attrs))
    |> Ecto.Multi.delete_all(:tokens, RetailerToken.retailer_and_contexts_query(retailer, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{retailer: retailer}} -> {:ok, retailer}
      {:error, :retailer, changeset, _} -> {:error, changeset}
    end
  end
end
