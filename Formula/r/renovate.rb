class Renovate < Formula
  desc "Automated dependency updates. Flexible so you don't need to be"
  homepage "https://github.com/renovatebot/renovate"
  url "https://registry.npmjs.org/renovate/-/renovate-38.44.0.tgz"
  sha256 "d4194332309693bb0bd30984ba947304826b5975abb893ab3cf812d5e39e2a03"
  license "AGPL-3.0-only"

  # There are thousands of renovate releases on npm and the page the `Npm`
  # strategy checks is several MB in size and can time out before the request
  # resolves. This checks the first page of tags on GitHub (to minimize data
  # transfer).
  livecheck do
    url "https://github.com/renovatebot/renovate/tags"
    regex(%r{href=["']?[^"' >]*?/tag/v?(\d+(?:\.\d+)+)["' >]}i)
    strategy :page_match
    throttle 10
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "20fbb979d0d916b8525f9782e3393bc2fc10a3fc3752147fdcd047263c24af2e"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "07e5930479af2c3d86998ebefffe4fbbebdeaa4879bdfac483cbc0ed14fcf862"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "a4b19f69d28184a9256a224e7634c912b1d58f4f9163931f43580f992f84befc"
    sha256 cellar: :any_skip_relocation, sonoma:         "1ffb6246727655afef85db7409d3bf32d2c21a1079eb76336d53ed548eb8438e"
    sha256 cellar: :any_skip_relocation, ventura:        "90e43dfbd9e7f0b5e19544d8ec074ea30198d4cc3cbe929057148a7fdd6fcd54"
    sha256 cellar: :any_skip_relocation, monterey:       "9e0f14aa02ab45d2949a2f5deb30db3636902b1bd5557f37d09f8916c5c7ede6"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "4eb9db788810bffcf19589f09940bf8ae79a5ea1eeaab61f30c2fbb26f5ea2c9"
  end

  depends_on "node"

  uses_from_macos "git", since: :monterey

  def install
    system "npm", "install", *std_npm_args
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    assert_match "FATAL: You must configure a GitHub token", shell_output("#{bin}/renovate 2>&1", 1)
  end
end
