defmodule Triceratops.Modules.Crypto do

  @moduledoc "Module for dealing with encrypting and decrypting files."

  require Logger

  # -c, --symmetric = Encryption only with symmetric cipher
  # echo -n "qwerty" | gpg --batch --no-tty --yes --passphrase-fd 0 -c --cipher-algo aes256 -o "#{output}" "#{input}"

  # Decrypt data
  # echo -n "qwerty" | gpg --batch --no-tty --yes --passphrase-fd 0 -d -o #{output} #{input}

  # echo -n "qwerty" | openssl enc -pass pass:stdin -aes-256-cbc -in "#{input}" -out "#{output}"

  # Decrypt data
  # echo -n "qwerty" | openssl enc -d -pass pass:stdin -aes-256-cbc -in "#{input}" -out "#{output}"

end
