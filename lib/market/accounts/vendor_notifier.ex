defmodule Market.Accounts.VendorNotifier do
  import Swoosh.Email

  alias Market.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Market", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(vendor, url) do
    deliver(vendor.email, "Confirmation instructions", """

    ==============================

    Hi #{vendor.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a vendor password.
  """
  def deliver_reset_password_instructions(vendor, url) do
    deliver(vendor.email, "Reset password instructions", """

    ==============================

    Hi #{vendor.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a vendor email.
  """
  def deliver_update_email_instructions(vendor, url) do
    deliver(vendor.email, "Update email instructions", """

    ==============================

    Hi #{vendor.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end
end
