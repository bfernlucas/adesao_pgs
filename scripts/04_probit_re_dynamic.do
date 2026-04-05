* ==============================================================================
* 04_probit_re_dynamic.do
* Projeto : Determinantes da Adesão ao PGS – Alinhamento Político
* ------------------------------------------------------------------------------
* OBJETIVO
*   Estima o Probit RE dinâmico "ingênuo" (inclui y_{t-1} sem corrigir o
*   problema de condição inicial) e exporta os AMEs.
*
* OUTPUT : ${dir_tables}/tab_ame_probit_re_dyn.tex
* ==============================================================================

do "${root}/config.do"

use "${bd_final}", clear
xtset id_municipio ano
keep if inrange(ano, ${ano_ini}, ${ano_fim})

* --- Criar defasagem do desfecho ----------------------------------------------
gen y_l1 = L.ano_tratado
label variable y_l1 "Participou no ano anterior (t-1)"

drop if missing(y_l1)   // remove 1ª obs de cada município (lag indisponível)

* --- Estimação ----------------------------------------------------------------
xtprobit ano_tratado ///
    y_l1 ///
    dias_chuva_l1 ///
    aridez_evapo12_l1 ///
    alin_gov_fed ///
    alin_pref_fed ///
    pib_admpub_sh_l1 ///
    pib_agro_sh_l1 ///
    ln_dens_pop_l1 ///
    i.ano, re vce(cluster id_municipio)

estimates store probit_re_dyn

* --- AME ----------------------------------------------------------------------
margins, dydx( ///
    y_l1 ///
    dias_chuva_l1 aridez_evapo12_l1 ///
    alin_gov_fed alin_pref_fed ///
    pib_admpub_sh_l1 pib_agro_sh_l1 ln_dens_pop_l1) post

estimates store AME_dyn_RE

* --- Exportar tabela ----------------------------------------------------------
esttab AME_dyn_RE using "${dir_tables}/tab_ame_probit_re_dyn.tex", ///
    replace booktabs label se ///
    b(%9.3f) se(%9.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    nonumber nomtitle ///
    stats(N, fmt(%9.0fc) labels("Observações")) ///
    title("AME – Probit RE Dinâmico\label{tab:probit_dyn}") ///
    addnotes("Efeitos marginais médios (AME). Erros-padrão clusterizados no município." ///
             "Inclui y\$_{t-1}\$ sem corrigir condição inicial (modelo ingênuo).")

display as result "tab_ame_probit_re_dyn.tex exportada."
