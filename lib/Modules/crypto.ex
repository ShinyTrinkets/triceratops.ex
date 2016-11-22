defmodule Triceratops.Modules.Crypto do

  @moduledoc "Module for dealing with encrypting and decrypting files."

  require Logger

  # c, --symmetric = Encryption only with symmetric cipher
  # echo "qwerty" | gpg --batch --no-tty --yes --passphrase-fd 0 -c --cipher-algo aes256 -o #{output} #{input}

  # Decrypt data
  # echo "qwerty" | gpg --batch --no-tty --yes --passphrase-fd 0 -d -o #{output} #{input}

end
