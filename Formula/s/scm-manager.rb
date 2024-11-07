class ScmManager < Formula
  desc "Manage Git, Mercurial, and Subversion repos over HTTP"
  homepage "https://www.scm-manager.org"
  url "https://packages.scm-manager.org/repository/releases/sonia/scm/packaging/unix/3.3.0/unix-3.3.0.tar.gz"
  sha256 "cf3fd465c385779a3a66b1655dfc81eda53a5474937a41d5eb00a4d7cab8c218"
  license all_of: ["Apache-2.0", "MIT"]

  livecheck do
    url "https://scm-manager.org/download/"
    regex(/href=.*?unix[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "6f6cbf22743a06d4915cf4a44515d1eb3c2c215b7b497cc04568a64b537194fd"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "6f6cbf22743a06d4915cf4a44515d1eb3c2c215b7b497cc04568a64b537194fd"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "6f6cbf22743a06d4915cf4a44515d1eb3c2c215b7b497cc04568a64b537194fd"
    sha256 cellar: :any_skip_relocation, sonoma:         "6f6cbf22743a06d4915cf4a44515d1eb3c2c215b7b497cc04568a64b537194fd"
    sha256 cellar: :any_skip_relocation, ventura:        "6f6cbf22743a06d4915cf4a44515d1eb3c2c215b7b497cc04568a64b537194fd"
    sha256 cellar: :any_skip_relocation, monterey:       "6f6cbf22743a06d4915cf4a44515d1eb3c2c215b7b497cc04568a64b537194fd"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "d175118e0f442074bd8e03240835982987b238fba8d02b944e38e141431e65bc"
  end

  depends_on "jsvc"
  depends_on "openjdk@21"

  def install
    # Replace pre-built `jsvc` with formula to add Apple Silicon support
    inreplace "bin/scm-server", %r{ \$BASEDIR/libexec/jsvc-.*"}, " #{Formula["jsvc"].opt_bin}/jsvc\""
    rm Dir["libexec/jsvc-*"]
    libexec.install Dir["*"]

    env = Language::Java.overridable_java_home_env("21")
    env["BASEDIR"] = libexec
    env["REPO"] = libexec/"lib"
    (bin/"scm-server").write_env_script libexec/"bin/scm-server", env
  end

  service do
    run [opt_bin/"scm-server"]
  end

  test do
    port = free_port

    cp libexec/"conf/config.yml", testpath
    inreplace testpath/"config.yml" do |s|
      s.gsub! "./work", testpath/"work"
      s.gsub! "port: 8080", "port: #{port}"
    end
    ENV["JETTY_BASE"] = testpath
    pid = fork { exec bin/"scm-server" }
    sleep 15
    assert_match "<title>SCM-Manager</title>", shell_output("curl http://localhost:#{port}/scm/")
  ensure
    Process.kill "TERM", pid
  end
end
