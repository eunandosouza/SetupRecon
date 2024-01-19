#!/bin/bash

# Função para exibir banners
banner() {
  echo -e "\\033[0;34m----------------------------------------\\033[0m"
  echo -e "\\033[1;32m$1\\033[0m"
  echo -e "\\033[0;34m----------------------------------------\\033[0m"
}

# Função para instalar dependências
install_dependencies() {
  local packages=("$@")
  for package in "${packages[@]}"; do
    banner "Instalando $package"
    if sudo apt-get install -y "$package"; then
      echo "$package instalado com sucesso." >> install.log
    else
      echo "Erro ao instalar $package." >> install.log
    fi
  done
}

# Atualizando o sistema
banner "Atualizando o sistema"
if sudo apt-get update -y; then
  echo "Sistema atualizado com sucesso." >> install.log
else
  echo "Erro ao atualizar o sistema." >> install.log
fi

# Instalando Dependências
dependencies=("unzip" "curl" "ca-certificates" "gnupg" "python3" "python3-pip")
install_dependencies "${dependencies[@]}"

# Instalando o Go
# Instalando o Go
banner "Instalando o Go"
GO_VERSION="1.21.6  # atualize isso para a versão desejada do Go
GO_OS="linux"
GO_ARCH="amd64"
GO_FILE="go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz"
GO_URL="https://golang.org/dl/${GO_FILE}"
if curl -LO "${GO_URL}" && sudo tar -C /usr/local -xzf "${GO_FILE}"; then
  echo "Go instalado com sucesso." >> install.log
  echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
  source ~/.bashrc
  go version
else
  echo "Erro ao instalar Go." >> install.log
fi


# Instalando o Docker
banner "Instalando o Docker"
if curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg; then
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  if sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; then
    echo "Docker instalado com sucesso." >> install.log
  else
    echo "Erro ao instalar Docker." >> install.log
  fi
else
  echo "Erro ao adicionar a chave GPG do Docker." >> install.log
fi

# Instalando as ferramentas
banner "Instalando as ferramentas"
tools=(
  "github.com/projectdiscovery/httpx/cmd/httpx@latest"
  "github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
  "github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
  "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
  "github.com/tomnomnom/assetfinder@latest"
  "github.com/tomnomnom/meg@latest"
  "github.com/tomnomnom/anew@latest"
  "github.com/tomnomnom/waybackurls@latest"
  "github.com/tomnomnom/qsreplace@latest"
  "github.com/hakluke/hakcheckurl@latest"
  "github.com/hakluke/hakrawler@latest"
  "github.com/ferreiraklet/nilo@latest"
  "github.com/ferreiraklet/airixss@latest"
  "github.com/takshal/freq@latest"
  "github.com/bp0lr/gauplus@latest"
  "github.com/ThreatUnkown/jsubfinder@latest"
  "github.com/j3ssie/sdlookup@latest"
  "github.com/hueristiq/xurlfind3r/cmd/xurlfind3r@latest"
  "github.com/lc/subjs@latest"
  "github.com/deletescape/goop@latest"
  "github.com/d3mondev/puredns/v2@latest"
)

for tool in "${tools[@]}"; do
  if go install "$tool"; then
    echo "$tool instalado com sucesso." >> install.log
  else
    echo "Erro ao instalar $tool." >> install.log
  fi
done

if pip3 install uro; then
  echo "uro instalado com sucesso." >> install.log
else
  echo "Erro ao instalar uro." >> install.log
fi

if sudo snap install amass; then
  echo "amass instalado com sucesso." >> install.log
else
  echo "Erro ao instalar amass." >> install.log
fi

# Clonando e instalando outros repositórios
repos=(
  "https://github.com/vortexau/dnsvalidator"
  "https://github.com/guelfoweb/knock.git"
  "https://github.com/0x240x23elu/JSScanner.git"
  "https://github.com/s0md3v/Photon.git"
  "https://github.com/blechschmidt/massdns.git"
)

for repo in "${repos[@]}"; do
  repo_dir=$(basename "$repo" .git)
  if git clone "$repo"; then
    cd "$repo_dir"
    if [[ -f "setup.py" ]]; then
      if python3 setup.py install; then
        echo "$repo instalado com sucesso." >> install.log
      else
        echo "Erro ao instalar $repo." >> install.log
      fi
    elif [[ -f "requirements.txt" ]]; then
      if pip3 install -r requirements.txt; then
        echo "$repo instalado com sucesso." >> install.log
      else
        echo "Erro ao instalar $repo." >> install.log
      fi
    elif [[ -f "Makefile" ]]; then
      if make && sudo make install; then
        echo "$repo instalado com sucesso." >> install.log
      else
        echo "Erro ao instalar $repo." >> install.log
      fi
    fi
    cd ..
  else
    echo "Erro ao clonar $repo." >> install.log
  fi
done

# Baixando e instalando Findomain
if curl -LO https://github.com/findomain/findomain/releases/latest/download/findomain-linux.zip; then
  if unzip -o findomain-linux.zip; then
    chmod +x findomain
    if sudo mv findomain /usr/bin/findomain; then
      echo "Findomain instalado com sucesso." >> install.log
    else
      echo "Erro ao mover findomain para /usr/bin." >> install.log
    fi
  else
    echo "Erro ao descompactar findomain-linux.zip." >> install.log
  fi
else
  echo "Erro ao baixar findomain-linux.zip." >> install.log
fi

# Movendo as ferramentas Go para /usr/bin
if sudo mv ~/go/bin/* /usr/bin; then
  echo "Ferramentas Go movidas para /usr/bin com sucesso." >> install.log
else
  echo "Erro ao mover as ferramentas Go para /usr/bin." >> install.log
fi

# Limpeza
rm -rf ~/go
rm findomain-linux.zip
