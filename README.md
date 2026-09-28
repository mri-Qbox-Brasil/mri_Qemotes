# mri_Qemotes — Manual

Menu de emotes com a interface da suíte MRI, rodando sobre o catálogo e o motor de animação do `rpemotes-reborn`. Para servidores QBox que já usam o rpemotes e querem um menu com busca, favoritos, preview do personagem e navegação por teclado.

---

## Sumário

1. [Dependências](#dependências)
2. [Instalação](#instalação)
3. [Uso](#uso)
4. [Configuração](#configuração)
5. [Comandos](#comandos)
6. [Integrações](#integrações)
7. [Entrypoints para outros recursos](#entrypoints-para-outros-recursos)
8. [Localização](#localização)
9. [Estrutura de arquivos](#estrutura-de-arquivos)

---

## Dependências

| Recurso | Obrigatório | Observação |
|---|---|---|
| `rpemotes-reborn` | Sim | Versão 2.2.0 ou superior. Fornece o catálogo (`GetEmoteCatalog`) e executa os emotes |
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
3. No `config.lua` do `rpemotes-reborn`, desligue a tecla do menu nativo para não concorrer com o F4:
   ```lua
   MenuKeybindEnabled = false,
   ```
   Os comandos `/e`, `/emotemenu`, `/walk` e `/mood` do rpemotes continuam funcionando.

O pacote publicado já traz a interface compilada em `html/`. O build só é necessário a partir do repositório de fonte (`cd web && pnpm install && pnpm build`).

---

## Uso

### Abrir e fechar

`F4` (configurável em Configurações → Teclas → FiveM) ou `/em`. O menu abre encostado à direita da tela.

Com o menu aberto o jogador continua andando com WASD. Ficam bloqueados: atirar, mirar, roda de armas, troca de câmera, chat, pausa e as teclas que o menu usa.

### Preview

Ao passar o mouse sobre um emote, ou ao selecioná-lo pelo teclado, um clone do personagem aparece ao lado do menu fazendo o emote, com o objeto na mão quando houver. Humor mostra o rosto de perto. Emojis e Saídas não têm preview.

Clicar e arrastar fora do painel gira a câmera do jogo.

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
| `/mriemotes` | todos | Abre ou fecha o menu. É o comando ligado ao F4 |
| `/em` | todos | Atalho para `/mriemotes` |

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

---

## Localização

Textos em `locales/`, no formato do `ox_lib 'locale'`. Idiomas disponíveis: `pt-br` e `en`.

```
setr ox:locale "pt-br"
```

Os nomes dos emotes vêm do rpemotes e seguem o `MenuLanguage` dele.

---

## Estrutura de arquivos

```
mri_Qemotes/
├── client/
│   ├── catalog.lua       — espera o rpemotes e monta o índice do catálogo
│   ├── camera.lua        — gira a câmera do jogo a partir do arraste na NUI
│   ├── preview.lua       — clone do personagem que faz o emote ao lado do menu
│   └── main.lua          — abrir/fechar, callbacks da NUI, favoritos e recentes
├── server/
│   └── main.lua          — repassa mudanças de mri:color e mri:backgroundColor
├── locales/
│   ├── pt-br.json
│   └── en.json
├── html/                 — interface compilada
└── fxmanifest.lua
```
