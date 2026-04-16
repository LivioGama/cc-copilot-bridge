class CcCopilotBridge < Formula
  desc "Multi-provider switcher for Claude Code CLI"
  homepage "https://github.com/FlorianBruniaux/cc-copilot-bridge"
  url "https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/download/v1.8.0/cc-copilot-bridge-1.8.0.tar.gz"
  sha256 "8c89eb20a227f9bddb149a0774d4bc6282cad6e748111f53257f1916f3b6eadb" # TODO: regenerate for v1.8.0 release tarball
  license "MIT"
  version "1.8.0"

  depends_on "netcat"

  # Optional dependencies
  depends_on "ollama" => :optional
  depends_on "node" => :optional  # For copilot-api

  def install
    bin.install "claude-switch"

    # Create log directory
    (var/"log/claude-switch").mkpath

    # Install docs
    doc.install "README.md" if File.exist?("README.md")
    doc.install "QUICKSTART.md" if File.exist?("QUICKSTART.md")
    doc.install Dir["docs/*"] if Dir.exist?("docs")
  end

  def caveats
    <<~EOS
      To enable shell aliases, add to your ~/.zshrc or ~/.bashrc:

        eval "$(claude-switch --shell-config)"

      Or test it first:

        source <(claude-switch --shell-config)

      For more integration options:
        https://github.com/FlorianBruniaux/cc-copilot-bridge/blob/main/docs/INSTALL-OPTIONS.md

      For JetBrains Junie: npx junie-api auth && npx junie-api start --port 4142

      Logs are stored in:
        #{var}/log/claude-switch/claude-switch.log
    EOS
  end

  test do
    assert_match(/claude-switch v\d+\.\d+/, shell_output("#{bin}/claude-switch --version"))
    assert_match "alias ccd=", shell_output("#{bin}/claude-switch --shell-config")
  end
end
