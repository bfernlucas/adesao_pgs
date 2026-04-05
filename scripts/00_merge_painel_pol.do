* ==============================================================================
* 00_merge_painel_pol.do
* Projeto : Determinantes da Adesão ao PGS – Alinhamento Político
* ------------------------------------------------------------------------------
* OBJETIVO
*   Constrói a base analítica combinando:
*     (a) painel PGS  ←  ${file_painel_xtreg}
*     (b) alinhamento político municipal  ←  ${file_alinhamento}
*   Chave final: id_municipio × ano
*
* INPUT  : ${file_painel_xtreg}  (xtreg_pgs.dta)
*          ${file_alinhamento}   (.csv)
* OUTPUT : ${bd_final_merged}    (bd_painel_PGS_pol.dta)
* ==============================================================================

do "${root}/config.do"

* ------------------------------------------------------------------------------
* 1) Base master: painel PGS
* ------------------------------------------------------------------------------
use "${file_painel_xtreg}", clear

keep ///
    ano ano_safra uf nm_uf id_municipio nm_municipio sudene semiarido benef ano_tratado ///
    diasdechuva_lag1 ///
    aridity_evapo_12months_lag1 ///
    gov_est_fed ///
    pref_fed ///
    pib_admpub_share_lag1 ///
    pib_agro_share_lag1 ///
    ln_densidade_pop_lag1

isid id_municipio ano

save "${bd_painel_pol}", replace
display as result "bd_painel_pol salvo."

* ------------------------------------------------------------------------------
* 2) Base de alinhamento
*    Regra: 1 obs por (id_municipio × ano_mandato)
*    Critério de desempate: eleição mais antiga no ano (baseline do mandato)
* ------------------------------------------------------------------------------
import delimited "${file_alinhamento}", clear

* Converter data_eleicao (string YYYY-MM-DD → data Stata)
capture confirm numeric variable data_eleicao
if _rc {
    gen double data_eleicao2 = daily(data_eleicao, "YMD")
    format data_eleicao2 %td
    drop data_eleicao
    rename data_eleicao2 data_eleicao
}
else {
    format data_eleicao %td
}

* Alinhar chave com o painel
rename ano_mandato ano

* Manter 1 obs por id_municipio-ano (eleição mais antiga)
bys id_municipio ano (data_eleicao): keep if _n == 1

isid id_municipio ano
save "${bd_alin_unique}", replace
display as result "bd_alinhamento_unique salvo."

* ------------------------------------------------------------------------------
* 3) Merge 1:1
* ------------------------------------------------------------------------------
use "${bd_painel_pol}", clear
isid id_municipio ano

merge 1:1 id_municipio ano using "${bd_alin_unique}"

tab _merge
keep if _merge == 3
drop _merge

save "${bd_merged}", replace
display as result "bd_painel_PGS_pol salvo. N = `c(N)'"
