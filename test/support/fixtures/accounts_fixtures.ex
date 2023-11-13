# FIXME: replace with factory
defmodule Market.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Market.Accounts` context.
  """

  ### Vendor
  def unique_vendor_email, do: "vendor#{System.unique_integer()}@example.com"
  def valid_vendor_password, do: "hello world!"

  def valid_vendor_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_vendor_email(),
      password: valid_vendor_password()
    })
  end

  def vendor_fixture(attrs \\ %{}) do
    {:ok, vendor} =
      attrs
      |> valid_vendor_attributes()
      |> Market.Accounts.register_vendor()

    vendor
  end

  def extract_vendor_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  # Retailer
  def unique_retailer_email, do: "retailer#{System.unique_integer()}@example.com"
  def valid_retailer_password, do: "hello world!"

  def valid_retailer_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_retailer_email(),
      password: valid_retailer_password()
    })
  end

  def retailer_fixture(attrs \\ %{}) do
    {:ok, retailer} =
      attrs
      |> valid_retailer_attributes()
      |> Market.Accounts.register_retailer()

    retailer
  end

  def extract_retailer_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
