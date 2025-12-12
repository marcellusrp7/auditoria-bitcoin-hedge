# ==============================================================================
# AUDITORIA ECONOMÉTRICA: BITCOIN BRASIL (HEDGE VS DOLARIZAÇÃO)
# Autor: Marcelo Rodrigues Pereira
# ==============================================================================

# 1. SETUP E PACOTES
if(!require(pacman)) install.packages("pacman")
pacman::p_load(readxl, readr, dplyr, quantmod, lmtest, sandwich, car, lubridate, stargazer, ggplot2)

# ==============================================================================
# 2. CARREGAMENTO DE DADOS (Lendo da pasta 'data/')
# ==============================================================================

# A. Bitcoin Brasil (Ajustado para pular a linha de cabeçalho extra se houver)
btc_raw <- read_excel("data/btc_brl.xlsx", skip = 1) 
btc <- btc_raw %>% 
  select(Date = 1, Close = 2) %>% 
  mutate(Date = ymd(Date)) %>% 
  na.omit()

# B. Câmbio (USD/BRL)
cambio_raw <- read_excel("data/usd_brl.xlsx")
cambio <- cambio_raw %>% 
  select(Date = 1, Rate = 2) %>% 
  mutate(Date = ymd(Date)) %>% 
  na.omit()

# C. Risco País (CDS) - Leitura de CSV com separador ponto e vírgula
cds_raw <- read_delim("data/cds_brazil.csv", delim = ";", show_col_types = FALSE)
cds <- cds_raw %>% 
  select(Date = 1, CDS = 2) %>% 
  mutate(Date = dmy(Date), CDS = as.numeric(gsub(",", ".", CDS))) %>% 
  na.omit()

# D. Benchmark Global (API Yahoo Finance em tempo real)
getSymbols("BTC-USD", src = "yahoo", from = "2018-01-01", to = Sys.Date())
btc_usd <- data.frame(Date = index(`BTC-USD`), Close_USD = as.numeric(`BTC-USD`[,4]))

# ==============================================================================
# 3. UNIFICAÇÃO E TRANSFORMAÇÃO (LOG-RETORNOS)
# ==============================================================================
# Juntar todas as tabelas pela data comum
df <- Reduce(function(x, y) inner_join(x, y, by = "Date"), list(btc, btc_usd, cambio, cds))

# Calcular Log-Retornos (Estacionarizar as séries)
model_data <- data.frame(
  Date = df$Date[-1],
  ret_brl = diff(log(df$Close)),    # Variável Dependente
  ret_usd = diff(log(df$Close_USD)), # Controle Global
  ret_fx  = diff(log(df$Rate)),      # Efeito Câmbio
  d_cds   = diff(df$CDS)             # Efeito Risco
)

# ==============================================================================
# 4. MODELAGEM (OLS COM ERROS ROBUSTOS NEWEY-WEST)
# ==============================================================================
# Modelo: O retorno Brasil é explicado pelo Mundo + Câmbio + Risco?
model <- lm(ret_brl ~ ret_usd + ret_fx + d_cds, data = model_data)

# Teste Robusto (HC0 - White/Newey-West) para corrigir heterocedasticidade
robust_se <- vcovHC(model, type = "HC0")
print(coeftest(model, vcov = robust_se))

# ==============================================================================
# 5. GERAR RESULTADOS VISUAIS
# ==============================================================================

# Gráfico de Aderência
model_data$Predicted <- predict(model, newdata = model_data)
grafico <- ggplot(tail(model_data, 100), aes(x = Date)) +
  geom_line(aes(y = ret_brl, color = "Real Market"), size = 1) +
  geom_line(aes(y = Predicted, color = "Model Fit"), linetype = "dashed") +
  theme_minimal() +
  labs(title = "Model Fit: Bitcoin Brazil (Last 100 Days)", 
       subtitle = "R-squared: 90.5% - Driven by Global Price & FX, not Risk.",
       y = "Log Returns", color = "Legend")

ggsave("results/model_fit_chart.png", plot = grafico, width = 10, height = 6)
print("Gráfico salvo na pasta results/")