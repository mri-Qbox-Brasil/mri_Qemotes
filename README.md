# mri_Qemotes — Manual

Menu de emotes com a interface da suíte MRI, rodando sobre o catálogo e o motor de animação do `rpemotes-reborn`. Para servidores QBox que já usam o rpemotes e querem um menu com busca, favoritos, preview do personagem e navegação por teclado.

---

## Sumário

1. [Dependências](#dependências)
2. [Instalação](#instalação)
3. [Uso](#uso)
4. [Configuração](#configuração)
5. [Comandos](#comandos)
6. [Emotes em português](#emotes-em-português)
7. [Integrações](#integrações)
8. [Entrypoints para outros recursos](#entrypoints-para-outros-recursos)
9. [Substituindo o scully_emotemenu](#substituindo-o-scully_emotemenu)
10. [Localização](#localização)
11. [Estrutura de arquivos](#estrutura-de-arquivos)

---

## Dependências

| Recurso | Obrigatório | Observação |
|---|---|---|
| `rpemotes-reborn` | Sim | Fork da MRI (`mri-Qbox-Brasil/rpemotes-reborn`), com o export `AddEmotes`. Fornece o catálogo (`GetEmoteCatalog`), executa os emotes e recebe os emotes extras |
| `ox_lib` | Sim | Locale, notificações e o painel `/uiconfig` |

O recurso não usa banco de dados. Favoritos e recentes ficam no KVP do cliente.

---

## Instalação

1. Copie a pasta `mri_Qemotes` para `resources/`.
2. Garanta que o `rpemotes-reborn` sobe antes. Adicione ao `server.cfg`:
   ```
   ensure rpemotes-reborn
   ensure mri_Qemotes
   ```
3. No `config.lua` do `rpemotes-reborn`, desligue a tecla do menu nativo (F4) para ele não abrir junto:
   ```lua
   MenuKeybindEnabled = false,
   ```
   Os comandos `/e`, `/emotemenu`, `/walk` e `/mood` do rpemotes continuam funcionando.
4. Aumente o pool de animações do jogo no `server.cfg`. Os ~980 `.ycd` deste recurso, somados aos do rpemotes, passam do limite padrão (21.000, quase todo ocupado pelo GTA), e o jogo fecha na entrada com "AnimStore Pool Full". O comando só vale na subida do servidor:
   ```
   increase_pool_size "AnimStore" 20480
   ```
5. Se o `scully_emotemenu` ou o `dpemotes` estiverem no `server.cfg`, remova-os. O `mri_Qemotes` atende os exports deles; ver [Substituindo o scully_emotemenu](#substituindo-o-scully_emotemenu).

O pacote publicado já traz a interface compilada em `html/`. O build só é necessário a partir do repositório de fonte (`cd web && pnpm install && pnpm build`).

---

## Uso

### Abrir e fechar

`F5` (configurável em Configurações → Teclas → FiveM) ou `/em`. O menu abre encostado à direita da tela.

Com o menu aberto o jogador continua andando com WASD. Ficam bloqueados: atirar, mirar, roda de armas, troca de câmera, chat, pausa e as teclas que o menu usa.

### Preview

Ao passar o mouse sobre um emote, ou ao selecioná-lo pelo teclado, um clone do personagem aparece ao lado do menu fazendo o emote, com o objeto na mão quando houver. Humor mostra o rosto de perto. Emojis e Saídas não têm preview.

Segurar o botão esquerdo fora do painel solta o mouse para a câmera do jogo: o cursor some e o mouse gira a câmera normalmente. Ao soltar o botão, o cursor volta.

### Teclado

| Tecla | Na lista | Na coluna de categorias |
|---|---|---|
| `↑` `↓` | Navega pelos emotes | Troca a categoria |
| `←` | Vai para as categorias | — |
| `→` | — | Volta para a lista |
| `Enter` | Toca o emote | Volta para a lista |
| `Backspace` | Vai para as categorias | Fecha o menu |
| `F` | Favorita ou desfavorita | — |
| `PageUp` `PageDown` `Home` `End` | Pula pela lista | — |
| `Tab` | Entra e sai da busca | Entra na busca |
| `Esc` | Fecha o menu (ou sai da busca) | Fecha o menu |

Na grade de emojis as quatro setas andam pela grade. Enquanto a busca está em foco, o jogo não recebe nenhuma tecla; `↓` sai da busca para a lista e `Enter` toca o item selecionado.

### Abas

| Aba | Conteúdo |
|---|---|
| Todos | Gestos, danças, com objeto, em dupla e animais |
| Favoritos | Emotes marcados com a estrela ou com `F` |
| Recentes | Últimos 24 emotes tocados |
| Gestos, Danças, Com objeto, Em dupla, Animais, Saídas | Categorias do rpemotes |
| Andar | Estilos de `/walk` |
| Humor | Expressões de `/mood` |
| Emojis | Reações sobre a cabeça |
| +18 | Emotes adultos (`AdultAnimation`). Ficam só aqui, fora de Todos e das outras abas; somem se o `Config.AdultEmotesDisabled` do rpemotes estiver ligado |

Só aparecem as abas que têm emotes no catálogo carregado.

### Rodapé

Mostra o emote em execução, com as variações de objeto quando existem, e o andar e o humor atuais, cada um com um botão para voltar ao padrão.

---

## Configuração

Não há arquivo de configuração. O comportamento vem de convars e do `rpemotes-reborn`.

| Convar | Padrão | Descrição |
|---|---|---|
| `mri:color` | `#00E699` | Cor de destaque do menu. Muda em tempo real, inclusive com o menu aberto |
| `mri:backgroundColor` | vazio | Cor de fundo do painel. Vazio usa o tema do `/uiconfig` |
| `ox:locale` | `pt-br` | Idioma dos textos |

Raio das bordas, fonte e vidro do painel seguem o painel `/uiconfig` do ox_lib.

Quais emotes aparecem, permissões por categoria e o catálogo em si são configurados no `rpemotes-reborn`.

---

## Comandos

| Comando | Permissão | Descrição |
|---|---|---|
| `/mri_emotes` | todos | Abre ou fecha o menu. É o comando ligado ao F5 |
| `/em` | todos | Atalho para `/mri_emotes` |

---

## Emotes em português

O rpemotes traz os nomes dos emotes em inglês. O `mri_Qemotes` carrega `locales/emotes.<idioma>.json` e, para cada emote do rpemotes, aplica um rótulo traduzido e um ou mais apelidos de comando:

```json
"medbag": { "label": "Bolsa Médica", "alias": "bolsa5", "aliases": ["bolsa5", "bmedica"] }
```

Com isso, no menu o emote aparece como "Bolsa Médica" com o comando `/e bolsa5`, a busca acha por `bolsa5`, `bmedica` ou `medbag`, e os exports de compatibilidade aceitam qualquer um. O menu mostra o nome em inglês ao lado do traduzido e os dois comandos.

Os nomes em português vêm de duas fontes, nesta ordem de prioridade:

1. **Comandos legados**, o conjunto que os jogadores já conhecem: `/e joia`, `/e wtf`, `/e dancar3`, `/e caixa`. Podem ser várias listas, em ordem de prioridade: a primeira vale quando duas definem o mesmo nome de jeitos diferentes, e as seguintes só acrescentam. Cada entrada é casada com o rpemotes pelo dicionário, animação e objeto. Quando o rpemotes tem o emote, o nome legado vira apelido; quando não tem, vira um emote novo. Quando o rpemotes já usa o mesmo nome para outra animação (`radio`, `camera`, `sleep`, `shrug`, `no`...), **o legado vence** e esse nome passa a tocar a animação legada; a lista completa está em `tools/report.pt-br.txt`.
2. **Tradução do scully_emotemenu da MRI**, para os rótulos descritivos ("Bolsa Médica", "Continência") e como apelido secundário (`bmedica`), quando o nome não colide com o legado. Emotes que só o scully tinha viram emotes novos; se o nome já era do conjunto legado, ganham o sufixo `b` (`pose10b`).

Rótulos: o do scully quando é descritivo; o comando legado escrito por extenso quando o do scully é só "Palavra N" ou quando não há tradução (`dancar229` → "Dançar 229"). Emotes sem nome em nenhuma das fontes ficam em inglês.

Dois arquivos em `tools/` corrigem o que vem das fontes e são aplicados pelo gerador:

| Arquivo | O que faz |
|---|---|
| `words.pt-br.json` | Correção por palavra, em qualquer rótulo: acentos (`dancar` → `Dançar`, `maos` → `Mãos`), erros de digitação (`lixp` → `Lixo`), palavras em inglês (`weld` → `Soldar`) e comandos colados (`cortaessa` → `Corta Essa`) |
| `overrides.pt-br.json` | Rótulo fixo por emote (`"dance3": "Dançar 3B"`) |
| `legacy-aliases.pt-br.json` | Comandos legados que só prendem um objeto sem animação (`bolsa5`), apontados à mão para o emote equivalente do rpemotes |
| `adult.pt-br.json` | Padrões (regex) de dicionário, animação ou objeto que marcam um emote novo como adulto (`AdultAnimation`), para ele ir para a aba +18 |

O gerador acusa no relatório qualquer rótulo repetido dentro da mesma categoria e grava o relatório em `tools/report.pt-br.txt`.

O `/e`, `/walk` e `/mood` do chat são do rpemotes e só conhecem os nomes dele. Para os apelidos e os emotes extras valerem no chat, o `mri_Qemotes` os registra no rpemotes ao subir, pelo export `AddEmotes` (cliente e servidor), a partir de `data/emotes.lua`. Apelidos usam `AliasOf` e apontam para o mesmo dicionário, animação e objeto do original; os nomes legados que substituem um emote do rpemotes usam `Replace = true`. Nenhum arquivo do rpemotes é alterado, e se o `mri_Qemotes` parar, o rpemotes volta ao catálogo original.

Tudo é gerado por `tools/emotes-locale.mjs`, que lê a lista legada de comandos, os pares `*_pt-br.lua` do scully e o `AnimationList.lua` do rpemotes:

```sh
node tools/emotes-locale.mjs <scully>/data/animations <rpemotes-reborn>/client/AnimationList.lua pt-br --legacy <lista1>/core.lua --legacy <lista2>/core.lua --adult <lista>/main.lua
```

Rode de novo ao atualizar o rpemotes.

### Emotes que o rpemotes não tem

2.901 emotes das fontes não existem no rpemotes, seja pela animação ou pelo objeto (o sorvete de morango usa a mesma animação do hambúrguer, mas é outro emote): 2.668 do conjunto legado, 32 adultos em dupla e 201 do scully. O gerador os registra no mesmo `data/emotes.lua` como emotes novos, com o nome em português, convertendo objetos, loop, movimento, partículas, cenários e emotes em dupla para o formato do rpemotes. Os 979 arquivos `.ycd` que eles usam (59 MB) ficam em `stream/` e são streamados por este recurso; os demais usam animações nativas do jogo. Objetos customizados (`.ydr`/`.ytyp`) usados por algum emote também vão para `stream/`, e o gerador escreve as linhas `data_file` dos `.ytyp` no fim do `fxmanifest.lua`. Nove comandos legados que só prendem um objeto sem animação não têm equivalente e ficam de fora (`bolsa` a `bolsa4`, `caixa2`, `lixo`, `radio2`, `dildo8`, `surf`).

Os 32 emotes adultos em dupla (`--adult`) viram pares `x1`…`x16` e `x1t`…`x16t` na aba Em dupla, marcados como adultos: `/nearby x1` toca no jogador e pede o `x1t` a quem está mais perto, com o encaixe por osso ou o afastamento que a lista original definia. As 11 cenas de veículo dessa lista não são convertidas.

As animações vêm do repositório público do scully_emotemenu (GPL-3.0), que as distribui com permissão dos autores. Crédito a: BoringNeptune, BzZzi, MissSnowie, Molllyyy, Qpaccy, Sharror, Steph21, Struggleville e Ultrahacx.

---

## Integrações

### rpemotes-reborn

O `mri_Qemotes` não copia animações. Ele lê o catálogo com `exports['rpemotes-reborn']:GetEmoteCatalog()` e toca com `Execute(name, emoteType, variation)`. Parar usa `EmoteCancel`; andar e humor padrão usam `walk reset` e `mood reset`. Alterações no catálogo do rpemotes aparecem no menu após reiniciar o recurso.

### ox_lib

Notificação quando o catálogo ainda não carregou, `lib.callback` para o `/uiconfig` e o evento `ox_lib:uiConfigChanged` para aplicar mudanças com o menu aberto.

---

## Entrypoints para outros recursos

```lua
exports.mri_Qemotes:openMenu()
exports.mri_Qemotes:closeMenu()
exports.mri_Qemotes:toggleMenu()
```

Eventos de cliente disparados pelo servidor quando as convars mudam:

| Evento | Payload |
|---|---|
| `mri_Qemotes:client:accentColorChanged` | `color` (string hex) |
| `mri_Qemotes:client:backgroundColorChanged` | `color` (string hex ou vazio) |

Os exports abaixo também existem com o nome deste recurso (`exports.mri_Qemotes:playEmoteByCommand(...)`).

---

## Substituindo o scully_emotemenu

O `mri_Qemotes` responde aos exports e eventos do `scully_emotemenu`, então recursos escritos para ele funcionam sem alteração (`qbx_mechanicjob`, `qbx_consumables`, `mri_Qcrafting`, `mri_Qnpc`, `mri_Qbox`). O scully não pode estar no `server.cfg` ao mesmo tempo; o `mri_Qemotes` avisa no console se encontrar o `scully_emotemenu` ou o `dpemotes` rodando.

| Export (`exports.scully_emotemenu:...`) | Comportamento |
|---|---|
| `playEmoteByCommand(comando, variação?, ped?)` | Toca pelo nome do rpemotes ou pelo apelido em português. Com `ped`, toca num ped que não é o jogador (NPC), com objeto. Retorna `boolean` |
| `playEmote(dados, variação?, ped?)` | Igual, aceitando `{ Command = ... }` ou string |
| `cancelEmote()` | Para o emote do jogador |
| `isInEmote()` / `getLastEmote()` | Se há emote em execução / nome dele |
| `setLimitation(bool)` / `isLimited()` | Bloqueia emotes e o menu (algemado, por exemplo) e publica `LocalPlayer.state.canEmote` |
| `setWalk(clipset ou nome)` / `resetWalk()` / `getCurrentWalk()` | Estilo de andar; `getCurrentWalk` devolve o clipset ou `default` |
| `setExpression(nome)` / `resetExpression()` / `getCurrentExpression()` | Humor; `getCurrentExpression` devolve a expressão ou `default` |
| `clearpedsObjects()` | Remove os objetos presos a peds animados por `playEmoteByCommand` |
| `registerEmote(emote)` / `playRegisteredEmote(nome)` | Emotes registrados por outros recursos |
| `toggleMenu()` / `closeMenu()` / `openMenu()` | Menu |

Eventos de cliente atendidos: `scully_emotemenu:playByCommand`, `play`, `cancelEmote`, `cancelAnimation`, `closeMenu`, `toggleMenu`, `setWalk`, `resetWalk`, `setExpression`, `resetExpression`, `toggleLimitation`, `registerEmote`, `playRegisteredEmote`.

O que não é coberto: `require('@scully_emotemenu.data.animations...')`, que lê arquivos de dentro da pasta do scully. Recursos que fazem isso precisam passar a usar `exports['rpemotes-reborn']:GetEmoteCatalog()`.

---

## Localização

Textos em `locales/`, no formato do `ox_lib 'locale'`. Idiomas disponíveis: `pt-br` e `en`.

```
setr ox:locale "pt-br"
```

Os nomes dos emotes seguem `locales/emotes.<idioma>.json` quando o arquivo existe (só `pt-br` hoje); sem ele, ficam em inglês como no rpemotes.

---

## Estrutura de arquivos

```
mri_Qemotes/
├── client/
│   ├── catalog.lua       — espera o rpemotes, monta o índice e aplica a tradução
│   ├── animate.lua       — toca uma entrada do catálogo num ped qualquer, com objetos
│   ├── preview.lua       — clone do personagem que faz o emote ao lado do menu
│   ├── main.lua          — abrir/fechar, callbacks da NUI, favoritos e recentes
│   └── compat.lua        — exports e eventos do scully_emotemenu
├── server/
│   └── main.lua          — repassa mudanças de mri:color e mri:backgroundColor
├── data/
│   └── emotes.lua        — apelidos em português e emotes extras, registrados no rpemotes (gerado)
├── stream/               — .ycd dos emotes extras (gerado)
├── tools/
│   ├── emotes-locale.mjs — gera a tradução, o data/emotes.lua e o stream/
│   ├── words.pt-br.json  — correções por palavra aplicadas aos rótulos
│   ├── overrides.pt-br.json — rótulo fixo por emote
│   ├── legacy-aliases.pt-br.json — comandos legados só de objeto, mapeados à mão
│   ├── adult.pt-br.json  — padrões que marcam emotes como adultos
│   └── report.pt-br.txt  — relatório da última geração (sobrescritos, renomeados)
├── locales/
│   ├── pt-br.json
│   ├── en.json
│   └── emotes.pt-br.json — rótulo e apelido de cada emote (gerado)
├── html/                 — interface compilada
└── fxmanifest.lua
```
