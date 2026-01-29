-- Identificar quais nichos convertem melhor 
SELECT 
    d.CNT_TME_PRF AS tema,
    SUM(f.ADS_CLK_DIA) AS total_cliques,
    SUM(f.ADS_VIW_DIA) AS total_views,
    ROUND((SUM(f.ADS_CLK_DIA) / NULLIF(SUM(f.ADS_VIW_DIA), 0)) * 100, 2) AS ctr_percentual
FROM dw.FT_ADS_PRF f
JOIN dw.DIM_ITR d ON f.SRK_ITR = d.SRK_ITR
GROUP BY d.CNT_TME_PRF
ORDER BY ctr_percentual DESC;



-- Saber se pessoas com renda "High" clicam mais.
SELECT 
    u.INC_LVL AS nivel_renda,
    AVG(f.ADS_VIW_DIA) AS media_ads_vistos,
    AVG(f.ADS_CLK_DIA) AS media_ads_clicados
FROM dw.FT_ADS_PRF f
JOIN dw.DIM_USR u ON f.SRK_USR = u.SRK_USR
GROUP BY u.INC_LVL
ORDER BY media_ads_clicados DESC;



-- Testar a hipótese de clique impulsivo por estresse.
SELECT 
    e.STR_SCR AS nivel_estresse,
    COUNT(f.SRK_USR) AS total_usuarios,
    AVG(f.ADS_CLK_DIA) AS media_cliques
FROM dw.FT_ADS_PRF f
JOIN dw.DIM_ETL_VDA e ON f.SRK_ETL_VDA = e.SRK_ETL_VDA
GROUP BY e.STR_SCR
ORDER BY e.STR_SCR ASC;



-- Verificar comportamento baseado no tipo de assinatura.
SELECT 
    c.SUB_STS AS tipo_assinatura,
    SUM(f.ADS_CLK_DIA) AS total_cliques,
    AVG(f.ADS_CLK_DIA) AS media_cliques_por_usuario
FROM dw.FT_ADS_PRF f
JOIN dw.DIM_CNT c ON f.SRK_CNT = c.SRK_CNT
GROUP BY c.SUB_STS;


-- Performance por Gênero e País
SELECT 
    u.CTR_USR AS pais,
    u.GEN_USR AS genero,
    SUM(f.ADS_CLK_DIA) AS total_cliques
FROM dw.FT_ADS_PRF f
JOIN dw.DIM_USR u ON f.SRK_USR = u.SRK_USR
GROUP BY u.CTR_USR, u.GEN_USR
ORDER BY total_cliques DESC
LIMIT 10;



-- Quem passa mais tempo no feed clica mais?
SELECT 
    CASE 
        WHEN eng.TIM_FED_DIA > 60 THEN 'Viciado (>1h)'
        WHEN eng.TIM_FED_DIA > 30 THEN 'Moderado (30m-1h)'
        ELSE 'Casual (<30m)'
    END AS perfil_uso,
    AVG(ads.ADS_CLK_DIA) AS media_cliques_ads
FROM dw.FT_ADS_PRF ads
JOIN dw.FT_ENG_APP eng ON ads.SRK_USR = eng.SRK_USR
GROUP BY 1
ORDER BY media_cliques_ads DESC;

-- Perfil Etário (Faixas de Idade)
SELECT 
    CASE 
        WHEN u.AGE_USR < 25 THEN '<25'
        WHEN u.AGE_USR BETWEEN 25 AND 40 THEN '25-40'
        WHEN u.AGE_USR BETWEEN 41 AND 60 THEN '41-60'
        ELSE '60+'
    END AS faixa_etaria,
    AVG(f.ADS_CLK_DIA) AS media_cliques
FROM dw.FT_ADS_PRF f
JOIN dw.DIM_USR u ON f.SRK_USR = u.SRK_USR
GROUP BY 1
ORDER BY media_cliques DESC;



-- Comparar o CTR de grupos baseados em felicidade declarada.
WITH Metricas_Globais AS (
    -- Calcula a média geral de cliques de todo o sistema
    SELECT AVG(ADS_CLK_DIA) AS media_global
    FROM dw.FT_ADS_PRF
),
Metricas_Por_Felicidade AS (
    -- Calcula a média por nível de felicidade
    SELECT 
        e.HPN_SCR AS nivel_felicidade,
        AVG(f.ADS_CLK_DIA) AS media_grupo
    FROM dw.FT_ADS_PRF f
    JOIN dw.DIM_ETL_VDA e ON f.SRK_ETL_VDA = e.SRK_ETL_VDA
    GROUP BY e.HPN_SCR
)
SELECT 
    h.nivel_felicidade,
    ROUND(h.media_grupo::numeric, 2) AS media_cliques_grupo,
    ROUND(g.media_global::numeric, 2) AS media_cliques_global,
    CASE 
        WHEN h.media_grupo > g.media_global THEN 'Acima da Média'
        ELSE 'Abaixo da Média'
    END AS comparativo
FROM Metricas_Por_Felicidade h, Metricas_Globais g
ORDER BY h.nivel_felicidade DESC;



-- Isolar os top usuários mais engajados e ver se dão lucro
WITH Top_Engajados AS (
    -- Seleciona os usuários que interagem muito (Likes + Comentários)
    SELECT 
        SRK_USR,
        (LIK_GVN_DIA + COM_WRT_DIA) AS total_interacoes
    FROM dw.FT_ENG_APP
    WHERE (LIK_GVN_DIA + COM_WRT_DIA) > 300 -- Corte para Heavy User
),
Performance_Ads AS (
    -- Pega os dados de ads apenas desses usuários
    SELECT 
        f.SRK_USR,
        f.ADS_CLK_DIA
    FROM dw.FT_ADS_PRF f
    WHERE f.SRK_USR IN (SELECT SRK_USR FROM Top_Engajados)
)
SELECT 
    COUNT(*) AS qtd_heavy_users,
    AVG(ADS_CLK_DIA) AS media_cliques_heavy_users,
    SUM(ADS_CLK_DIA) AS total_cliques_gerados
FROM Performance_Ads;



-- Rankear os temas populares dentro de cada País.

WITH Performance_Tematica AS (
    -- Agrupa dados por País e Tema
    SELECT 
        u.CTR_USR AS pais,
        i.CNT_TME_PRF AS tema,
        SUM(f.ADS_CLK_DIA) AS total_cliques
    FROM dw.FT_ADS_PRF f
    JOIN dw.DIM_USR u ON f.SRK_USR = u.SRK_USR
    JOIN dw.DIM_ITR i ON f.SRK_ITR = i.SRK_ITR
    GROUP BY u.CTR_USR, i.CNT_TME_PRF
),
Ranking_Regional AS (
    -- Aplica um RANK() particionado por país
    SELECT 
        pais,
        tema,
        total_cliques,
        RANK() OVER (PARTITION BY pais ORDER BY total_cliques DESC) as ranking
    FROM Performance_Tematica
)
SELECT * FROM Ranking_Regional
WHERE ranking <= 3 
ORDER BY pais, ranking;