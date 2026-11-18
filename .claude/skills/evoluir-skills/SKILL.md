---
name: evoluir-skills
description: Propor melhorias incrementais em agentes e skills com evidências; nunca reescrever instruções persistentes sem aprovação.
argument-hint: "[falha observada, padrão recorrente ou skill]"
disable-model-invocation: true
---
Observação: $ARGUMENTS

1. Identifique evidências reais e diferencie falha de instrução, execução, modelo, teste e requisito.
2. Sugira mudanças mínimas como diff textual, com benefício esperado, possível regressão e custo.
3. Não modifique `.claude/agents`, `.claude/skills`, `CLAUDE.md` nem `settings.json` sem autorização explícita do usuário.
4. Após aprovação, aplique somente a mudança autorizada e verifique o carregamento. Não guarde credenciais, dados pessoais ou segredos nas instruções ou memórias.
