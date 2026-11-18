# Claude Code — Orquestração Opus 5.5 Medium (Windows)

> **Modificações locais (17/11/2026) — prevalecem sobre o texto abaixo:**
> - Modelos por **atalho**, acompanhando sempre a versão mais nova: principal `opus`; agentes `haiku`, `sonnet` e `opus`; hook opcional `haiku`.
> - Esforço por `effortLevel: medium` **geral** (vale para qualquer versão do Opus). O instalador remove esforços fixados por versão do Opus deixados por pacotes antigos.
> - **Sem** bloqueio de leitura de `.env` (regras `permissions.deny` removidas). O `CLAUDE.md` permite ler `.env` quando a tarefa precisar, mas proíbe expor valores de segredos.
> - Removido `autoCompactWindow` (fica o padrão do Claude Code).

**Versão 2 — adaptação do pacote anterior para o uso real no Claude Pro.** Mantém Opus 5.5 como principal em esforço Medium. Usa Haiku 5.5 e Sonnet 5.5 como auxiliares, sem acionar subagentes por obrigação. Este pacote não é oficial da Anthropic nem reproduz o layout exato do vídeo (o áudio não mostra a árvore de pastas).

## Conteúdo

| Arquivo | Uso |
|---|---|
| `INSTALAR.ps1` | Instala ou atualiza a configuração; reconhece arquivos originais da v1 |
| `.claude/settings.json` | Seleciona Opus 5.5 e esforço Medium; compactação `auto` para o Opus |
| `CLAUDE.md` | Política de delegação, validação e segurança |
| `.claude/agents/` | Seis agentes especializados (Haiku, Sonnet e revisor crítico Opus) |
| `.claude/skills/` | Quatro skills: `/orquestrar`, `/verificar`, `/compactar-com-contexto`, `/evoluir-skills` |
| `PERFIL_VERIFICACAO_INTENSA.json` | Hook de Stop opcional, não habilitado automaticamente |
| `MANIFESTO-V1.json` | Hashes SHA-256 dos agentes e skills do primeiro pacote para atualização segura |

## Requisitos

- Windows 10 ou 11, PowerShell 7+.
- Claude Code atualizado; **v2.1.293 ou posterior** é necessário para trabalhar com Haiku 5.5 (prefira a versão mais recente com `claude update`).
- Acesso aos modelos conforme sua assinatura/provedor. O pacote não altera a assinatura, os limites de uso nem credenciais.

## Instalação recomendada em um projeto

1. Extraia o ZIP em uma pasta.
2. Abra **PowerShell 7** dentro da pasta extraída.
3. Execute (substitua a pasta do projeto):

```powershell
.\INSTALAR.ps1 -Escopo Projeto -Destino 'C:\Projetos\MeuProjeto'
```

Para instalar em todos os seus projetos:

```powershell
.\INSTALAR.ps1 -Escopo Global
```

Para habilitar a revisão extra por IA ao encerrar cada resposta:

```powershell
.\INSTALAR.ps1 -Escopo Global -VerificacaoRigorosa
```

**Atenção:** esse último modo chama um modelo adicional a cada parada, podendo aumentar o consumo e a latência. Comece sem ele.

Se scripts estiverem bloqueados por política de execução, após revisar o código do instalador você pode executar:

```powershell
pwsh -NoProfile -ExecutionPolicy Bypass -File .\INSTALAR.ps1 -Escopo Global
```

## Diferenças da versão 1

- `model: opus` foi substituído por `model: claude-opus-5-5` para **fixar a versão 5.5**, em vez de acompanhar futuras trocas de alias.
- Opus 5.5 usa `modelSettings.claude-opus-5-5.effortLevel: medium` (a forma recomendada para configurar esforço por modelo).
- A janela de compactação Opus usa `auto`, sem limiar arbitrário de 400k/600k.
- O pacote v1 tinha `effortLevel: xhigh` global e `autoCompactWindow: 400000`; ao detectar **ambos** no perfil antigo, o instalador remove esses campos legados.
- Sonnet e Haiku foram fixados à família **5.5** por ID completo nos subagentes.
- Revisões comuns com Sonnet, revisões críticas com Opus (`revisor-critico-opus`).
- Os nomes das skills e agentes existentes foram preservados; novo agente crítico foi acrescentado.

## Atualização sem apagar personalizações

- Antes de alterar `settings.json` ou `CLAUDE.md` existentes, o instalador cria cópias `.backup-AAAAMMDD-HHMMSS-fff`.
- Apenas o bloco identificado por marcadores dentro do `CLAUDE.md` é substituído. Texto externo fica intacto.
- Agentes e skills idênticos à versão 1 são atualizados com backup. Arquivos modificados manualmente ficam preservados e geram aviso para revisão manual.
- As configurações de outros modelos, permissões, ferramentas, hooks e plugins são preservadas. O modelo principal **Opus 5.5** e seu esforço **Medium** são definidos deliberadamente pela instalação.
- Se o hook extra da versão antiga já estiver ativo, a instalação sem `-VerificacaoRigorosa` **não remove hooks existentes**; desligue o antigo manualmente em `settings.json` se não o quiser. Com a opção, o hook antigo do próprio pacote é substituído pelo novo.
- Uma política de organização, variáveis como `ANTHROPIC_MODEL` e parâmetros de sessão podem prevalecer sobre estes arquivos. Use `/status`, `/model` e `/effort` para conferir.

## Uso

Execute `claude` dentro do seu projeto e teste:

```text
/model
/effort
/status
/agents
/skills
/orquestrar Analise os arquivos de rotas e explique o fluxo. Não altere nada.
```

Você **não precisa** iniciar toda tarefa com `/orquestrar`; a regra global já orienta delegação sensata. Use a skill quando quiser uma coordenação explícita. Para análise crítica, diga claramente: "Revise esta alteração crítica com Opus".

## Considerações sobre velocidade, custo e confiabilidade

- Os subagentes consomem capacidade do mesmo plano. **Não** existe ganho de velocidade ou economia garantido; muitos agentes podem piorar a latência.
- O limite de dois agentes simultâneos é uma **orientação no `CLAUDE.md`**, não uma limitação rígida imposta pela ferramenta. Separe escritas em série.
- Os agentes com `tools` restritos não substituem auditoria de execução. Shells podem produzir efeitos colaterais; por isso os prompts limitam os comandos.
- Skills não se autoaprimoram silenciosamente: `/evoluir-skills` **propõe** alterações para sua aprovação.
- Nenhum arquivo altera serviços existentes, dados de produção, autenticação, MCP, ou instalações de pacotes.
- A instalação não foi executada em um Windows nesta entrega; os JSONs, os frontmatters e o ZIP foram verificados estaticamente.

## Documentação da Anthropic

- https://code.claude.com/docs/en/model-config
- https://code.claude.com/docs/en/settings
- https://code.claude.com/docs/en/settings-reference
- https://code.claude.com/docs/en/sub-agents
- https://code.claude.com/docs/en/skills
- https://code.claude.com/docs/en/hooks
