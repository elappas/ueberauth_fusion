defmodule Ueberauth.Strategy.Fusion.OAuth do
  @moduledoc """
  OAuth2 for Fusion.

  Add `client_id`, `client_secret`, `fusion_url`, `redirect_url`, `tenant_id` to your configuration:
  Also you can configure: `authorize_url`, `userinfo_url`, `userinfo_url`, `jwk_set_url`, `sign_out_url`.
  If not configured, then the default values are build using `fusion_url`

  config :ueberauth, Ueberauth.Strategy.Fusion.OAuth,
    client_id: System.get_env("FUSION_APP_ID"),
    client_secret: System.get_env("FUSION_APP_SECRET")
    redirect_url: System.get_env("FUSION_REDIRECT_URL")
    fusion_url: System.get_env("FUSION_URL")
    tenant_id: System.get_env("TENANT_ID")
  """
  use OAuth2.Strategy

  require Logger

  #@defaults []
  defp defaults() do
    url = Application.get_env(:ueberauth, __MODULE__, []) |> Keyword.get(:fusion_url, "http://localhost:9011")
    [
      strategy: __MODULE__,
      site: url,
      authorize_url: to_string(url) <> "/oauth2/authorize",
      token_url: to_string(url) <> "/oauth2/token",
      userinfo_url: to_string(url) <> "/oauth2/userinfo",
      jwk_set_url: to_string(url) <> "/.well-known/jwks.json",
      sign_out_url: to_string(url) <> "/oauth2/logout",
      token_method: :post
    ]
  end

  defp construct_options(opts) do
    config = Application.get_env(:ueberauth, __MODULE__, [])
    _opts = defaults() |> Keyword.merge(opts) |> Keyword.merge(config) |> resolve_values()
  end

  @doc """
  returns the configuration for a specific value ssing the default urls and the overriden values
  """
  def get_config_value(value) do
    construct_options([]) |> Keyword.get(value)
  end

  @doc """
  Construct a client for requests to Fusion Auth.

  This will be setup automatically for you in `Ueberauth.Strategy.Fusion`.

  These options are only useful for usage outside the normal callback phase of Ueberauth.
  """
  def client(opts \\ []) do
    opts = construct_options(opts)
    json_library = Ueberauth.json_library()

    OAuth2.Client.new(opts)
    |> OAuth2.Client.put_serializer("application/json", json_library)
  end

  @doc """
  Provides the authorize url for the request phase of Ueberauth. No need to call this usually.
  """
  def authorize_url!(params \\ [], opts \\ []) do
    opts
    |> client
    |> OAuth2.Client.authorize_url!(params)
  end

  def get(token, url, headers \\ [], opts \\ []) do
    [token: token]
    |> client
    |> put_param("client_secret", client().client_secret)
    |> OAuth2.Client.get(url, headers, opts)
  end

  def get_access_token(params \\ [], opts \\ []) do
    case opts |> client |> OAuth2.Client.get_token(params) do
      {:error, %{body: %{"error" => error, "error_description" => description}}} ->
        {:error, {error, description}}
      {:ok, %{token: %{access_token: nil} = token}} ->
        %{"error" => error, "error_description" => description} = token.other_params
        {:error, {error, description}}
      {:ok, %{token: token}} ->
        {:ok, token}
    end
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_param("client_secret", client.client_secret)
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end


  @doc """
  returns the signout url based on the configuration files, sign_out_url and client_id
  """
  def signout_url(_params \\ %{}) do
    sign_out  = get_config_value(:sign_out_url)
    client_id = get_config_value(:client_id)
    tenant_id = get_config_value(:tenant_id)
    {:ok, "#{sign_out}?client_id=#{client_id}&tenant_id=#{tenant_id}"}
  end

  defp resolve_values(list) do
    for {key, value} <- list do
      {key, resolve_value(value)}
    end
  end

  defp resolve_value({m, f, a}) when is_atom(m) and is_atom(f), do: apply(m, f, a)
  defp resolve_value(v), do: v
end
