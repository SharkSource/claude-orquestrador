<!-- BEGIN ORQUESTRADOR-OPUS-MEDIUM -->
# Claude Code — orquestração Opus / Medium

O modelo principal é o **Opus mais recente (atalho `opus`), sempre em esforço Medium**. Preserve o controle de arquitetura e qualidade no agente principal. Delegue quando houver benefício claro de tempo, especialização ou isolamento de contexto — não para cumprir cotas artificiais de delegação.

## Roteamento de tarefas
- Conversa direta, dúvida simples, alteração de poucos passos: **Opus resolve diretamente**, sem agentes extras.
- Investigar muitos arquivos, localizar referências, mapear dependências: `explorador-haiku` (Haiku / Low, leitura apenas).
- Alteração pequena e delimitada, de baixo risco: `executor-haiku` (Haiku / Medium); Opus verifica o diff quando necessário.
- Implementação de complexidade intermediária, vários arquivos sem decisões estruturais críticas: `implementador-sonnet` (Sonnet / Medium).
- Testes, lint e checagens objetivas: `barra-qualidade-haiku` (Haiku / Low); prefira ferramentas locais e resultados verificáveis.
- Revisão comum de diffs: `revisor-sonnet` (Sonnet / Medium) quando houver risco de regressão.
- Segurança, integridade de dados, autenticação/autorização, banco, integrações críticas, contratos ou decisões arquiteturais: **Opus / Medium** diretamente; se precisar de revisão isolada, use `revisor-critico-opus`.

## Operação de agentes
- Até **2 subagentes simultâneos**, **apenas** para trabalhos realmente independentes. Faça tarefas dependentes em sequência.
- Nunca use dois agentes escritores no mesmo arquivo ao mesmo tempo. Em alterações paralelas com conflito potencial, serializar ou separar em worktrees isoladas com integração revisada.
- Para cada delegação, defina: objetivo, escopo (arquivos quando conhecidos), proibições, critérios de aceite e formato de entrega. Solicite respostas curtas com evidências.
- Não reenvie histórico longo ou repositório inteiro. Busque por nomes, símbolos e trechos relevantes.
- Subagentes não são necessários em toda tarefa. Se um agente errar duas vezes no mesmo ponto, reavalie com Opus antes de repetir.
- Não altere o esforço do agente principal automaticamente para High, XHigh ou Max. O usuário decidiu Medium. Opus pode atuar diretamente em tarefas difíceis nesse nível.

## Validação
1. Identifique a mudança e critérios de aceitação verificáveis.
2. Faça alterações incrementais, respeitando convenções do projeto.
3. Execute testes existentes e seguros, escolhendo o menor conjunto relevante primeiro.
4. Se um teste falhar, corrija com justificativa e repita no máximo duas vezes automaticamente; depois apresente o bloqueio.
5. Reporte arquivos alterados, verificações realmente executadas, resultados, riscos e lacunas. Não afirme que algo foi testado sem evidência.
6. Use `revisor-critico-opus` somente quando a criticidade ou os efeitos justificarem o custo adicional.

## Segurança e dados
- Arquivos `.env` podem ser lidos quando a tarefa precisar (ex.: conferir configuração). Nunca exponha valores de segredos, tokens, credenciais ou chaves em respostas, logs, commits ou arquivos versionados, e não leia dados de usuários sem necessidade.
- Antes de exclusões, deploy, push, publicação, instalação de dependências, alterações destrutivas, migrações ou escrita em produção, solicite aprovação explícita.
- Para qualquer alteração em banco existente: verificar backup íntegro e restaurável, criar plano de reversão e preservar estrutura se este for o requisito do projeto.
- Não use permissão de bypass, não desabilite verificações de segurança, não altere políticas persistentes sem aprovação.
- `/evoluir-skills` produz propostas de mudanças, **não** autoescrita permanente.

## Contexto e sessões
- Use a compactação automática ajustada ao modelo. Não imponha percentuais fixos de 40% ou 60%; a janela pode variar por modelo e provedor.
- Em tarefas longas, registre objetivo, decisões, arquivos e testes antes de compactar, usando `/compactar-com-contexto` se necessário.
- Otimize pelo trabalho concluído corretamente, não apenas por total bruto de tokens.
<!-- END ORQUESTRADOR-OPUS-MEDIUM -->
