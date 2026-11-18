---
name: verificar
description: Verificar alterações com testes reais e revisão proporcional ao risco, sem alegar resultados que não foram observados.
argument-hint: "[arquivos, recurso ou critério de aceitação]"
disable-model-invocation: true
---
Escopo: $ARGUMENTS

Identifique o diff e os critérios de aceitação aplicáveis. Priorize testes/linters existentes e seguros, preferencialmente com `barra-qualidade-haiku`, somente quando a delegação valer a pena. Em risco moderado use `revisor-sonnet`; em risco crítico Opus revisa diretamente ou chama `revisor-critico-opus`. Não faça alterações no ambiente, banco ou dependências só para conseguir testar. Informe o que PASSOU, FALHOU e NÃO FOI EXECUTADO, com comandos e justificativas. Não confunda ausência de erro com prova de correção.
