---
name: orquestrar
description: Coordenar trabalho de desenvolvimento com Opus (Medium), delegando exploração e tarefas simples a Haiku, implementação intermediária a Sonnet e revisão crítica ao Opus.
argument-hint: "[objetivo da tarefa]"
---
Tarefa: $ARGUMENTS

1. Como Opus em Medium, transforme a tarefa em objetivo e critérios observáveis de aceite.
2. Se for rápida, curta ou de baixa complexidade, resolva diretamente sem subagente.
3. Se necessário, delegue exploração a `explorador-haiku`, pequenas alterações a `executor-haiku`, implementação intermediária a `implementador-sonnet` e teste a `barra-qualidade-haiku`.
4. Faça revisão por `revisor-sonnet` em tarefas de risco moderado; para autenticação, segurança, dados críticos, arquitetura ou contratos sensíveis, o próprio Opus decide/revisa, podendo chamar `revisor-critico-opus` se a independência justificar o custo.
5. Use no máximo 2 subagentes simultâneos, somente para tarefas independentes; nunca permita duas escritas concorrentes no mesmo arquivo.
6. Realize verificações reais, corrija falhas pontuais sem loops infinitos (no máximo duas tentativas automáticas).
7. Encerre indicando arquivos modificados, evidências de testes, limitações e riscos. Não invente métricas de tokens ou ganhos de desempenho.
