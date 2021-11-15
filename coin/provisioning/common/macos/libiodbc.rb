class Libiodbc < Formula
  desc "Database connectivity layer based on ODBC. (alternative to unixodbc)"
  homepage "http://www.iodbc.org/dataspace/iodbc/wiki/iODBC/"
  url "https://github.com/openlink/iODBC/archive/v3.52.15.tar.gz"
  sha256 "f6b376b6dffb4807343d6d612ed527089f99869ed91bab0bbbb47fdea5ed6ace"

  option "with-universal", "Build as universal binary"

  if build.with? "universal"
    version "3.52.15-universal"
    env :std
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  conflicts_with "unixodbc", :because => "both install 'odbcinst.h' header"

  def install
    if build.with? "universal"
      ENV['CFLAGS'] = '-O -arch arm64 -arch x86_64 -mmacosx-version-min=10.9'
    end
    system "./autogen.sh"
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system bin/"iodbc-config", "--version"
  end
end

