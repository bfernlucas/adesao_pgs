* ==============================================================================
* run_all.do
* Projeto : Determinantes da Adesão ao PGS – Alinhamento Político
* ------------------------------------------------------------------------------
* SCRIPT MESTRE: reproduz toda a análise em sequência.
*
* COMO USAR
*   1. Edite `config.do` e ajuste o global `root` para o seu computador.
*   2. No Stata, execute:
*        do "C:\caminho\para\o\projeto\run_all.do"
*   3. Os outputs (tabelas .tex) serão gravados em output/tables/
* ==============================================================================

* ---- Carrega configurações globais ------------------------------------------
* Ajuste o caminho abaixo para a pasta raiz do projeto no seu computador:
do "C:\Users\Lucas\OneDrive\EDUCAÇÃO\PUBLICAÇÕES\EM DESENVOLVIMENTO\Adesão PGS\config.do"

* ---- Abre log global ---------------------------------------------------------
local stamp = subinstr("`c(current_date)' `c(current_time)'", ":", "-", .)
local stamp = subinstr("`stamp'", " ", "_", .)
log using "${dir_logs}/run_all_`stamp'.log", text replace

display as result "======================================================"
display as result " INÍCIO DA REPLICAÇÃO"
display as result " `c(current_date)' `c(current_time)'"
display as result "======================================================"

* ---- Pipeline de scripts -----------------------------------------------------

display as result "--> 00_merge_painel_pol.do"
do "${dir_scripts}/00_merge_painel_pol.do"

display as result "--> 01_padronizacao.do"
do "${dir_scripts}/01_padronizacao.do"

display as result "--> 02_descritivas.do"
do "${dir_scripts}/02_descritivas.do"

display as result "--> 03_probit_re_static.do"
do "${dir_scripts}/03_probit_re_static.do"

display as result "--> 04_probit_re_dynamic.do"
do "${dir_scripts}/04_probit_re_dynamic.do"

display as result "--> 05_probit_dyn_cre_ci.do"
do "${dir_scripts}/05_probit_dyn_cre_ci.do"

display as result "--> 06_tabela_final_3modelos.do"
do "${dir_scripts}/06_tabela_final_3modelos.do"

display as result "--> 07_heterog_semiarido.do"
do "${dir_scripts}/07_heterog_semiarido.do"

display as result "--> 08_heterog_fora_semiarido.do"
do "${dir_scripts}/08_heterog_fora_semiarido.do"

display as result "--> 09_robustez_lpm_fe.do"
do "${dir_scripts}/09_robustez_lpm_fe.do"

* ---- Encerra log -------------------------------------------------------------
display as result "======================================================"
display as result " FIM DA REPLICAÇÃO"
display as result " `c(current_date)' `c(current_time)'"
display as result "======================================================"

log close
