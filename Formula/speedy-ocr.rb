class SpeedyOcr < Formula
  desc "Fast PDF OCR CLI tool powered by macOS Vision Framework"
  homepage "https://github.com/daiaoki/speedy-ocr"
  url "https://github.com/daiaoki/speedy-ocr/releases/download/#{version}/speedy-ocr-macos-universal.tar.gz"
  sha256 ""
  license "MIT"

  depends_on :macos
  depends_on macos: :ventura

  def install
    bin.install "speedy-ocr"
  end

  test do
    assert_match "speedy-ocr", shell_output("#{bin}/speedy-ocr --help")
  end
end
