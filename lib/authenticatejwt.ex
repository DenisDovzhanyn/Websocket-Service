defmodule WebsocketConnections.AuthenticateJWT do
  def verify_token(token) do
    Auth.verify_and_validate(token)
  end
end
