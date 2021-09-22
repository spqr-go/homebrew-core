class Hledger < Formula
  desc "Easy plain text accounting with command-line, terminal and web UIs"
  homepage "https://hledger.org/"
  url "https://hackage.haskell.org/package/hledger-1.23/hledger-1.23.tar.gz"
  sha256 "0ba5dabfd50a8c1a4a5b53adb7c7a5ea542ea19534180b6fb9a69bfe7e5ced68"
  license "GPL-3.0-or-later"

  # A new version is sometimes present on Hackage before it's officially
  # released on the upstream homepage, so we check the first-party download
  # page instead.
  livecheck do
    url "https://hledger.org/download.html"
    regex(%r{href=.*?/tag/v?(\d+(?:\.\d+)+)["' >]}i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "f453eec32d2311151860a1cabdd8e962a0781b63eef0f455f2d6c67a88209ffc"
    sha256 cellar: :any_skip_relocation, big_sur:       "418a5f956bebb1aba9333f9db0616466a73a47859d768b3902746303839009ad"
    sha256 cellar: :any_skip_relocation, catalina:      "29143fe8be6b3638291fb2405e0fc7678fbc5f4ecf94682bdbe0dad4bd7e07c7"
    sha256 cellar: :any_skip_relocation, mojave:        "e246dc983fc9feb20e931ea7e597cf16ea9e6c078ebc4d3635842331a2821d7a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "619c7b4a8242618ae19ffeef6483243838b48b22d7c69ce9784477eb321d2ec2"
  end

  depends_on "ghc" => :build
  depends_on "haskell-stack" => :build

  uses_from_macos "ncurses"
  uses_from_macos "zlib"

  resource "hledger-lib" do
    url "https://hackage.haskell.org/package/hledger-lib-1.23/hledger-lib-1.23.tar.gz"
    sha256 "2c54ed631a23ef05531327b93d334d5303edf9831b598b71f60bab4b5c5257a0"
  end

  resource "hledger-ui" do
    url "https://hackage.haskell.org/package/hledger-ui-1.23/hledger-ui-1.23.tar.gz"
    sha256 "3a3bd1d91fe1145414be62c828a8510fbd6a0c26c4a0c115adb4ec4c25b89a13"
  end

  resource "hledger-web" do
    url "https://hackage.haskell.org/package/hledger-web-1.23/hledger-web-1.23.tar.gz"
    sha256 "9113f2c469bf9adbd086ffdafb4b63c801ed6a7b7b75d4b78b54b4416085f06a"
  end

  def install
    (buildpath/"../hledger-lib").install resource("hledger-lib")
    (buildpath/"../hledger-ui").install resource("hledger-ui")
    (buildpath/"../hledger-web").install resource("hledger-web")
    cd ".." do
      system "stack", "update"
      (buildpath/"../stack.yaml").write <<~EOS
        resolver: lts-17.5
        compiler: ghc-#{Formula["ghc"].version}
        compiler-check: newer-minor
        packages:
        - hledger-#{version}
        - hledger-lib
        - hledger-ui
        - hledger-web
      EOS
      system "stack", "install", "--system-ghc", "--no-install-ghc", "--skip-ghc-check", "--local-bin-path=#{bin}"

      man1.install Dir["hledger-*/*.1"]
      man5.install Dir["hledger-lib/*.5"]
      info.install Dir["hledger-*/*.info"]
    end
  end

  test do
    system "#{bin}/hledger", "test"
    system "#{bin}/hledger-ui", "--version"
    system "#{bin}/hledger-web", "--test"
  end
end
