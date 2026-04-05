* ==============================================================================
* 03_probit_re_static.do
* Projeto : Determinantes da Adesão ao PGS – Alinhamento Político
* ------------------------------------------------------------------------------
* OBJETIVO
*   Estima o Probit com efeitos aleatórios (RE) estático e exporta os
*   Efeitos Marginais Médios (AME).
*
* OUTPUT : ${dir_tables}/tab_ame_probit_re_static.tex
* ==============================================================================

do "${root}/config.do"

use "${bd_final}", clear
xtset id_municipio ano
keep if inrange(ano, ${ano_ini}, ${ano_fim})

* --- Estimação ----------------------------------------------------------------
xtprobit ano_tratado ///
    dias_chuva_l1 ///
    aridez_evapo12_l1 ///
    alin_gov_fed ///
    alin_pref_fed ///
    pib_admpub_sh_l1 ///
    pib_agro_sh_l1 ///
    ln_dens_pop_l1 ///
    i.ano, re vce(cluster id_municipio)

estimates store probit_re_static

* --- AME (efeitos marginais médios) ------------------------------------------
margins, dydx( ///
    dias_chuva_l1 aridez_evapo12_l1 ///
    alin_gov_fed alin_pref_fed ///
    pib_admpub_sh_l1 pib_agro_sh_l1 ln_dens_pop_l1) post

estimates store AME_static

* --- Exportar tabela ----------------------------------------------------------
esttab AME_static using "${dir_tables}/tab_ame_probit_re_static.tex", ///
    replace booktabs label se ///
    b(%9.3f) se(%9.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    nonumber nomtitle ///
    stats(N, fmt(%9.0fc) labels("Observações")) ///
    title("AME – Probit RE Estático\label{tab:probit_static}") ///
    addnotes("Efeitos marginais médios (AME). Erros-padrão clusterizados no município.")

display as result "tab_ame_probit_re_static.tex exportada."
