# Platformer Base

Projeto base de jogo de plataforma 2D para Godot 4.3 ou superior (testado no 4.5). Todo o visual é provisório e foi feito para ser substituído.

## Controles

| Ação | Teclado | Controle |
|---|---|---|
| Mover | A / D ou setas | Analógico esquerdo ou direcional |
| Pular | Espaço, W ou seta para cima | Botão A |

## Estrutura de pastas

```
assets/       Arte e áudio brutos (sprites, audio, fonts)
resources/    Recursos .tres reutilizáveis (SpriteFrames)
scenes/       Cenas: actors, objects, world, levels, ui
scripts/      Um script por cena, espelhando a pasta de scenes
```

Cada cena tem seu script na mesma subpasta dentro de `scripts/`. A comunicação segue "sinais para cima, chamadas para baixo".

## Camadas de física

| Camada | Nome | Quem usa |
|---|---|---|
| 1 | world | Plataformas |
| 2 | player | Jogador |
| 3 | enemies | Inimigos |
| 4 | collectibles | Moedas |
| 5 | hazards | Zona de queda |

## Trocar o placeholder por animações

1. Coloque o spritesheet em `assets/sprites/...`.
2. Abra `resources/sprite_frames/player_frames.tres` e substitua os quadros de cada animação.
3. Animações do jogador: `idle`, `run`, `jump`, `fall`, `die`. Se alguma não existir, o script apenas a ignora.
4. Inimigo: `walk`, `die`. Moeda: `spin`.

A arte do jogador olha para a direita e a do inimigo para a esquerda. O espelhamento é feito por `flip_h`.

## Parallax

`scenes/world/parallax_background.tscn` usa `Parallax2D` em quatro camadas mais um céu fixo. Para trocar a arte, mude a textura do `Sprite2D` de cada camada e ajuste `repeat_size` para a largura da nova imagem. A velocidade fica em `scroll_scale`.

## Criar novas fases

1. Duplique `scenes/levels/level_01.tscn`.
2. Ajuste `bounds` no Inspetor do nó raiz (limites da câmera).
3. Arraste instâncias de `platform.tscn`, `coin.tscn` e `enemy_walker.tscn`.
4. A `Platform` é redimensionável pela propriedade `size`. Não use `scale` nela.

Para levar o jogador a uma fase nova, chame `Game.change_level(caminho_da_cena)`.

## Ajuste de sensação do pulo

Os valores ficam exportados no Inspetor do `Player` (grupos Movimento, Pulo e Interações). A gravidade vem de `Project Settings > Physics > 2D > Default Gravity`.
