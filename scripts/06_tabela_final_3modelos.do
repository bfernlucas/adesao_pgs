* ==============================================================================
* 06_tabela_final_3modelos.do
* Projeto : Determinantes da Adesão ao PGS – Alinhamento Político
* ------------------------------------------------------------------------------
* OBJETIVO
*   Produz a tabela comparativa de AMEs com 3 especificações:
*     (1) Probit RE Estático
*     (2) Probit RE Dinâmico (ingênuo)
*     (3) Probit RE Dinâmico + CRE/Mundlak + Condição Inicial (Wooldridge 2005)
*
* OUTPUT : ${dir_tables}/tab_ame_probit_3modelos.tex
* ==============================================================================

do "${root}/config.do"

use "${bd_final}", clear
xtset id_municipio ano
keep if inrange(ano, ${ano_ini}, ${ano_fim})

* --- Labels para exportação --------------------------------------------------
label variable dias_chuva_l1     "Dias de chuva (t-1)"
label variable aridez_evapo12_l1 "Índice de aridez P-ETP 12m (t-1)"
label variable alin_gov_fed      "Alinhamento governador–governo federal"
label variable alin_pref_fed     "Alinhamento prefeito–governo federal"
label variable pib_admpub_sh_l1  "Adm. pública no PIB (t-1)"
label variable pib_agro_sh_l1    "Agro no PIB (t-1)"
label variable ln_dens_pop_l1    "Log densidade pop. (t-1)"

* ==============================================================================
* (1) Probit RE Estático
* ==============================================================================
xtprobit ano_tratado ///
    dias_chuva_l1 aridez_evapo12_l1 ///
    alin_gov_fed alin_pref_fed ///
    pib_admpub_sh_l1 pib_agro_sh_l1 ln_dens_pop_l1 ///
    i.ano, re vce(cluster id_municipio)

margins, dydx( ///
    dias_chuva_l1 aridez_evapo12_l1 ///
    alin_gov_fed alin_pref_fed ///
    pib_admpub_sh_l1 pib_agro_sh_l1 ln_dens_pop_l1) post
estimates store AME_static

* ==============================================================================
* Preparação da amostra dinâmica
* ==============================================================================
gen y_l1 = L.ano_tratado
label variable y_l1 "Participou no ano anterior (t-1)"

bysort id_municipio (ano): gen y_i1 = ano_tratado[1]
label variable y_i1 "Condição inicial"

local covs dias_chuva_l1 aridez_evapo12_l1 alin_gov_fed alin_pref_fed ///
           pib_admpub_sh_l1 pib_agro_sh_l1 ln_dens_pop_l1
foreach v of local covs {
    bysort id_municipio: egen mean_`v' = mean(`v')
}

drop if missing(y_l1)

* ==============================================================================
* (2) Probit RE Dinâmico (ingênuo)
* ==============================================================================
xtprobit ano_tratado ///
    y_l1 ///
    dias_chuva_l1 aridez_evapo12_l1 ///
    alin_gov_fed alin_pref_fed ///
    pib_admpub_sh_l1 pib_agro_sh_l1 ln_dens_pop_l1 ///
    i.ano, re vce(cluster id_municipio)

margins, dydx( ///
    y_l1 ///
    dias_chuva_l1 aridez_evapo12_l1 ///
    alin_gov_fed alin_pref_fed ///
    pib_admpub_sh_l1 pib_agro_sh_l1 ln_dens_pop_l1) post
estimates store AME_dyn_RE

* ==============================================================================
* (3) Probit RE Dinâmico + CRE + Condição Inicial
* ==============================================================================
xtprobit ano_tratado ///
    y_l1 ///
    dias_chuva_l1 aridez_evapo12_l1 ///
    alin_gov_fed alin_pref_fed ///
    pib_admpub_sh_l1 pib_agro_sh_l1 ln_dens_pop_l1 ///
    y_i1 ///
    mean_dias_chuva_l1 mean_aridez_evapo12_l1 ///
    mean_alin_gov_fed mean_alin_pref_fed ///
    mean_pib_admpub_sh_l1 mean_pib_agro_sh_l1 mean_ln_dens_pop_l1 ///
    i.ano, re vce(cluster id_municipio)

margins, dydx( ///
    y_l1 ///
    dias_chuva_l1 aridez_evapo12_l1 ///
    alin_gov_fed alin_pref_fed ///
    pib_admpub_sh_l1 pib_agro_sh_l1 ln_dens_pop_l1) post
estimates store AME_dyn_CRE_CI

* ==============================================================================
* Tabela final: 3 colunas
* ==============================================================================
esttab AME_static AME_dyn_RE AME_dyn_CRE_CI ///
    using "${dir_tables}/tab_ame_probit_3modelos.tex", ///
    replace booktabs label ///
    b(%9.3f) se(%9.3f) ///
    star(* 0.10 ** 0.05 *** 0.01) ///
    mtitles("RE" "RE + \$y_{t-1}\$" "RE + CRE/CI") ///
    keep(y_l1 dias_chuva_l1 aridez_evapo12_l1 alin_gov_fed alin_pref_fed ///
         pib_admpub_sh_l1 pib_agro_sh_l1 ln_dens_pop_l1) ///
    order(y_l1 dias_chuva_l1 aridez_evapo12_l1 alin_gov_fed alin_pref_fed ///
          pib_admpub_sh_l1 pib_agro_sh_l1 ln_dens_pop_l1) ///
    stats(N, fmt(%9.0fc) labels("Observações")) ///
    title("Determinantes da Adesão ao PGS – AMEs (3 especificações)\label{tab:main}") ///
    addnotes("Efeitos marginais médios (AME). Erros-padrão clusterizados no município." ///
             "Período: ${ano_ini}--${ano_fim}. Col. (3): Wooldridge (2005).")

display as result "tab_ame_probit_3modelos.tex exportada."
