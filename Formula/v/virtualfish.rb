class Virtualfish < Formula
  include Language::Python::Virtualenv

  desc "Python virtual environment manager for the fish shell"
  homepage "https://virtualfish.readthedocs.io/en/latest/"
  url "https://files.pythonhosted.org/packages/54/2f/a7800ae09a689843b62b3eb423d01a90175be5795b66ac675f6f45349ca9/virtualfish-2.5.5.tar.gz"
  sha256 "6b654995f151af8fca62646d49a62b5bf646514250f1461df6d42147995a0db2"
  license "MIT"
  head "https://github.com/justinmayer/virtualfish.git", branch: "main"

  bottle do
    rebuild 3
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "1f247a3d61821e4b5b0cc1ede4f39c4c698037a6490816229a9a770b341fc902"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "f86626ae92fe1c934fe678be8fd4fb5835c8696e8bc4a56d5be413fe8418e806"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "d95595eca51362b908d0a2d2f51c4fd14df93bc1520000e84a7fece52badd769"
    sha256 cellar: :any_skip_relocation, sonoma:         "51af3c2433d0d84776e468f95179695a0b1dd9d10530b53892ed5237b1a5769b"
    sha256 cellar: :any_skip_relocation, ventura:        "4b7198e35a518a0f45eb70a04429deddd63e5281246283ba0d4a7dcdb29cc1f3"
    sha256 cellar: :any_skip_relocation, monterey:       "7f569f4c0a255980b8245b59204ac037e3bae382b387dbfeddb11c8152f715be"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "d02d694ebc0f8363cb640d3493f18a44b23c2399110db2db09c8111070e34028"
  end

  depends_on "fish"
  depends_on "python@3.12"

  resource "distlib" do
    url "https://files.pythonhosted.org/packages/c4/91/e2df406fb4efacdf46871c25cde65d3c6ee5e173b7e5a4547a47bae91920/distlib-0.3.8.tar.gz"
    sha256 "1530ea13e350031b6312d8580ddb6b27a104275a31106523b8f123787f494f64"
  end

  resource "filelock" do
    url "https://files.pythonhosted.org/packages/70/70/41905c80dcfe71b22fb06827b8eae65781783d4a14194bce79d16a013263/filelock-3.13.1.tar.gz"
    sha256 "521f5f56c50f8426f5e03ad3b281b490a87ef15bc6c526f168290f0c7148d44e"
  end

  resource "packaging" do
    url "https://files.pythonhosted.org/packages/fb/2b/9b9c33ffed44ee921d0967086d653047286054117d584f1b1a7c22ceaf7b/packaging-23.2.tar.gz"
    sha256 "048fb0e9405036518eaaf48a55953c750c11e1a1b68e0dd1a9d62ed0c092cfc5"
  end

  resource "pkgconfig" do
    url "https://files.pythonhosted.org/packages/c4/e0/e05fee8b5425db6f83237128742e7e5ef26219b687ab8f0d41ed0422125e/pkgconfig-1.5.5.tar.gz"
    sha256 "deb4163ef11f75b520d822d9505c1f462761b4309b1bb713d08689759ea8b899"
  end

  resource "platformdirs" do
    url "https://files.pythonhosted.org/packages/96/dc/c1d911bf5bb0fdc58cc05010e9f3efe3b67970cef779ba7fbc3183b987a8/platformdirs-4.2.0.tar.gz"
    sha256 "ef0cc731df711022c174543cb70a9b5bd22e5a9337c8624ef2c2ceb8ddad8768"
  end

  resource "psutil" do
    url "https://files.pythonhosted.org/packages/90/c7/6dc0a455d111f68ee43f27793971cf03fe29b6ef972042549db29eec39a2/psutil-5.9.8.tar.gz"
    sha256 "6be126e3225486dff286a8fb9a06246a5253f4c7c53b475ea5f5ac934e64194c"
  end

  # setuptools included due to https://github.com/justinmayer/virtualfish/issues/240
  resource "setuptools" do
    url "https://files.pythonhosted.org/packages/c9/3d/74c56f1c9efd7353807f8f5fa22adccdba99dc72f34311c30a69627a0fad/setuptools-69.1.0.tar.gz"
    sha256 "850894c4195f09c4ed30dba56213bf7c3f21d86ed6bdaafb5df5972593bfc401"
  end

  resource "virtualenv" do
    url "https://files.pythonhosted.org/packages/94/d7/adb787076e65dc99ef057e0118e25becf80dd05233ef4c86f07aa35f6492/virtualenv-20.25.0.tar.gz"
    sha256 "bf51c0d9c7dd63ea8e44086fa1e4fb1093a31e963b86959257378aef020e1f1b"
  end

  def install
    virtualenv_install_with_resources

    site_packages = Language::Python.site_packages("python3.12")
    paths = %w[virtualenv].map { |p| Formula[p].opt_libexec/site_packages }
    (libexec/site_packages/"homebrew-deps.pth").write paths.join("\n")
  end

  def caveats
    <<~EOS
      To activate virtualfish, run the following in a fish shell:
        vf install
    EOS
  end

  test do
    # Pre-create .virtualenvs to avoid interactive prompt
    (testpath/".virtualenvs").mkpath

    # Run `vf install` in the test environment, adds vf as function
    refute_path_exists testpath/".config/fish/conf.d/virtualfish-loader.fish"
    assert_match "VirtualFish is now installed!", shell_output("fish -c '#{bin}/vf install'")
    assert_path_exists testpath/".config/fish/conf.d/virtualfish-loader.fish"

    # Add virtualenv to prompt so virtualfish doesn't link to prompt doc
    (testpath/".config/fish/functions/fish_prompt.fish").write(<<~EOS)
      function fish_prompt --description 'Test prompt for virtualfish'
        echo -n -s (pwd) 'VIRTUAL_ENV=' (basename "$VIRTUAL_ENV") '>'
      end
    EOS

    # Create a virtualenv 'new_virtualenv'
    refute_path_exists testpath/".virtualenvs/new_virtualenv/pyvenv.cfg"
    system "fish", "-c", "vf new new_virtualenv"
    assert_path_exists testpath/".virtualenvs/new_virtualenv/pyvenv.cfg"

    # The virtualenv is listed
    assert_match "new_virtualenv", shell_output('fish -c "vf ls"')

    # Delete the virtualenv
    system "fish", "-c", "vf rm new_virtualenv"
    refute_path_exists testpath/".virtualenvs/new_virtualenv/pyvenv.cfg"
  end
end
