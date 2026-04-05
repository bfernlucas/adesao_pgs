* ==============================================================================
* 01_padronizacao.do
* Projeto : Determinantes da Adesão ao PGS – Alinhamento Político
* ------------------------------------------------------------------------------
* OBJETIVO
*   Padroniza nomes de variáveis, aplica labels de variáveis e de valores,
*   ordena as colunas e comprime a base para uso analítico.
*
* INPUT  : ${bd_merged}  (bd_painel_PGS_pol.dta)
* OUTPUT : ${bd_final}   (bd_painel_PGS_pol_padronizada.dta)
* ==============================================================================

do "${root}/config.do"

use "${bd_merged}", clear

* ==============================================================================
* 1) Resolver duplicatas de nome de UF e Município
* ==============================================================================
capture confirm variable municipio
if !_rc {
    capture confirm variable nm_municipio
    if _rc  rename municipio nm_municipio
    else    drop municipio
}

capture confirm variable sigla_uf
if !_rc {
    capture confirm variable uf_sigla
    if _rc  rename sigla_uf uf_sigla
    else    drop sigla_uf
}

capture confirm variable uf
if !_rc {
    capture confirm variable uf_sigla
    if _rc  rename uf uf_sigla
}

* ==============================================================================
* 2) Renomear variáveis (convenção: domínio_descrição_sufixo)
* ==============================================================================

* — Clima / estrutura (lags) —
capture confirm variable diasdechuva_lag1
if !_rc rename diasdechuva_lag1 dias_chuva_l1

capture confirm variable aridity_evapo_12months_lag1
if !_rc rename aridity_evapo_12months_lag1 aridez_evapo12_l1

capture confirm variable pib_agro_share_lag1
if !_rc rename pib_agro_share_lag1 pib_agro_sh_l1

capture confirm variable pib_admpub_share_lag1
if !_rc rename pib_admpub_share_lag1 pib_admpub_sh_l1

capture confirm variable ln_densidade_pop_lag1
if !_rc rename ln_densidade_pop_lag1 ln_dens_pop_l1

* — Alinhamentos —
capture confirm variable gov_est_fed
if !_rc rename gov_est_fed alin_gov_fed

capture confirm variable pref_fed
if !_rc rename pref_fed alin_pref_fed

* — Variáveis eleitorais/políticas —
capture confirm variable ano_eleicao
if !_rc rename ano_eleicao ano_eleic_mun

capture confirm variable numero_candidato
if !_rc rename numero_candidato n_cand_mun

capture confirm variable partido_prefeito
if !_rc rename partido_prefeito part_pref

capture confirm variable votos
if !_rc rename votos votos_pref

capture confirm variable partido_presidente
if !_rc rename partido_presidente part_pres

capture confirm variable ano_eleicao_presidencial
if !_rc rename ano_eleicao_presidencial ano_eleic_pres

capture confirm variable ano_eleicao_presidencial_mapeada
if !_rc rename ano_eleicao_presidencial_mapeada ano_eleic_pres_map

capture confirm variable alinhado_prefeito_pres_coligacao
if !_rc rename alinhado_prefeito_pres_coligacao alin_pref_pres_colig

capture confirm variable partido_governador
if !_rc rename partido_governador part_gov

capture confirm variable alinhado_governador_pres_coligac
if !_rc rename alinhado_governador_pres_coligac alin_gov_pres_colig

capture confirm variable alinhado_pref_governador_partido
if !_rc rename alinhado_pref_governador_partido alin_pref_gov_part

capture confirm numeric variable data_eleicao
if !_rc format data_eleicao %td

* ==============================================================================
* 3) Labels de valores e de variáveis
* ==============================================================================
capture label define yesno 0 "Não" 1 "Sim", replace

foreach v in sudene semiarido benef ano_tratado alin_gov_fed alin_pref_fed ///
             alin_pref_pres_colig alin_gov_pres_colig alin_pref_gov_part {
    capture confirm variable `v'
    if !_rc capture label values `v' yesno
}

capture label variable ano                    "Ano (calendário)"
capture label variable ano_safra              "Ano-safra (referência agrícola)"
capture label variable id_municipio           "Código do município (IBGE)"
capture label variable nm_municipio           "Nome do município"
capture label variable uf_sigla               "UF (sigla)"
capture label variable nm_uf                  "UF (nome)"
capture label variable sudene                 "Município pertence à SUDENE"
capture label variable semiarido              "Município pertence ao Semiárido"
capture label variable benef                  "PGS acionado (benefício pago no ano t)"
capture label variable ano_tratado            "Município participou do PGS no ano t"
capture label variable dias_chuva_l1          "Dias de chuva (t-1)"
capture label variable aridez_evapo12_l1      "Índice de aridez P-ETP 12m (t-1)"
capture label variable pib_agro_sh_l1         "Participação do agro no PIB (t-1)"
capture label variable pib_admpub_sh_l1       "Participação da adm. pública no PIB (t-1)"
capture label variable ln_dens_pop_l1         "Log densidade populacional (t-1)"
capture label variable ano_eleic_mun          "Ano da eleição municipal"
capture label variable data_eleicao           "Data da eleição municipal"
capture label variable n_cand_mun             "Número de candidatos (eleição municipal)"
capture label variable part_pref              "Partido do prefeito"
capture label variable votos_pref             "Votos do candidato vencedor"
capture label variable part_gov               "Partido do governador"
capture label variable part_pres              "Partido do presidente"
capture label variable presidente             "Presidente (nome)"
capture label variable ano_eleic_pres         "Ano da eleição presidencial"
capture label variable ano_eleic_pres_map     "Ano eleição presidencial (mapeada p/ mandato)"
capture label variable alin_pref_fed          "Alinhamento prefeito–governo federal"
capture label variable alin_gov_fed           "Alinhamento governador–governo federal"
capture label variable alin_pref_pres_colig   "Alinhamento prefeito–presidente (coligação)"
capture label variable alin_gov_pres_colig    "Alinhamento governador–presidente (coligação)"
capture label variable alin_pref_gov_part     "Alinhamento prefeito–governador (partido)"

* ==============================================================================
* 4) Ordenação das colunas
* ==============================================================================
order ///
    id_municipio nm_municipio uf_sigla nm_uf ///
    ano ano_safra ///
    sudene semiarido ///
    ano_tratado benef ///
    dias_chuva_l1 aridez_evapo12_l1 ///
    pib_agro_sh_l1 pib_admpub_sh_l1 ln_dens_pop_l1 ///
    ano_eleic_mun data_eleicao n_cand_mun part_pref votos_pref ///
    part_gov ///
    ano_eleic_pres ano_eleic_pres_map presidente part_pres ///
    alin_pref_fed alin_gov_fed ///
    alin_pref_pres_colig alin_gov_pres_colig alin_pref_gov_part, first

compress

* ==============================================================================
* 5) Salvar base padronizada
* ==============================================================================
save "${bd_final}", replace
display as result "bd_painel_PGS_pol_padronizada salvo. N = `c(N)'"
