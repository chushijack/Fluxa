cask "fluxa" do
  version "VERSION"
  sha256 arm: "ARM_SHA256",
         intel: "AMD_SHA256"

  on_arm do
    arch = "arm64"
  end
  on_intel do
    arch = "amd64"
  end

  url "https://github.com/chushijack/Fluxa/releases/download/v#{version}/Fluxa-#{version}-macos-#{arch}.dmg"
  name "Fluxa"
  desc "Cross-platform proxy client (fork of FlClash)"
  homepage "https://github.com/chushijack/Fluxa"

  livecheck do
    url :homepage
    strategy :github_latest
  end

  app "Fluxa.app"

  postflight do
    system_command "/usr/bin/xattr",
        args:           ["-rd", "com.apple.quarantine", "{{appdir}}/Fluxa.app"],
        writable_paths: ["Fluxa.app"],
        must_succeed:   false
  end
end
