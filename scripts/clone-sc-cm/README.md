## get_sct_cm.sh

### O que faz ?

Cria uma estrutura de pastas baseada no arquivo de namespaces passado para o script onde cada namespace terá sua pasta própria e também poderá ter uma pasta de secrets e configmaps (caso exista algum dos dois nesse namespace).

### Como usar ?

1. Crie um arquivo de texto simples com os namespace que deseja pegar as secrets e configmaps, onde cada linha do arquivo contém exatamente um namespace.

2. Execute o script passando o caminho para o arquivo de namespaces como primeiro parâmetro

### Exemplo de uso

> Estrutura do arquivo com namespaces:
```
<namespace_origem_1>
<namespace_origem_2>
.
.
.
<namespace_origem_x>
```

> Como executar o script:
```bash
./get_sct_cm.sh <arquivo_com_namespaces>
```

---


## apply_sct_cm.sh

### O que faz?

Utiliza a estrutura criada pelo script `get_sct_cm.sh` e um arquivo de namespaces para aplicar as secrets e configmaps.

### Como usar ?

1. Crie um arquivo de texto simples que contém os namespaces de origem e destino dos artefatos, cada linha desse arquivo deve ter apenas `<namespace_origem>:<namespace_destino>` (sempre separados por `:`).

2. Execute o script passando o caminho para o arquivo de namespaces como primeiro parâmetro

### Exemplo de uso

> Estrutura do arquivo com namespaces:
```
<namespace_origem_1>:<namespace_destino_1>
<namespace_origem_2>:<namespace_destino_2>
.
.
.
<namespace_origem_x>:<namespace_destino_x>
```

> Como executar o script:
```bash
./apply_sct_cm.sh <arquivo_com_namespaces>
```
---

## seal_secrets.sh

### O que faz ?

Utiliza a estrutura criada pelo script `get_sct_cm.sh` para selar as secrets de cada namespace e copiar as secrets seladas para uma pasta de templates do helm.

### Como usar ?

1. Crie um arquivo de texto simples que contém os namespaces de origem e destino dos artefatos, cada linha desse arquivo deve ter apenas `<namespace_origem>:<namespace_destino>` (sempre separados por `:`).

2. Execute o script passando:
    1. caminho da pasta raiz onde o script `get_sct_cm.sh` gerou a estrutura
    2. caminho da pasta raiz com templates do helm
    3. caminho para aquivo com os namespaces mapeados

### Exemplo de uso

> Estrutura do arquivo com namespaces:
```
<namespace_origem_1>:<namespace_destino_1>
<namespace_origem_2>:<namespace_destino_2>
.
.
.
<namespace_origem_x>:<namespace_destino_x>
```

> Como executar o script:
```bash
./seal_secrets.sh <caminho_raiz_artefatos> <caminho_destino_secrets> <arquivo_com_namespaces>
```