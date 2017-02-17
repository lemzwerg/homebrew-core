class Ucon64 < Formula
  desc "ROM backup tool and emulator's Swiss Army knife program"
  homepage "https://ucon64.sourceforge.io/"
  url "https://downloads.sourceforge.net/ucon64/ucon64-2.0.2-src.tar.gz"
  sha256 "2df3972a68d1d7237dfedb99803048a370b466a015a5e4c1343f7e108601d4c9"
  head ":pserver:anonymous:@ucon64.cvs.sourceforge.net:/cvsroot/ucon64", :using => :cvs

  bottle do
    sha256 "ebea93e0d5d70ac09e0e0dd633fe5cb0c6a9cf7807ed269d90e985d03f1e0ea9" => :sierra
    sha256 "c967e556e861fc8c7237473d5a672da27064d1e4f92d965cfded55686e776b59" => :el_capitan
    sha256 "6931f246836b4d75c8027b4447f88544f8c5b24683bcb2e7d8260efb3e35598c" => :yosemite
  end

  resource "super_bat_puncher_demo" do
    url "http://morphcat.de/superbatpuncher/Super%20Bat%20Puncher%20Demo.zip"
    sha256 "d74cb3ba11a4ef5d0f8d224325958ca1203b0d8bb4a7a79867e412d987f0b846"
  end

  def install
    # ucon64's normal install process installs the discmage library in
    # the user's home folder. We want to store it inside the prefix, so
    # we have to change the default value of ~/.ucon64rc to point to it.
    # .ucon64rc is generated by the binary, so we adjust the default that
    # is set when no .ucon64rc exists.
    inreplace "src/ucon64_misc.c", 'PROPERTY_MODE_DIR ("ucon64") "discmage.dylib"',
                                   "\"#{opt_prefix}/libexec/libdiscmage.dylib\""

    cd "src" do
      system "./configure", "--disable-debug",
                            "--disable-dependency-tracking",
                            "--disable-silent-rules",
                            "--prefix=#{prefix}"
      system "make"
      bin.install "ucon64"
      libexec.install "libdiscmage/discmage.so" => "libdiscmage.dylib"
    end
  end

  def caveats; <<-EOS.undent
      You can copy/move your DAT file collection to $HOME/.ucon64/dat
      Be sure to check $HOME/.ucon64rc for configuration after running uCON64
      for the first time.
    EOS
  end

  test do
    resource("super_bat_puncher_demo").stage testpath

    assert_match "00000000  4e 45 53 1a  08 00 11 00  00 00 00 00  00 00 00 00",
                 shell_output("#{bin}/ucon64 \"#{testpath}/Super Bat Puncher Demo.nes\"")
  end
end
