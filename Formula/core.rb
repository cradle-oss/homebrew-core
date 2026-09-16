# Homebrew formula for CORE (staged locally; not yet submitted).
#
# Verified against the real codebase (v0.4.1):
#   - entry point:      pyproject [project.scripts] -> core = "core.cli:main"
#   - runtime deps:     click, rich, openai, pydantic, gitpython,
#                       beautifulsoup4, html2text (via `pip install .`)
#   - env vars:         ONLY the four that src/core/model/provider.py reads
#                       (CORE_MODEL, OPENROUTER_API_KEY, OPENAI_API_KEY,
#                       CORE_ZEN_API_KEY). No invented vars.
#   - invocation:       `core run "<task>"` (task is positional; there is
#                       no --task flag).
#   - version/license:  0.4.1 / MIT, matching pyproject.toml.
#
# BEFORE USE: cut the v0.4.1 GitHub Release, then replace
# RELEASE_SHA256_BELOW with:  shasum -a 256 <downloaded v0.4.1 tarball>
# Release v0.4.1 published 2026-09-16; SHA256 of the official tarball below.
#
# (Staged 2026-09-16 against release
#  https://github.com/cradle-oss/core/releases/tag/v0.4.1)

class Core < Formula
  desc "Terminal-native developer agent and code verification toolchain"
  homepage "https://github.com/cradle-oss/core"
  url "https://github.com/cradle-oss/core/archive/refs/tags/v0.4.1.tar.gz"
  sha256 "adbb3bcf5faabfb5246ebbaf94d610b1441d655ddab7ee803f050fd086add7b3"
  license "MIT"

  depends_on "python@3.11"
  depends_on "git"

  def install
    venv = libexec/"venv"
    system Formula["python@3.11"].opt_bin/"python3.11", "-m", "venv", venv
    system venv/"bin/pip", "install", "--upgrade", "pip"
    system venv/"bin/pip", "install", "."
    bin.install_symlink venv/"bin/core"

    # Config template with ONLY the env vars the code reads.
    # Provider precedence (src/core/model/provider.py):
    #   explicit --model / CORE_MODEL -> OPENROUTER_API_KEY -> zen route ->
    #   OPENAI_API_KEY.
    (pkgshare/"env.example").write <<~EOS
      # Optional: pin a model (openrouter/* -> OpenRouter, else direct OpenAI).
      # export CORE_MODEL=

      # Recommended: OpenRouter adaptive routing (tool calling supported).
      # export OPENROUTER_API_KEY=

      # OpenCode Zen free route (bare tool-capable model ids).
      # export CORE_ZEN_API_KEY=

      # Direct OpenAI (used when no OpenRouter key is set).
      # export OPENAI_API_KEY=
    EOS
  end

  def post_install
    ohai "CORE installed. Configure one provider key, then run:"
    puts "  export OPENROUTER_API_KEY=<key>   # or CORE_ZEN_API_KEY / OPENAI_API_KEY"
    puts "  core run \"inspect this repository\""
    puts "Template: #{pkgshare}/env.example   Version: #{version}"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/core --version")
  end
end
