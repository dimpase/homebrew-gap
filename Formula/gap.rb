class Gap < Formula
  desc "System for computational discrete algebra"
  # homepage "https://www.gap-system.org/" - too slow for test-bot
  homepage "https://github.com/gap-system/gap"
  url "https://github.com/gap-system/gap/releases/download/v4.15.1/gap-4.15.1.tar.gz"
  sha256 "6049d53e99b12e25c2d848db21ac4a06380a46fe4c4157243d556fe06930042c"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/dimpase/homebrew-gap/releases/download/gap-4.15.1"
    rebuild 2
    sha256 arm64_tahoe:  "dd342780caaa84bdcdb98ab2109ba7d3d507d2e1691ab77c7880162ec3b55a13"
    sha256 x86_64_linux: "ae0bcefab424955f14c1bd29349723aa46244418d5a0ab6da84cdac614046769"
  end

  # most dependencies are for for packages; only gmp and readline are for GAP itself
  depends_on "cddlib"   # CddInterface
  depends_on "curl"     # curlInterface
  depends_on "flint"    # a 2nd order dep.
  depends_on "fplll"    # float
  depends_on "gmp"      # - for main GAP
  depends_on "libmpc"   # float
  depends_on "mpfi"     # float
  depends_on "mpfr"     # float, normalizinterface
  depends_on "nauty"    # grape
  depends_on "ncurses"  # browse
  depends_on "pari"     # alnuth
  # GAP cannot be built against the native macOS version of readline
  # it requires either GNU readline, or no readline at all; but
  # the latter leads to an inferior user experience.
  # So we depend on GNU readline here.
  depends_on "readline" # - for main GAP
  depends_on "singular" # many packages
  depends_on "zeromq"   # ZeroMQInterface
  depends_on "zlib-ng-compat" # a 2nd order dep.

  def install
    system "./configure", *std_configure_args
    system "make", "install"

    ohai "Building included packages. Please be patient, it may take a while"

    require "fileutils"
    mkdir_p "#{lib}/gap/"
    cp_r "pkg", "#{lib}/gap/pkg"

    cd lib/"gap/pkg" do
      # NOTE: This script will build most of the packages that require
      # compilation. It is known to produce a number of warnings and
      # error messages, possibly failing to build several packages.
      system buildpath/"bin/BuildPackages.sh", "--with-gaproot=#{lib}/gap"
      rm Dir.glob("#{lib}/gap/pkg/**/*.log")
      rm Dir.glob("#{lib}/gap/pkg/**/config.status")
      rm Dir.glob("#{lib}/gap/pkg/**/*.out")
      rm Dir.glob("#{lib}/gap/pkg/**/*.err") # semigroups fails to build on macOS 26
      rm Dir.glob("#{lib}/gap/pkg/**/Makefile")
      rm Dir.glob("#{lib}/gap/pkg/**/libtool")
    end
  end

  test do
    ENV["LC_CTYPE"] = "en_GB.UTF-8"
    system bin/"gap", "-r", "-A", "#{lib}/gap/pkg/alnuth/tst/testinstall.g"
  end
end
