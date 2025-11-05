#!/bin/bash

# Function to install CUDA Toolkit for a specific version
install_cuda() {
    local cuda_version=$1
    
    # Extract major and minor version numbers (e.g., 13.0 from 13.0.2)
    local major_minor_version=$(echo "$cuda_version" | cut -d'.' -f1-2)
    # Replace dots with hyphens for the package naming (e.g., 13-0 from 13.0)
    local package_version=$(echo "$major_minor_version" | sed 's/\./-/g')
    
    echo "Installing CUDA Toolkit $cuda_version for WSL..."
    
    # Download and set up the repository
    wget https://developer.download.nvidia.com/compute/cuda/repos/wsl-ubuntu/x86_64/cuda-wsl-ubuntu.pin
    sudo mv cuda-wsl-ubuntu.pin /etc/apt/preferences.d/cuda-repository-pin-600
    
    # Download the appropriate .deb package for the specified version
    wget "https://developer.download.nvidia.com/compute/cuda/$cuda_version/local_installers/cuda-repo-wsl-ubuntu-$package_version-local_$cuda_version-1_amd64.deb"
    
    # Run dpkg and capture its output to extract the GPG key filename
    dpkg_output=$(sudo dpkg -i "cuda-repo-wsl-ubuntu-$package_version-local_$cuda_version-1_amd64.deb" 2>&1)
    echo "$dpkg_output"
    
    # Extract the GPG key filename from the dpkg output
    # Look for the pattern "cuda-XXXX-keyring.gpg" in the output
    gpg_key=$(echo "$dpkg_output" | grep -oE 'cuda-[A-Z0-9a-z-]*-keyring\.gpg' | head -n 1)
    
    if [ -z "$gpg_key" ]; then
        # If we can't extract the key from output, try to find it in the standard location
        gpg_key=$(ls /var/cuda-repo-wsl-ubuntu-$package_version-local/cuda-*-keyring.gpg 2>/dev/null | head -n 1 | xargs basename)
    fi
    
    # Install the GPG key using the extracted filename
    if [ -n "$gpg_key" ]; then
        sudo cp "/var/cuda-repo-wsl-ubuntu-$package_version-local/$gpg_key" /usr/share/keyrings/
    else
        echo "Warning: Could not find GPG key file"
        exit 1
    fi
    
    # Update package list and install CUDA toolkit
    sudo apt-get update
    sudo apt-get -y install "cuda-toolkit-$package_version"
    
    echo "Successfully installed CUDA Toolkit $cuda_version"
}

# Check if a CUDA version was provided as an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <cuda_version>"
    echo "Example: $0 13.0.2"
    exit 1
fi

# Install CUDA with the provided version
install_cuda "$1"