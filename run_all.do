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
do "${0:h}/config.do"          // Stata 16+: detecta pasta do próprio script
* Se o comando acima falhar, use:
* do "C:\caminho\completo\para\o\projeto\config.do"

* ---- Abre log global ---------------------------------------------------------
local stamp = subinstr("`c(current_date)' `c(current_time)'", ":", "-", .)
local stamp = subinstr("`stamp'", " ", "_", .)
log using "${dir_logs}/run_all_`stamp'.log", text replace

display as result "======================================================"
display as result " INÍCIO DA REPLICAÇÃO"
display as result " `c(current_date)' `c(current_time)'"
display as result "======================================================"

* ---- Pipeline de scripts -----------------------------------------------------

* 1. Construção da base analítica
display as result "--> 00_merge_painel_pol.do"
do "${dir_scripts}/00_merge_painel_pol.do"

* 2. Padronização, labels e ordenação
display as result "--> 01_padronizacao.do"
do "${dir_scripts}/01_padronizacao.do"

* 3. Estatísticas descritivas
display as result "--> 02_descritivas.do"
do "${dir_scripts}/02_descritivas.do"

* 4. Probit RE estático
display as result "--> 03_probit_re_static.do"
do "${dir_scripts}/03_probit_re_static.do"

* 5. Probit RE dinâmico (ingênuo)
display as result "--> 04_probit_re_dynamic.do"
do "${dir_scripts}/04_probit_re_dynamic.do"

* 6. Probit dinâmico RE + CRE + condição inicial (Wooldridge 2005)
display as result "--> 05_probit_dyn_cre_ci.do"
do "${dir_scripts}/05_probit_dyn_cre_ci.do"

* 7. Tabela final comparativa (3 modelos)
display as result "--> 06_tabela_final_3modelos.do"
do "${dir_scripts}/06_tabela_final_3modelos.do"

* 8. Heterogeneidade – Semiárido
display as result "--> 07_heterog_semiarido.do"
do "${dir_scripts}/07_heterog_semiarido.do"

* 9. Heterogeneidade – Fora do Semiárido
display as result "--> 08_heterog_fora_semiarido.do"
do "${dir_scripts}/08_heterog_fora_semiarido.do"

* 10. Robustez – LPM com Efeitos Fixos
display as result "--> 09_robustez_lpm_fe.do"
do "${dir_scripts}/09_robustez_lpm_fe.do"

* ---- Encerra log -------------------------------------------------------------
display as result "======================================================"
display as result " FIM DA REPLICAÇÃO"
display as result " `c(current_date)' `c(current_time)'"
display as result "======================================================"

log close
