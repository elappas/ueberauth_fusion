# UeberauthFusion

Fusion OAuth2 strategy for Überauth.
The strategy developed based existing Strategies for Überauth.

## Installation

1. Setup fusion auth. More detail can be found in the [Fusion Auth documentation page][1]: 

1. Add `:ueberauth_fusion` to you list of dependencies in `mix.exs`
    ```elixir
    def deps do
      [
        {:ueberauth_fusion, "~> 0.9.0"}
      ]
    end
    ```

1. Add fusion to your Überauth configuration: 
    ```elixir
    config :ueberauth, Ueberauth,
      providers: [
        fusion: {Ueberauth.Strategy.Fusion, []},
      ]
    ```

1. Configure provider Strategy
    You have to configure client_id, client_secret, and fusion_url. The rest of the fields are build using the fusion_url field.
    ```elixir
    config :ueberauth, Ueberauth.Strategy.Fusion.OAuth,
      # Mandatory Fields
      client_id:      System.get_env("FUSION_APP_ID"),
      client_secret:  System.get_env("FUSION_APP_SECRET"),
      fusion_url:     System.get_env("FUSION_URL"),
      # Optional Fields - If not provided they build using fusion_url
      redirect_url:   System.get_env("FUSION_REDIRECT_URL"),
      sign_out_url:   System.get_env("FUSION_SIGNOUT_URL"),
      authorize_url:  System.get_env("FUSION_AUTH_URL")
      token_url:      System.get_env("FUSION_AUTH_TOKEN"),
      userinfo_url:   System.get_env("FUSION_USERINFO_URL"),
      jwk_set_url:    System.get_env("FUSION_JWK_URL"),
      token_method:   System.get_env("FUSION_TOKEN_METHOD")
    ```
1. When the user log out from the system, you have to redirect the user to fusion auth logout url. Otherwise, the session in fusion authentication system will remain active.
    ```elixir
      Ueberauth.Strategy.Fusion.logout(conn)
    ```

For an example implementation see the [Überauth Example][3] application.

## License

Please see [LICENSE][2] for licensing details.



[1]: https://fusionauth.io/docs/
[2]: https://github.com/elappas/ueberauth_fusion/blob/master/LICENSE
[3]: https://github.com/ueberauth/ueberauth_example
