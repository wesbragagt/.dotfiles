let
  # Your SSH public key (from local machine)
  user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF4xsJwfA16E7aNlRCKwNWzPRNtPz5ZyKj5n+6LbWhsS";

  # VM SSH HOST KEY
  system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFWNii0RMkG5StDS+R6pue6T8rCRvSfcZIYKlAlO69cU";

  keys = [ user system ];
in
{
  # Define which secrets can be decrypted by which keys
  "test-secret.age".publicKeys = keys;

  # Example:
  # "password.age".publicKeys = [ user ];
  # "api-key.age".publicKeys = [ system ];
}
