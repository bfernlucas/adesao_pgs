# Determinantes da Adesão ao PGS: Alinhamento Político e Fatores Climáticos

> Painel municipal brasileiro · 2003–2008 · SUDENE / Semiárido

## Sobre o projeto

Este repositório contém o código de replicação do artigo que analisa os determinantes da adesão municipal ao **Programa de Garantia de Safra (PGS)**, com foco no papel do alinhamento político (prefeito–governo federal e governador–governo federal) e de condicionantes climáticos.

**Variável dependente:** `ano_tratado` – município participou do PGS no ano *t*

**Estratégia empírica:** Probit com efeitos aleatórios (RE), dinâmico com correção de condição inicial via abordagem de Wooldridge (2005) e CRE/Mundlak.

**Chave do painel:** `id_municipio × ano`

---

## Estrutura do repositório

```
adesao_pgs/
├── config.do                   ← ÚNICO arquivo a editar ao mudar de máquina
├── run_all.do                  ← Reproduz toda a análise em sequência
│
├── scripts/
│   ├── 00_merge_painel_pol.do  ← Constrói a base analítica (merge)
│   ├── 01_padronizacao.do      ← Nomes, labels, ordenação
│   ├── 02_descritivas.do       ← Tabela de estatísticas descritivas
│   ├── 03_probit_re_static.do  ← Probit RE estático + AME
│   ├── 04_probit_re_dynamic.do ← Probit RE dinâmico ingênuo + AME
│   ├── 05_probit_dyn_cre_ci.do ← Probit dinâmico + CRE + CI (Wooldridge 2005)
│   ├── 06_tabela_final_3modelos.do ← Tabela comparativa (3 colunas)
│   ├── 07_heterog_semiarido.do ← Heterogeneidade: Semiárido
│   ├── 08_heterog_fora_semiarido.do ← Heterogeneidade: Fora do Semiárido
│   └── 09_robustez_lpm_fe.do   ← Robustez: LPM com FE
│
├── data/
│   ├── raw/          ← Dados brutos (não versionados no git)
│   ├── processed/    ← Dados processados (não versionados)
│   └── external/     ← Fontes externas (não versionadas)
│
├── output/
│   ├── tables/       ← Tabelas .tex (versionadas)
│   ├── figures/      ← Figuras .png/.pdf (versionadas)
│   └── logs/         ← Logs de execução (não versionados)
│
└── paper/            ← Manuscrito LaTeX (se aplicável)
```

---

## Como reproduzir

### 1. Pré-requisitos

- **Stata 16+** (requer `reghdfe`, `estout`, `xtprobit`)
- Instale os pacotes necessários uma única vez:
  ```stata
  ssc install reghdfe
  ssc install ftools
  ssc install estout
  ```

### 2. Dados

Copie os arquivos brutos para `data/raw/`:

| Arquivo | Descrição |
|---|---|
| `xtreg_pgs.dta` | Painel PGS com covariáveis climáticas e estruturais |
| `painel_municipios_com_alinhamento_governador.csv` | Alinhamento político municipal |

> Os dados **não são versionados** no git por questões de tamanho e privacidade.

### 3. Configuração

Abra `config.do` e ajuste **apenas a linha**:
```stata
global root "C:\caminho\para\o\projeto\adesao_pgs"
```

### 4. Reprodução completa

```stata
do "C:\caminho\para\o\projeto\adesao_pgs\run_all.do"
```

Ou execute os scripts individualmente na ordem numerada.

---

## Variáveis principais

| Variável | Descrição |
|---|---|
| `ano_tratado` | Município participou do PGS no ano *t* (dummy) |
| `benef` | PGS acionado – benefício pago no ano *t* (dummy) |
| `alin_pref_fed` | Alinhamento prefeito–governo federal (dummy) |
| `alin_gov_fed` | Alinhamento governador–governo federal (dummy) |
| `dias_chuva_l1` | Dias de chuva (defasado em 1 ano) |
| `aridez_evapo12_l1` | Índice de aridez P-ETP 12 meses (defasado) |
| `pib_agro_sh_l1` | Participação do agronegócio no PIB municipal (defasado) |
| `ln_dens_pop_l1` | Log da densidade populacional (defasado) |

---

## Outputs gerados

| Arquivo | Tabela no artigo |
|---|---|
| `output/tables/tab_descritivas.tex` | Estatísticas descritivas |
| `output/tables/tab_ame_probit_3modelos.tex` | Tabela principal (3 especificações) |
| `output/tables/tab_ame_probit_dyn_cre_ci_semiarido.tex` | Heterogeneidade – Semiárido |
| `output/tables/tab_ame_probit_dyn_cre_ci_fora_semi.tex` | Heterogeneidade – Fora Semiárido |
| `output/tables/tab_lpm_fe.tex` | Robustez – LPM-FE |

---

## Referências

- Wooldridge, J.M. (2005). Simple solutions to the initial conditions problem in dynamic, nonlinear panel data models with unobserved heterogeneity. *Journal of Applied Econometrics*, 20(1), 39–54.
- Mundlak, Y. (1978). On the pooling of time series and cross section data. *Econometrica*, 46(1), 69–85.
