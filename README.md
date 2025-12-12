# Análise Econométrica: Bitcoin como Hedge em Economias Emergentes (Brasil)

Este repositório contém a auditoria estatística e a modelagem econométrica desenvolvida para validar a hipótese de uso do Bitcoin como proteção cambial (*hedge*) versus risco soberano no Brasil, referente ao período de 2018 a 2025.

**Contexto:** Suporte técnico à Dissertação de Mestrado Profissional (UNIALFA).

## 🎯 Objetivo do Estudo

Investigar se o preço do Bitcoin no Brasil ($P_{BRL}$) reage a choques no **Risco País (CDS 5 Anos)** ou se atua meramente como um veículo de **Dolarização Sintética** (seguindo o paridade global).

## 📊 Metodologia

Diferente de abordagens baseadas em correlação simples (Pearson) — que podem gerar resultados espúrios em séries com tendência de alta —, este estudo utiliza **Regressão Linear Múltipla em Log-Retornos** com estimadores robustos.

### Especificação do Modelo
A equação estimada foi:

$$\Delta \ln(P^{BRL}_t) = \alpha + \beta_1 \Delta \ln(P^{USD}_t) + \beta_2 \Delta \ln(E_t) + \beta_3 \Delta (CDS_t) + \varepsilon_t$$

Onde:
* **Benchmark Global:** Bitcoin em Dólar (Yahoo Finance).
* **Câmbio:** Taxa PTAX (Bacen).
* **Risco:** CDS Brazil 5 Years (Credit Default Swap).

### Stack Tecnológico
* **Linguagem:** R (4.4.1)
* **Pacotes Principais:** `quantmod` (Dados), `sandwich` & `lmtest` (Correção de Newey-West/HC0), `stargazer` (Tabelas Acadêmicas).

## 📉 Principais Resultados

| Variável | Coeficiente | Significância | Interpretação |
| :--- | :---: | :---: | :--- |
| **Bitcoin Global** | 0.89 | *** (p<0.01) | Integração quase perfeita com o mercado mundial. |
| **Câmbio (USD)** | 0.48 | *** (p<0.01) | Proteção cambial efetiva (Pass-through). |
| **Risco País (CDS)** | ~0.00 | n.s. (p>0.30) | **Hipótese de Hedge de Crise rejeitada.** |

> **Conclusão:** O estudo comprova que o investidor brasileiro utiliza o Bitcoin para exposição cambial (acesso ao Dólar), mas não precifica o risco fiscal de curto prazo no ativo. O resultado corrobora a tese de "utilidade transacional" do **Banco Central Europeu (ECB)** para mercados emergentes.

## 🚀 Como Reproduzir

1. Clone este repositório.
2. Certifique-se de que os arquivos de dados estão na pasta `data/`.
3. Abra o projeto no **RStudio**.
4. Instale as dependências:
   ```R
   install.packages(c("readxl", "tidyverse", "quantmod", "sandwich", "lmtest", "stargazer"))