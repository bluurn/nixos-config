{ pkgs, ... }:

let
  applyPilotVersion = "0.3.0";

  applyPilotInstall = pkgs.writeShellApplication {
    name = "applypilot-install";

    runtimeInputs = with pkgs; [
      coreutils
      python312
      uv
    ];

    text = ''
      set -euo pipefail

      data_home="''${XDG_DATA_HOME:-$HOME/.local/share}"
      install_dir="$data_home/applypilot"
      venv="$install_dir/venv"

      mkdir -p "$install_dir"

      echo "Creating ApplyPilot ${applyPilotVersion} environment..."
      uv venv --clear --python "${pkgs.python312}/bin/python" "$venv"

      uv pip install \
        --python "$venv/bin/python" \
        "applypilot==${applyPilotVersion}" \
        numpy \
        pandas \
        pydantic \
        tls-client \
        requests \
        markdownify \
        regex

      uv pip install \
        --python "$venv/bin/python" \
        --no-deps \
        python-jobspy

      printf '%s\n' "${applyPilotVersion}" >"$install_dir/version"

      echo
      echo "ApplyPilot ${applyPilotVersion} installed in $venv"
      echo "Next: applypilot init"
    '';
  };

  applyPilot = pkgs.writeShellApplication {
    name = "applypilot";

    runtimeInputs = with pkgs; [
      claude-code
      chromium
      coreutils
      nodejs
    ];

    text = ''
      set -euo pipefail

      data_home="''${XDG_DATA_HOME:-$HOME/.local/share}"
      install_dir="$data_home/applypilot"
      executable="$install_dir/venv/bin/applypilot"
      installed_version=""

      if [ -f "$install_dir/version" ]; then
        installed_version="$(cat "$install_dir/version")"
      fi

      if [ ! -x "$executable" ] || [ "$installed_version" != "${applyPilotVersion}" ]; then
        echo "ApplyPilot ${applyPilotVersion} is not installed." >&2
        echo "Run: applypilot-install" >&2
        exit 1
      fi

      export CHROME_PATH="${pkgs.chromium}/bin/chromium"
      export PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH="${pkgs.chromium}/bin/chromium"

      exec "$executable" "$@"
    '';
  };
in
{
  home.packages = [
    applyPilot
    applyPilotInstall
  ];
}
