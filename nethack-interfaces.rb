class NethackInterfaces < Formula
  desc "Single-player roguelike video game"
  homepage "http://www.nethack.org/index.html"
  version "3.6.0-chasonr.20160329"
  url "https://github.com/chasonr/nethack-3.6.0-patches.git", :branch => "interfaces"
  conflicts_with "nethack", :because => "both install `nethack` binaries"

  # Don't remove save folder
  skip_clean "libexec/save"

  depends_on "qt@4"
  depends_on "sdl2"
  depends_on "sdl2_image"
  depends_on "pkg-config" => :build

  # The hints files for lion and leopard are broken in this fork
  depends_on MinimumMacOSRequirement => :yosemite

  def install
    # Build everything in-order; no multi builds.
    ENV.deparallelize

    # Generate makefiles for OS X
    cd "sys/unix" do
      case
      when MacOS.version >= :yosemite
        hintfile = "macosx10.10"
      when MacOS.version >= :lion
        hintfile = "macosx10.7"
      when MacOS.version >= :leopard
        hintfile = "macosx10.5"
      else
        hintfile = "macosx"
      end

      inreplace "hints/#{hintfile}",
                /^HACKDIR=.*/,
                "HACKDIR=#{libexec}"

      inreplace "hints/#{hintfile}",
                /^#WANT_SDL2_FROM_HOMEBREW=.*/,
                "WANT_SDL2_FROM_HOMEBREW=1"

      system "sh", "setup.sh", "hints/#{hintfile}"
    end

    # Enable wizard mode for all users
    inreplace "sys/unix/sysconf",
      /^WIZARDS=.*/,
      "WIZARDS=*"

    # Make the game
    system "make", "install"
    bin.install "src/nethack"
    (libexec+"save").mkpath

    # Enable `man nethack`
    man6.install "doc/nethack.6"

    # These need to be group-writable in multi-user situations
    chmod "g+w", libexec
    chmod "g+w", libexec+"save"
  end

  test do
    system "#{bin}/nethack", "-s"
  end
end
