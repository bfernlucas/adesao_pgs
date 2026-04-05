* ==============================================================================
* config.do
* Projeto : Determinantes da Adesão ao PGS – Alinhamento Político
* Autores : Lucas Fernandes (bfernlucas)
* Criado  : 2025
* ------------------------------------------------------------------------------
* PROPÓSITO
*   Define TODOS os caminhos globais do projeto de forma relativa à raiz.
*   É o ÚNICO arquivo que precisa ser editado ao mudar de máquina.
*
* COMO USAR
*   1. Abra o Stata a partir da pasta raiz do projeto  OU
*      defina manualmente o global `root` abaixo.
*   2. Execute:  do "config.do"
*   3. Todos os demais scripts chamam este arquivo no início.
* ==============================================================================

* ------------------------------------------------------------------------------
* 1) RAIZ DO PROJETO
*    Ajuste apenas esta linha ao clonar em outra máquina.
* ------------------------------------------------------------------------------
global root "C:\Users\Lucas\OneDrive\EDUCAÇÃO\PUBLICAÇÕES\EM DESENVOLVIMENTO\Adesão PGS"

* ------------------------------------------------------------------------------
* 2) SUBPASTAS (relativas a `root` – NÃO alterar)
* ------------------------------------------------------------------------------
global dir_raw       "${root}/data/raw"
global dir_processed "${root}/data/processed"
global dir_external  "${root}/data/external"
global dir_tables    "${root}/output/tables"
global dir_figures   "${root}/output/figures"
global dir_logs      "${root}/output/logs"
global dir_scripts   "${root}/scripts"

* ------------------------------------------------------------------------------
* 3) ARQUIVOS DE ENTRADA (dados brutos)
* ------------------------------------------------------------------------------
global file_painel_xtreg  "${dir_raw}/xtreg_pgs.dta"
global file_alinhamento   "${dir_raw}/painel_municipios_com_alinhamento_governador.csv"

* ------------------------------------------------------------------------------
* 4) ARQUIVOS PROCESSADOS (intermediários e finais)
* ------------------------------------------------------------------------------
global bd_painel_pol      "${dir_processed}/bd_painel_pol.dta"
global bd_alin_unique     "${dir_processed}/bd_alinhamento_unique.dta"
global bd_merged          "${dir_processed}/bd_painel_PGS_pol.dta"
global bd_final           "${dir_processed}/bd_painel_PGS_pol_padronizada.dta"

* ------------------------------------------------------------------------------
* 5) PARÂMETROS DO PAPER
* ------------------------------------------------------------------------------
global ano_ini  2003
global ano_fim  2008

* ------------------------------------------------------------------------------
* 6) CONFIRMAR CAMINHOS
* ------------------------------------------------------------------------------
foreach d in raw processed external tables figures logs scripts {
    capture mkdir "${root}/data/`d'"   2>nul
    capture mkdir "${root}/output/`d'" 2>nul
}
capture mkdir "${root}/data/raw"       2>nul
capture mkdir "${root}/data/processed" 2>nul
capture mkdir "${root}/data/external"  2>nul
capture mkdir "${root}/output/tables"  2>nul
capture mkdir "${root}/output/figures" 2>nul
capture mkdir "${root}/output/logs"    2>nul

display as result "─────────────────────────────────────────"
display as result " config.do carregado com sucesso"
display as result " root = ${root}"
display as result "─────────────────────────────────────────"
