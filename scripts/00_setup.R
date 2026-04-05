# =============================================================================
# 00_setup.R
# Projeto: Adesão ao PGS
# Descrição: Instalação e carregamento de pacotes, caminhos globais e opções
# =============================================================================

# ---- 1. Gerenciamento de pacotes (renv) ------------------------------------
# Para ativar controle de versão dos pacotes, rode uma vez:
#   install.packages("renv"); renv::init()
# Para restaurar o ambiente de um colaborador:
#   renv::restore()

# ---- 2. Pacotes necessários -------------------------------------------------
packages <- c(
  # Manipulação de dados
  "tidyverse",    # dplyr, ggplot2, tidyr, readr, stringr, forcats
  "data.table",   # alternativa rápida ao dplyr para bases grandes
  "lubridate",    # datas

  # Econometria
  "fixest",       # OLS, IV, FE com SEs cluster-robustos (feleml, feols, feiv)
  "lmtest",       # testes de hipóteses
  "sandwich",     # variâncias robustas (HC, HAC, cluster)
  "AER",          # IV e testes de instrumentos (ivreg, weak instruments)
  "rdrobust",     # RDD
  "did",          # DiD com tratamento escalonado (Callaway & Sant'Anna)
  "staggered",    # DiD escalonado (Sun & Abraham)

  # Tabelas e saída
  "modelsummary", # tabelas de regressão reprodutíveis
  "kableExtra",   # formatação de tabelas
  "gt",           # tabelas no estilo publicação
  "stargazer",    # tabelas LaTeX clássicas

  # Figuras
  "ggplot2",      # já incluído no tidyverse
  "patchwork",    # combinar múltiplos gráficos
  "ggthemes",     # temas adicionais
  "scales",       # formatação de eixos

  # Utilidades
  "here",         # caminhos relativos portáveis
  "haven",        # leitura de .dta (Stata), .sas, .spss
  "readxl",       # leitura de .xlsx
  "janitor",      # limpeza de nomes de colunas
  "skimr",        # resumo rápido de dados
  "assertr"       # validação de dados
)

# Instalar pacotes ausentes
to_install <- packages[!packages %in% installed.packages()[, "Package"]]
if (length(to_install) > 0) {
  install.packages(to_install, repos = "https://cloud.r-project.org")
}

# Carregar pacotes
invisible(lapply(packages, library, character.only = TRUE))

# ---- 3. Caminhos globais (via here) -----------------------------------------
# here() aponta para a raiz do projeto (onde está o .here ou .Rproj)
PATH_RAW        <- here("data", "raw")
PATH_PROCESSED  <- here("data", "processed")
PATH_EXTERNAL   <- here("data", "external")
PATH_TABLES     <- here("output", "tables")
PATH_FIGURES    <- here("output", "figures")
PATH_LOGS       <- here("output", "logs")

# ---- 4. Opções globais -------------------------------------------------------
options(
  scipen = 999,           # evitar notação científica
  digits = 4,
  warn   = 1              # warnings imediatos
)

set.seed(42)              # reprodutibilidade em sorteios/bootstrap

# ---- 5. Tema padrão ggplot2 --------------------------------------------------
theme_paper <- theme_bw(base_size = 12) +
  theme(
    panel.grid.minor  = element_blank(),
    strip.background  = element_rect(fill = "white"),
    legend.position   = "bottom"
  )
theme_set(theme_paper)

# ---- 6. Funções auxiliares ---------------------------------------------------
source(here("scripts", "utils.R"))

message("Setup concluído. Ambiente pronto.")
