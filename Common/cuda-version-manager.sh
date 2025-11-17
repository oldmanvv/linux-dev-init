# CUDA 版本管理工具（无 sudo，仅当前 shell 环境）
cvm() {
  local cuda_root_base="/usr/local"
  local cmd="$1"
  local version="$2"
  local default_file="${HOME}/.cuda_default"

  case "$cmd" in
    list)
      echo "🧭 Available CUDA versions:"
      ls -d ${cuda_root_base}/cuda-* 2>/dev/null | sed "s|${cuda_root_base}/cuda-||" | sort -V
      ;;
    use)
      if [[ -z "$version" ]]; then
        echo "Usage: cvm use <version>"
        echo "Example: cvm use 12.4"
        return 1
      fi

      local target_path="${cuda_root_base}/cuda-${version}"
      if [[ ! -d "$target_path" ]]; then
        echo "❌ CUDA version ${version} not found at ${target_path}"
        return 1
      fi

      # 清除旧 CUDA 路径
      export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v '/usr/local/cuda' | grep -v '/cuda-[0-9]' | paste -sd:)
      export LD_LIBRARY_PATH=$(echo "${LD_LIBRARY_PATH:-}" | tr ':' '\n' | grep -v '/usr/local/cuda' | grep -v '/cuda-[0-9]' | paste -sd:) 2>/dev/null || true

      # 设置新环境
      export CUDA_HOME="${target_path}"
      export PATH="${CUDA_HOME}/bin:${PATH}"
      if [[ -d "${CUDA_HOME}/lib64" ]]; then
        export LD_LIBRARY_PATH="${CUDA_HOME}/lib64:${LD_LIBRARY_PATH:-}"
      fi

      echo "✅ Switched to CUDA ${version}"
      nvcc --version 2>/dev/null | grep release || echo "⚠️ nvcc not found in PATH"
      ;;
    current)
      if [[ -n "$CUDA_HOME" ]]; then
        echo "🔹 Current CUDA: ${CUDA_HOME}"
        nvcc --version 2>/dev/null | grep release || echo "⚠️ nvcc not found in PATH"
      else
        echo "ℹ️ No CUDA version currently active"
      fi
      ;;
    default)
      if [[ -z "$version" ]]; then
        if [[ -f "$default_file" ]]; then
          echo "💾 Default CUDA version: $(cat "$default_file")"
        else
          echo "ℹ️ No default CUDA version set"
        fi
      else
        local target_path="${cuda_root_base}/cuda-${version}"
        if [[ ! -d "$target_path" ]]; then
          echo "❌ CUDA version ${version} not found at ${target_path}"
          return 1
        fi
        echo "$version" > "$default_file"
        echo "✅ Default CUDA version set to ${version}"
      fi
      ;;
    *)
      echo "Usage:"
      echo "  cvm list             # List available CUDA versions"
      echo "  cvm use <version>    # Switch to specified version"
      echo "  cvm current          # Show current CUDA version"
      echo "  cvm default <ver>    # Set default version"
      echo "  cvm default          # Show current default version"
      ;;
  esac
}

# 自动加载默认 CUDA 版本
if [[ -f "${HOME}/.cuda_default" ]]; then
  default_ver=$(cat "${HOME}/.cuda_default")
  cvm use "$default_ver" >/dev/null 2>&1 && echo "🎯 Loaded default CUDA ${default_ver}"
fi

alias nvitop="uvx nvitop"
alias glances="uvx glances"
