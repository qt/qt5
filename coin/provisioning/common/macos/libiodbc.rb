class Libiodbc < Formula
  desc "Database connectivity layer based on ODBC. (alternative to unixodbc)"
  homepage "http://www.iodbc.org/dataspace/iodbc/wiki/iODBC/"
  url "https://github.com/openlink/iODBC/archive/v3.52.12.tar.gz"
  sha256 "b2cab4f8fbd5388344d7ee0deb1a32310795b1e631c3505a5b515d90186e2516"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build

  conflicts_with "unixodbc", :because => "both install 'odbcinst.h' header"

  def install
    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system bin/"iodbc-config", "--version"
  end
end

